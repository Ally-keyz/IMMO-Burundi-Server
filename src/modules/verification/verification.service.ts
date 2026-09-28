import { Types } from 'mongoose';
import { Request } from 'express';
import { AppError } from '../../middleware/errorHandler.js';
import { VerificationRequest } from '../../models/verificationRequest.model.js';
import { VerificationCheck } from '../../models/verificationCheck.model.js';
import { Property } from '../../models/property.model.js';
import { Agent } from '../../models/agent.model.js';
import '../../models/users.model.js';
import { generateVerificationCode } from '../../helpers/codeGenerators.js';
import { auditLog } from '../../helpers/auditLog.js';
import { notifyAdmins, notifyUser } from '../../helpers/notify.js';
import { VERIFICATION_DISCLAIMER_VERSION, shapeDocuments } from '../../helpers/dtoShapers.js';
import { isAdmin } from '../../helpers/authz.js';
import { buildRequirements, missingRequirements } from './requirements.js';
import { OPEN_VERIFICATION_REQUEST_STATUSES, type VerificationStatus } from '@immo/shared-types';
import type { AgentVerificationItemDTO, AgentVerificationRequestDTO } from '@immo/shared-types';

const RESULT_TO_STATUS: Record<string, VerificationStatus> = {
  VERIFIED: 'VERIFIED',
  PARTIAL: 'PARTIAL',
  NOT_VERIFIED: 'NOT_VERIFIED',
};

function idFilter(id: string) {
  return Types.ObjectId.isValid(id) ? { $or: [{ _id: id }, { propertyId: id }] } : { propertyId: id };
}

async function loadRequestOr404(id: string): Promise<any> {
  const request: any = await VerificationRequest.findById(id);
  if (!request) throw new AppError(404, 'VERIFICATION_NOT_FOUND', 'Verification request not found.');
  return request;
}

async function assertOfficerOrAdmin(request: any, req: Request): Promise<void> {
  if (isAdmin(req)) return;
  if (req.user!.role !== 'VERIFICATION_OFFICER') {
    throw new AppError(403, 'FORBIDDEN', 'Only verification officers can perform this action.');
  }
  if (String(request.assignedOfficer) !== req.user!.sub) {
    throw new AppError(403, 'FORBIDDEN', 'This request is not assigned to you.');
  }
}

export async function createRequest(req: Request, body: any) {
  const property: any = await Property.findOne(idFilter(body.propertyId));
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');

  const userId = req.user!.sub;
  const agent = await Agent.findOne({ userId }).lean();
  const isOwner =
    String(property.ownerUserId) === userId ||
    String(property.landlordUserId) === userId ||
    String(property.createdBy) === userId;
  const isAgent = agent && String(property.agentId) === String((agent as any)._id);
  if (!isOwner && !isAgent && !isAdmin(req)) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot request verification for this property.');
  }

  /* One live request at a time - a second one would confuse the review queue. */
  const inFlight = await VerificationRequest.findOne({
    propertyId: property._id,
    status: { $in: OPEN_VERIFICATION_REQUEST_STATUSES },
  }).lean();
  if (inFlight) {
    throw new AppError(
      409,
      'VERIFICATION_ALREADY_REQUESTED',
      `A verification request is already in progress (${inFlight.status}).`,
    );
  }

  const verificationCode = await generateVerificationCode();
  const request = await VerificationRequest.create({
    propertyId: property._id,
    verificationCode,
    status: 'PENDING_PAYMENT',
    priority: body.priority ?? 0,
    requestedBy: userId,
    notes: body.notes,
    requestedAt: new Date(),
  });

  await auditLog({
    actorUserId: userId,
    action: 'VERIFICATION_REQUESTED',
    resourceType: 'VerificationRequest',
    resourceId: String(request._id),
    newData: { propertyId: String(property._id), verificationCode },
    requestId: req.requestId,
  });

  /* Moderators own the verification queue. */
  await notifyAdmins({
    type: 'NEW_VERIFICATION_REQUEST',
    title: 'New verification request',
    message: `"${property.title}" is waiting to be verified.`,
    data: { requestId: String(request._id), propertyId: String(property._id) },
  });

  return request;
}

export async function listRequests(req: Request, query: any) {
  const filter: Record<string, any> = {};
  if (isAdmin(req)) {
    /* all */
  } else if (req.user!.role === 'VERIFICATION_OFFICER') {
    filter.assignedOfficer = req.user!.sub;
  } else {
    filter.requestedBy = req.user!.sub;
  }
  if (query.status) filter.status = query.status;

  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const skip = (page - 1) * pageSize;

  const [items, total] = await Promise.all([
    VerificationRequest.find(filter)
      .sort({ priority: -1, createdAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .populate({
        path: 'propertyId',
        select: 'title propertyId listingType propertyType status media price provinceId communeId agentId ownerUserId landlordUserId',
        populate: [
          { path: 'provinceId', select: 'name code' },
          { path: 'communeId', select: 'name code' },
          { path: 'agentId', select: 'userId agencyName agentCode photo', populate: { path: 'userId', select: 'firstName lastName phone email photoUrl' } },
        ],
      })
      .populate('requestedBy', 'firstName lastName phone email photoUrl')
      .populate('assignedOfficer', 'firstName lastName'),
    VerificationRequest.countDocuments(filter),
  ]);

  return {
    items,
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}

export async function getRequest(id: string, req: Request) {
  const request = await loadRequestOr404(id);
  if (
    !isAdmin(req) &&
    req.user!.role !== 'VERIFICATION_OFFICER' &&
    String((request as any).requestedBy) !== req.user!.sub
  ) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot view this verification request.');
  }

  const checks = await VerificationCheck.find({ verificationRequestId: request._id })
    .populate('checkedBy', 'firstName lastName')
    .lean();

  return {
    request,
    checks,
    disclaimerVersion: VERIFICATION_DISCLAIMER_VERSION,
  };
}

export async function assignOfficer(id: string, req: Request, body: any) {
  const request = await loadRequestOr404(id);
  request.assignedOfficer = body.officerId;
  request.status = 'ASSIGNED';
  await request.save();

  await auditLog({
    actorUserId: req.user!.sub,
    action: 'VERIFICATION_ASSIGNED',
    resourceType: 'VerificationRequest',
    resourceId: String(request._id),
    newData: { assignedOfficer: body.officerId },
    requestId: req.requestId,
  });

  return request;
}

export async function startRequest(id: string, req: Request) {
  const request = await loadRequestOr404(id);
  await assertOfficerOrAdmin(request, req);
  if (!['ASSIGNED', 'PAYMENT_CONFIRMED'].includes(request.status)) {
    throw new AppError(409, 'INVALID_STATUS_TRANSITION', `Cannot start a request in status ${request.status}.`);
  }

  request.status = 'IN_PROGRESS';
  request.startedAt = new Date();
  await request.save();

  await auditLog({
    actorUserId: req.user!.sub,
    action: 'VERIFICATION_STARTED',
    resourceType: 'VerificationRequest',
    resourceId: String(request._id),
    requestId: req.requestId,
  });

  return request;
}

export async function addCheck(id: string, req: Request, body: any) {
  const request = await loadRequestOr404(id);
  await assertOfficerOrAdmin(request, req);

  if (!['IN_PROGRESS', 'UNDER_REVIEW', 'ASSIGNED'].includes(request.status)) {
    throw new AppError(409, 'INVALID_STATUS', 'Checks can only be recorded on active requests.');
  }

  const check = await VerificationCheck.create({
    verificationRequestId: request._id,
    documentId: body.documentId,
    checkType: body.checkType,
    status: body.status,
    notes: body.notes,
    checkedBy: req.user!.sub,
    checkedAt: new Date(),
  });

  await auditLog({
    actorUserId: req.user!.sub,
    action: 'VERIFICATION_CHECK_RECORDED',
    resourceType: 'VerificationCheck',
    resourceId: String(check._id),
    newData: { checkType: body.checkType, status: body.status },
    requestId: req.requestId,
  });

  return check;
}

export async function completeRequest(id: string, req: Request, body: any) {
  const request = await loadRequestOr404(id);
  await assertOfficerOrAdmin(request, req);

  if (['COMPLETED', 'CANCELLED'].includes(request.status)) {
    throw new AppError(409, 'INVALID_STATUS_TRANSITION', `Request is already ${request.status}.`);
  }

  const result = body.result as string;
  if (!Object.keys(RESULT_TO_STATUS).includes(result)) {
    throw new AppError(400, 'INVALID_RESULT', 'result must be VERIFIED, PARTIAL or NOT_VERIFIED.');
  }

  /* A rejection without a reason is not reviewable by the requester. */
  const rejectionReason = typeof body.reason === 'string' ? body.reason.trim() : '';
  if (result === 'NOT_VERIFIED' && !rejectionReason) {
    throw new AppError(400, 'REJECTION_REASON_REQUIRED', 'Explain why the verification is rejected.');
  }

  const property: any = await Property.findById(request.propertyId);
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');

  // Rule 8 — an owner may never mark their own property as verified.
  if (
    String(property.ownerUserId) === req.user!.sub ||
    String(property.landlordUserId) === req.user!.sub
  ) {
    throw new AppError(403, 'SELF_VERIFICATION_FORBIDDEN', 'Owners cannot verify their own properties.');
  }

  request.result = result as any;
  request.status = 'COMPLETED';
  request.completedBy = req.user!.sub;
  request.completedAt = new Date();
  request.disclaimerVersion = VERIFICATION_DISCLAIMER_VERSION;
  request.disclaimerAcceptedAt = new Date();
  if (body.notes) request.notes = body.notes;
  if (rejectionReason) request.rejectionReason = rejectionReason;
  await request.save();

  property.verificationStatus = RESULT_TO_STATUS[result];
  if (result === 'NOT_VERIFIED' && rejectionReason) property.verificationNotes = rejectionReason;
  if (body.level) property.verificationLevel = body.level;
  await property.save();

  await auditLog({
    actorUserId: req.user!.sub,
    action: 'VERIFICATION_COMPLETED',
    resourceType: 'VerificationRequest',
    resourceId: String(request._id),
    newData: { result, rejectionReason: rejectionReason || undefined, propertyVerificationStatus: property.verificationStatus },
    requestId: req.requestId,
  });

  /* Whoever asked for the verification needs the outcome. */
  await notifyUser(request.requestedBy, {
    type: 'VERIFICATION_COMPLETED',
    title: result === 'VERIFIED' ? 'Property verified' : 'Verification completed',
    message:
      result === 'VERIFIED'
        ? `"${property.title}" is now verified.`
        : rejectionReason
          ? `"${property.title}" was rejected: ${rejectionReason}`
          : `"${property.title}" is now ${property.verificationStatus}.`,
    data: { requestId: String(request._id), propertyId: String(property._id), result, reason: rejectionReason || undefined },
  });

  return { request, propertyId: String(property._id), verificationStatus: property.verificationStatus };
}

/* ── Agent portfolio ─────────────────────────────────────── */

/** Request states that still await a decision. Anything else is settled. */
const PENDING_REQUEST_STATUSES = ['PENDING_PAYMENT', 'PAYMENT_CONFIRMED', 'ASSIGNED', 'IN_PROGRESS', 'UNDER_REVIEW'];

/** Verification states the admin can still move forward from. */
function isPendingVerification(status?: string): boolean {
  return PENDING_REQUEST_STATUSES.includes(String(status ?? ''));
}

function isVerifiedStatus(status?: string): boolean {
  return status === 'VERIFIED' || status === 'FULLY_VERIFIED';
}

function personNameOf(ref: any): string | undefined {
  if (!ref) return undefined;
  if (typeof ref === 'string') return undefined;
  const first = String(ref.firstName ?? '').trim();
  const last = String(ref.lastName ?? '').trim();
  const name = `${first} ${last}`.trim();
  return name || undefined;
}

function shapeActiveRequest(request: any): AgentVerificationRequestDTO | null {
  if (!request) return null;
  return {
    id: String(request._id),
    verificationCode: String(request.verificationCode ?? ''),
    status: String(request.status ?? ''),
    result: request.result ?? undefined,
    rejectionReason: request.rejectionReason ?? undefined,
    requestedAt: request.requestedAt ? new Date(request.requestedAt).toISOString() : undefined,
    startedAt: request.startedAt ? new Date(request.startedAt).toISOString() : undefined,
    completedAt: request.completedAt ? new Date(request.completedAt).toISOString() : undefined,
    assignedOfficerName: personNameOf(request.assignedOfficer),
    isPending: isPendingVerification(request.status),
  };
}

/**
 * Everything an agent needs on one screen: the properties they manage, the
 * admin's verdict on each, any request still in flight, and the outstanding
 * items that block acceptance.
 *
 * Scoped to properties where the caller is the agent, owner, landlord or
 * creator — so an agent also sees requests the *owner* filed for their
 * listing, which `listRequests` (scoped to `requestedBy`) does not show.
 */
export async function agentPortfolio(req: Request) {
  const userId = req.user!.sub;
  const agent = await Agent.findOne({ userId }).select('_id').lean();
  const ownership: Record<string, unknown>[] = [
    { createdBy: userId },
    { ownerUserId: userId },
    { landlordUserId: userId },
  ];
  if (agent) ownership.push({ agentId: (agent as any)._id });

  const properties: any[] = await Property.find({ deletedAt: null, $or: ownership })
    .sort({ updatedAt: -1, createdAt: -1 })
    .populate('provinceId', 'name code')
    .populate('communeId', 'name code')
    .lean();

  /* Newest request per property, so a re-submitted property shows its latest state. */
  const propertyIds = properties.map((p) => p._id);
  const requests: any[] = propertyIds.length
    ? await VerificationRequest.find({ propertyId: { $in: propertyIds } })
        .sort({ createdAt: -1 })
        .populate('assignedOfficer', 'firstName lastName')
        .lean()
    : [];

  const latestByProperty = new Map<string, any>();
  for (const request of requests) {
    const key = String(request.propertyId?._id ?? request.propertyId);
    if (!latestByProperty.has(key)) latestByProperty.set(key, request);
  }

  const items: AgentVerificationItemDTO[] = properties.map((property: any) => {
    const requirements = buildRequirements(property);
    const media = Array.isArray(property.media) ? property.media : [];
    const primary = media.find((m: any) => m?.isPrimary) ?? media[0];
    const verificationStatus = String(property.verificationStatus ?? 'NOT_VERIFIED');
    const propertyStatus = String(property.status ?? 'DRAFT');

    return {
      propertyId: String(property._id),
      title: String(property.title ?? ''),
      thumbUrl: primary?.thumbUrl ?? primary?.url ?? undefined,
      listingType: String(property.listingType ?? ''),
      propertyType: String(property.propertyType ?? ''),
      propertyStatus,
      verificationStatus,
      verificationCode: property.verificationCode ?? undefined,
      verifiedAt: property.verifiedAt ? new Date(property.verifiedAt).toISOString() : undefined,
      adminNote: property.verificationNotes ?? undefined,
      reviewNote: property.reviewNote ?? undefined,
      rejectionReason: property.rejectionReason ?? undefined,
      needsCorrection:
        propertyStatus === 'NEEDS_CORRECTION' ||
        propertyStatus === 'REJECTED' ||
        Boolean(property.rejectionReason),
      activeRequest: shapeActiveRequest(latestByProperty.get(String(property._id))),
      documents: shapeDocuments(property.documents),
      requirements,
      missingCount: missingRequirements(requirements).length,
    };
  });

  return {
    items,
    summary: {
      total: items.length,
      pending: items.filter((i) => i.activeRequest?.isPending).length,
      verified: items.filter((i) => isVerifiedStatus(i.verificationStatus)).length,
      needsAction: items.filter(
        (i) => i.missingCount > 0 || i.needsCorrection || Boolean(i.adminNote) || Boolean(i.rejectionReason),
      ).length,
    },
  };
}
