import { Request } from 'express';
import { Types } from 'mongoose';
import type { VerificationStatus } from '@immo/shared-types';
import { OPEN_VERIFICATION_REQUEST_STATUSES } from '@immo/shared-types';
import { AppError } from '../../middleware/errorHandler.js';
import { Property } from '../../models/property.model.js';
import { Province } from '../../models/province.model.js';
import { Commune } from '../../models/commune.model.js';
import { Zone } from '../../models/zone.model.js';
import { Agent } from '../../models/agent.model.js';
import { Favorite } from '../../models/favorite.model.js';
import { PropertyView } from '../../models/propertyView.model.js';
import { PropertyDailyAnalytics } from '../../models/propertyDailyAnalytics.model.js';
import { AuditLog } from '../../models/auditLog.model.js';
import { VerificationRequest } from '../../models/verificationRequest.model.js';
import { Conversation } from '../../models/conversation.model.js';
import { Message } from '../../models/message.model.js';
import { Enquiry } from '../../models/enquiry.model.js';
import { generatePropertyId, generateVerificationCode } from '../../helpers/codeGenerators.js';
import { auditLog } from '../../helpers/auditLog.js';
import { agentUserIdForProperty, notifyAdmins, notifyUsers } from '../../helpers/notify.js';
import { isAdmin, isStaff } from '../../helpers/authz.js';
import {
  toAdminPropertyDTO,
  toAgentPropertyDTO,
  toOwnerPropertyDTO,
  toPropertySummaryDTO,
  toPublicPropertyDTO,
} from '../../helpers/dtoShapers.js';

const POPULATE = [
  { path: 'provinceId', select: 'name code' },
  { path: 'communeId', select: 'name code' },
  { path: 'zoneId', select: 'name code' },
  { path: 'ownerUserId', select: 'firstName lastName phone email address' },
  { path: 'landlordUserId', select: 'firstName lastName phone' },
  { path: 'createdBy', select: 'firstName lastName' },
  { path: 'approvedBy', select: 'firstName lastName' },
  { path: 'reviewedBy', select: 'firstName lastName' },
  { path: 'publishedBy', select: 'firstName lastName' },
  { path: 'agentId', populate: { path: 'userId', select: 'firstName lastName phone email' } },
];

const CREATE_FIELDS = [
  'title',
  'titleFr',
  'titleEn',
  'titleSw',
  'description',
  'descriptionFr',
  'descriptionEn',
  'descriptionSw',
  'propertyType',
  'listingType',
  'price',
  'isNegotiable',
  'surfaceArea',
  'bedrooms',
  'bathrooms',
  'rooms',
  'floors',
  'parkingSpaces',
  'yearBuilt',
  'provinceId',
  'communeId',
  'zoneId',
  'address',
  'latitude',
  'longitude',
  'locationPrecision',
  'media',
  'documents',
  'ownerUserId',
  'landlordUserId',
  'agentId',
] as const;

function pick(source: any, fields: readonly string[]): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const field of fields) {
    if (source[field] !== undefined) out[field] = source[field];
  }
  return out;
}

function idFilter(id: string) {
  return Types.ObjectId.isValid(id) ? { $or: [{ _id: id }, { propertyId: id }] } : { propertyId: id };
}

async function loadPropertyOr404(id: string, populate = false): Promise<any> {
  let query = Property.findOne({ ...idFilter(id), deletedAt: null });
  if (populate) query = query.populate(POPULATE as any);
  const property: any = await query;
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  return property;
}

function isOwner(property: any, userId: string): boolean {
  const owner = property.ownerUserId ?? property.createdBy;
  return String(owner) === userId;
}

async function canManage(property: any, req: Request): Promise<boolean> {
  const user = req.user!;
  if (isAdmin(req) || isOwner(property, user.sub)) return true;
  if (String(property.landlordUserId?._id ?? property.landlordUserId ?? '') === user.sub) return true;
  if (String(property.createdBy?._id ?? property.createdBy ?? '') === user.sub) return true;

  const populatedAgentUserId = property.agentId?.userId?._id ?? property.agentId?.userId;
  if (populatedAgentUserId && String(populatedAgentUserId) === user.sub) return true;
  if (property.agentId) {
    const agent = await Agent.findById(property.agentId).select('userId').lean();
    return Boolean(agent && String(agent.userId) === user.sub);
  }
  return false;
}

function escapeRegex(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function applyFilters(filter: Record<string, any>, query: any): void {
  if (query.q) {
    const rx = new RegExp(escapeRegex(String(query.q)), 'i');
    filter.$or = [
      { title: rx },
      { titleFr: rx },
      { titleEn: rx },
      { titleSw: rx },
      { description: rx },
      { propertyId: rx },
    ];
  }
  if (query.province) filter.provinceId = query.province;
  if (query.commune) filter.communeId = query.commune;
  if (query.zone) filter.zoneId = query.zone;
  if (query.propertyType) filter.propertyType = query.propertyType;
  if (query.listingType) filter.listingType = query.listingType;
  if (query.verificationStatus) filter.verificationStatus = query.verificationStatus;
  if (query.agentId) filter.agentId = query.agentId;
  if (query.bedrooms !== undefined) filter.bedrooms = { $gte: Number(query.bedrooms) };
  if (query.bathrooms !== undefined) filter.bathrooms = { $gte: Number(query.bathrooms) };
  if (query.isFeatured !== undefined) filter['badges.featured'] = query.isFeatured === true || query.isFeatured === 'true';
  if (query.minPrice !== undefined || query.maxPrice !== undefined) {
    filter['price.amount'] = {};
    if (query.minPrice !== undefined) filter['price.amount'].$gte = Number(query.minPrice);
    if (query.maxPrice !== undefined) filter['price.amount'].$lte = Number(query.maxPrice);
  }
  if (query.minSurface !== undefined || query.maxSurface !== undefined) {
    filter.surfaceArea = {};
    if (query.minSurface !== undefined) filter.surfaceArea.$gte = Number(query.minSurface);
    if (query.maxSurface !== undefined) filter.surfaceArea.$lte = Number(query.maxSurface);
  }
}

function buildSort(query: any): Record<string, 1 | -1> {
  const order: 1 | -1 = query.sortOrder === 'asc' ? 1 : -1;
  switch (query.sortBy) {
    case 'price':
      return { 'price.amount': order };
    case 'views':
      return { 'stats.views': order };
    case 'featured':
      return { 'badges.featured': order, publishedAt: -1 };
    case 'title':
      return { title: order };
    default:
      return { publishedAt: -1, createdAt: -1 };
  }
}

export async function createProperty(userId: string, body: any, meta?: { requestId?: string }) {
  if (!body.provinceId || !body.communeId) {
    throw new AppError(400, 'LOCATION_REQUIRED', 'provinceId and communeId are required.');
  }
  const province = await Province.findById(body.provinceId).lean();
  const commune = await Commune.findById(body.communeId).lean();
  if (!province || !commune) {
    throw new AppError(400, 'INVALID_LOCATION', 'Province or commune does not exist.');
  }

  const propertyId = await generatePropertyId((province as any).code, (commune as any).code);
  const agent = await Agent.findOne({ userId }).lean();

  const payload: any = pick(body, CREATE_FIELDS);
  payload.propertyId = propertyId;
  payload.createdBy = userId;
  payload.ownerUserId = body.ownerUserId ?? userId;
  if (['RENT', 'LEASE'].includes(body.listingType)) {
    payload.landlordUserId = body.landlordUserId ?? userId;
  }
  payload.agentId = body.agentId ?? (agent as any)?._id;
  /* The wizard's final button is "Submit property", so the listing goes straight into the
     admin review queue. Going live is still gated: approve and publish are adminOnly and
     blocked for the submitter (see TRANSITIONS / SELF_APPROVAL_FORBIDDEN). */
  payload.status = 'SUBMITTED';

  const property = await Property.create(payload);

  await auditLog({
    actorUserId: userId,
    action: 'PROPERTY_CREATED',
    resourceType: 'Property',
    resourceId: String(property._id),
    newData: { propertyId, title: property.title, status: property.status },
    requestId: meta?.requestId,
  });

  /* Fires the same notifications the submit transition does, so admins get the
     "new listing submitted" alert. The creating agent is excluded as the actor. */
  await notifyPropertyLifecycle(property, 'submit', userId);

  return loadPropertyOr404(String(property._id), true);
}

export async function listProperties(req: Request) {
  const query: any = { ...req.query };
  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const skip = (page - 1) * pageSize;

  const filter: Record<string, any> = { deletedAt: null };

  if (req.user) {
    filter.$and = [
      { $or: [{ status: 'PUBLISHED' }, { createdBy: req.user.sub }, { ownerUserId: req.user.sub }] },
    ];
    if (query.status) filter.status = query.status;
  } else {
    filter.status = 'PUBLISHED';
  }

  applyFilters(filter, query);

  const [items, total] = await Promise.all([
    Property.find(filter).sort(buildSort(query)).skip(skip).limit(pageSize).populate(POPULATE as any),
    Property.countDocuments(filter),
  ]);

  return {
    items: items.map((p) => toPropertySummaryDTO(p)),
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}

/** Sort keys for the agent property table, which paginates server-side. */
function buildManagedSort(query: any): Record<string, 1 | -1> {
  const order: 1 | -1 = query.sortOrder === 'asc' ? 1 : -1;
  switch (query.sortBy) {
    case 'views':
      return { 'stats.views': order };
    case 'title':
      return { title: order };
    default:
      return { createdAt: order };
  }
}

/** One batched lookup of open verification requests for a page of properties (avoids N+1). */
async function openVerificationsByProperty(
  propertyIds: unknown[],
): Promise<Map<string, { code: string; status: string }>> {
  const map = new Map<string, { code: string; status: string }>();
  if (propertyIds.length === 0) return map;
  const open = await VerificationRequest.find({
    propertyId: { $in: propertyIds },
    status: { $in: OPEN_VERIFICATION_REQUEST_STATUSES },
  })
    .sort({ createdAt: -1 })
    .select('propertyId verificationCode status')
    .lean();
  /* Newest first, so the first hit per property is the live one. */
  for (const request of open as any[]) {
    const key = String(request.propertyId);
    if (!map.has(key)) {
      map.set(key, { code: request.verificationCode, status: request.status });
    }
  }
  return map;
}

async function attachPendingVerification(dtos: any[], docs: any[]): Promise<void> {
  const map = await openVerificationsByProperty(docs.map((d) => d._id));
  for (let i = 0; i < dtos.length; i += 1) {
    dtos[i].pendingVerification = map.get(String(docs[i]._id)) ?? null;
  }
}

export async function listManagedProperties(userId: string, query: any) {
  const { page, pageSize, skip } = parsePaginationHelper(query);
  const agent = await Agent.findOne({ userId }).select('_id').lean();
  const ownership: Record<string, unknown>[] = [
    { createdBy: userId },
    { ownerUserId: userId },
    { landlordUserId: userId },
  ];
  if (agent) ownership.push({ agentId: (agent as any)._id });

  const filter: Record<string, any> = {
    deletedAt: null,
    $or: ownership,
  };
  if (query.status) filter.status = query.status;
  if (query.listingType) filter.listingType = query.listingType;
  if (query.propertyType) filter.propertyType = query.propertyType;
  if (query.province) filter.provinceId = query.province;
  if (query.commune) filter.communeId = query.commune;
  if (query.q) {
    const rx = new RegExp(escapeRegex(String(query.q)), 'i');
    filter.$and = [{ $or: [{ title: rx }, { propertyId: rx }, { description: rx }] }];
  }

  const [items, total] = await Promise.all([
    Property.find(filter).sort(buildManagedSort(query)).skip(skip).limit(pageSize).populate(POPULATE as any),
    Property.countDocuments(filter),
  ]);
  const dtos = items.map((property) => toAgentPropertyDTO(property));
  await attachPendingVerification(dtos, items as any[]);
  return {
    items: dtos,
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}

export async function getManagedProperty(id: string, req: Request) {
  const property = await loadPropertyOr404(id, true);
  if (!(await canManage(property, req))) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot access this property.');
  }
  const dto: any = toAgentPropertyDTO(property);
  const map = await openVerificationsByProperty([property._id]);
  dto.pendingVerification = map.get(String(property._id)) ?? null;
  return dto;
}

function parsePaginationHelper(query: any) {
  const page = Math.max(1, Number(query?.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query?.pageSize) || 20));
  return { page, pageSize, skip: (page - 1) * pageSize };
}
export async function featuredProperties(limit = 12) {
  const items = await Property.find({ status: 'PUBLISHED', 'badges.featured': true })
    .sort({ publishedAt: -1 })
    .limit(limit)
    .populate(POPULATE as any);
  return items.map(toPropertySummaryDTO);
}

export async function recentProperties(limit = 12) {
  const since = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const items = await Property.find({ status: 'PUBLISHED', publishedAt: { $gte: since } })
    .sort({ publishedAt: -1 })
    .limit(limit)
    .populate(POPULATE as any);
  return items.map(toPropertySummaryDTO);
}

export async function verifiedProperties(limit = 20) {
  const items = await Property.find({
    status: 'PUBLISHED',
    verificationStatus: { $in: ['VERIFIED', 'FULLY_VERIFIED'] },
  })
    .sort({ publishedAt: -1 })
    .limit(limit)
    .populate(POPULATE as any);
  return items.map(toPropertySummaryDTO);
}

export async function popularLocations(limit = 15) {
  return Property.aggregate([
    { $match: { status: 'PUBLISHED', deletedAt: null } },
    { $group: { _id: '$provinceId', count: { $sum: 1 } } },
    { $sort: { count: -1 } },
    { $limit: limit },
    {
      $lookup: {
        from: 'provinces',
        localField: '_id',
        foreignField: '_id',
        as: 'province',
      },
    },
    { $unwind: { path: '$province', preserveNullAndEmptyArrays: true } },
    {
      $project: {
        _id: 0,
        provinceId: '$_id',
        code: '$province.code',
        name: '$province.name',
        count: 1,
      },
    },
  ]);
}

async function recordView(property: any, req: Request): Promise<void> {
  const sessionId = (req.headers['x-session-id'] as string) || (req.query.sessionId as string);
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000);

  if (sessionId) {
    const existing = await PropertyView.findOne({
      propertyId: property._id,
      sessionId,
      viewedAt: { $gte: since },
    }).lean();
    if (existing) return;
  }

  await PropertyView.create({
    propertyId: property._id,
    userId: req.user?.sub,
    sessionId,
    deviceType: req.headers['x-device-type'] as string,
    browser: req.headers['user-agent'] as string,
    ipHash: (req.headers['x-ip-hash'] as string) || undefined,
    referrer: req.headers['referer'] as string,
  });
  await Property.updateOne({ _id: property._id }, { $inc: { 'stats.views': 1 } });
}

export async function getProperty(id: string, req: Request) {
  const property = await loadPropertyOr404(id, true);
  const user = req.user;

  if (!user) {
    if (property.status !== 'PUBLISHED') {
      throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
    }
    await recordView(property, req);
    return toPublicPropertyDTO(property);
  }

  if (isAdmin(req)) return toAdminPropertyDTO(property);

  const managed = await canManage(property, req);
  if (managed) {
    const agentUserId = property.agentId?.userId?._id ?? property.agentId?.userId;
    if (agentUserId && String(agentUserId) === user.sub) return toAgentPropertyDTO(property);
    return toOwnerPropertyDTO(property);
  }

  if (property.status !== 'PUBLISHED') {
    throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  }
  await recordView(property, req);
  return toPublicPropertyDTO(property);
}

export async function updateProperty(id: string, req: Request, body: any) {
  const property = await loadPropertyOr404(id);
  if (!(await canManage(property, req))) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot edit this property.');
  }
  if (!EDITABLE_STATUSES.includes(property.status)) {
    throw new AppError(
      409,
      'INVALID_STATUS',
      `Only ${EDITABLE_STATUSES.join(', ')} properties can be edited.`,
    );
  }

  const updates = pick(body, CREATE_FIELDS);
  Object.assign(property, updates);
  await property.save();

  await auditLog({
    actorUserId: req.user!.sub,
    action: 'PROPERTY_UPDATED',
    resourceType: 'Property',
    resourceId: String(property._id),
    newData: updates,
    requestId: req.requestId,
  });

  return loadPropertyOr404(String(property._id), true);
}

const NON_TERMINAL_STATUSES = ['DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'NEEDS_CORRECTION'];
const EDITABLE_STATUSES = ['DRAFT', 'NEEDS_CORRECTION', 'REJECTED'];

export async function deleteProperty(id: string, req: Request) {
  const property = await loadPropertyOr404(id);
  if (!(await canManage(property, req))) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot delete this property.');
  }
  if (!NON_TERMINAL_STATUSES.includes(property.status)) {
    throw new AppError(
      409,
      'INVALID_STATUS',
      'Only draft, submitted, approved, rejected or correction-requested properties can be deleted.',
    );
  }

  property.status = 'ARCHIVED';
  property.archivedAt = new Date();
  property.deletedAt = new Date();
  property.deletedBy = req.user!.sub;
  await property.save();

  await auditLog({
    actorUserId: req.user!.sub,
    action: 'PROPERTY_DELETED',
    resourceType: 'Property',
    resourceId: String(property._id),
    oldData: { propertyId: property.propertyId },
    requestId: req.requestId,
  });

  return { deleted: true, propertyId: property.propertyId, id: String(property._id) };
}

export async function setPropertyVerification(
  id: string,
  body: { status: VerificationStatus; note?: string },
  req: Request,
) {
  if (!isAdmin(req)) {
    throw new AppError(403, 'FORBIDDEN', 'Only an administrator can change property verification.');
  }
  const property = await loadPropertyOr404(id);
  const verifying = body.status === 'VERIFIED' || body.status === 'FULLY_VERIFIED';

  if (verifying && property.status === 'DRAFT') {
    throw new AppError(
      409,
      'PROPERTY_NOT_READY',
      'A draft property cannot be verified. Submit it for review first.',
    );
  }

  const previous = { verificationStatus: property.verificationStatus, verificationCode: property.verificationCode };
  property.verificationStatus = body.status;
  property.verificationNotes = body.note ?? (verifying ? property.verificationNotes : undefined);

  if (verifying) {
    property.verificationCode = property.verificationCode ?? (await generateVerificationCode());
    property.verificationLevel = body.status;
    property.verifiedAt = new Date();
    property.verifiedBy = req.user!.sub;
  } else {
    property.verificationCode = undefined;
    property.verificationLevel = undefined;
    property.verifiedAt = undefined;
    property.verifiedBy = undefined;
  }

  await property.save();

  await auditLog({
    actorUserId: req.user!.sub,
    action: verifying ? 'PROPERTY_VERIFIED' : 'PROPERTY_VERIFICATION_REVOKED',
    resourceType: 'Property',
    resourceId: String(property._id),
    oldData: previous,
    newData: { verificationStatus: property.verificationStatus, verificationCode: property.verificationCode, note: body.note },
    requestId: req.requestId,
  });

  return loadPropertyOr404(String(property._id), true);
}

type TransitionAction =
  | 'submit'
  | 'approve'
  | 'reject'
  | 'request-correction'
  | 'block'
  | 'unblock'
  | 'publish'
  | 'unpublish'
  | 'archive'
  |   'mark-sold'
  | 'mark-rented'
  | 'relist';

/** A property may only be published once verification reached one of these. */
const COMPLETED_VERIFICATION_STATUSES = ['VERIFIED', 'FULLY_VERIFIED'];

const TRANSITIONS: Record<
  TransitionAction,
  { from: string[]; to: string; adminOnly?: boolean; ownerAllowed?: boolean }
> = {  submit: { from: ['DRAFT', 'NEEDS_CORRECTION', 'REJECTED'], to: 'SUBMITTED' },
  approve: { from: ['SUBMITTED', 'UNDER_REVIEW'], to: 'APPROVED', adminOnly: true },
  reject: { from: ['SUBMITTED', 'UNDER_REVIEW'], to: 'REJECTED', adminOnly: true },
  'request-correction': {
    from: ['SUBMITTED', 'UNDER_REVIEW'],
    to: 'NEEDS_CORRECTION',
    adminOnly: true,
  },
  block: { from: [...NON_TERMINAL_STATUSES, 'PUBLISHED'], to: 'SUSPENDED', adminOnly: true },
  unblock: { from: ['SUSPENDED'], to: 'DRAFT', adminOnly: true },
  publish: { from: ['APPROVED'], to: 'PUBLISHED', adminOnly: true },
  unpublish: { from: ['PUBLISHED'], to: 'DRAFT', adminOnly: true },
  archive: { from: ['PUBLISHED'], to: 'ARCHIVED', ownerAllowed: true },
  'mark-sold': { from: ['PUBLISHED'], to: 'SOLD', ownerAllowed: true },
  'mark-rented': { from: ['PUBLISHED'], to: 'RENTED', ownerAllowed: true },
  /* An agent bringing a sold listing back to market. Lands on APPROVED so an admin
     still has to publish it — the property stays offline until a human acts. */
  relist: { from: ['SOLD', 'RENTED'], to: 'APPROVED', ownerAllowed: true },
};

export async function transitionProperty(id: string, action: TransitionAction, req: Request, body?: any) {
  const property = await loadPropertyOr404(id);
  const rule = TRANSITIONS[action];
  const userId = req.user!.sub;

  if (rule.adminOnly && !isAdmin(req)) {
    throw new AppError(403, 'FORBIDDEN', 'Only an administrator can perform this action.');
  }

  if (!rule.adminOnly && rule.ownerAllowed) {
    if (!isAdmin(req) && !isOwner(property, userId) && !(await canManage(property, req))) {
      throw new AppError(403, 'FORBIDDEN', 'You cannot perform this action on this property.');
    }
  } else if (!rule.adminOnly && action === 'submit') {
    if (!(await canManage(property, req))) {
      throw new AppError(403, 'FORBIDDEN', 'You cannot submit this property.');
    }
  }

  if (!rule.from.includes(property.status)) {
    throw new AppError(
      409,
      'INVALID_STATUS_TRANSITION',
      `Cannot ${action} a property in status ${property.status}.`,
    );
  }

  // Rule 5 — agents cannot approve/publish their own properties.
  if ((action === 'approve' || action === 'publish') && String(property.createdBy) === userId) {
    throw new AppError(
      403,
      'SELF_APPROVAL_FORBIDDEN',
      'You cannot approve or publish a property you submitted.',
    );
  }

  /* A listing only goes live once its verification has actually been completed. */
  if (action === 'publish' && !COMPLETED_VERIFICATION_STATUSES.includes(property.verificationStatus)) {
    throw new AppError(
      409,
      'VERIFICATION_REQUIRED',
      'This property must be verified before it can be published.',
    );
  }

  const oldStatus = property.status;
  property.status = rule.to;

  if (action === 'approve') {
    property.approvedBy = userId;
    property.reviewedBy = userId;
    property.reviewedAt = new Date();
    property.reviewNote = body?.note ?? body?.notes;
    property.rejectionReason = undefined;
  }
  if (action === 'publish') {
    property.publishedBy = userId;
    property.publishedAt = new Date();
    property.badges.isNew = true;
  }
  if (action === 'mark-sold') property.soldAt = new Date();
  if (action === 'mark-rented') property.rentedAt = new Date();
  if (action === 'relist') {
    // Coming back to market: clear the sold/rented markers and any stale
    // publication stamps so the history reads as a fresh listing.
    property.soldAt = undefined;
    property.rentedAt = undefined;
    property.publishedAt = undefined;
    property.publishedBy = undefined;
    property.archivedAt = undefined;
    property.badges.isNew = false;
  }
  if (action === 'archive') property.archivedAt = new Date();
  if (action === 'block') {
    property.blockedAt = new Date();
    property.blockedBy = userId;
    property.blockReason = body?.reason ?? body?.note;
    property.reviewedBy = userId;
    property.reviewedAt = new Date();
  }
  if (action === 'unblock') {
    property.blockedAt = undefined;
    property.blockedBy = undefined;
    property.blockReason = undefined;
    property.reviewedBy = userId;
    property.reviewedAt = new Date();
    property.reviewNote = body?.note ?? body?.reason ?? property.reviewNote;
  }
  if (action === 'reject' || action === 'request-correction') {
    property.internalNotes = body?.notes ?? property.internalNotes;
    property.reviewedBy = userId;
    property.reviewedAt = new Date();
    property.reviewNote = body?.note ?? body?.notes;
    if (action === 'reject') property.rejectionReason = body?.reason ?? body?.notes;
  }

  await property.save();

  await auditLog({
    actorUserId: userId,
    action: `PROPERTY_${action.toUpperCase().replace(/-/g, '_')}`,
    resourceType: 'Property',
    resourceId: String(property._id),
    oldData: { status: oldStatus },
    newData: { status: property.status, notes: body?.notes, reason: body?.reason },
    requestId: req.requestId,
  });

  await notifyPropertyLifecycle(property, action, userId, body?.reason ?? body?.notes);

  return loadPropertyOr404(String(property._id), true);
}

const LIFECYCLE_NOTIFICATIONS: Record<string, { type: string; title: string; message: string }> = {
  submit: { type: 'NEW_PROPERTY_SUBMITTED', title: 'Listing submitted', message: 'Your listing is waiting for review.' },
  approve: { type: 'PROPERTY_APPROVED', title: 'Listing approved', message: 'Your listing was approved.' },
  publish: { type: 'PROPERTY_PUBLISHED', title: 'Listing published', message: 'Your listing is now live.' },
  reject: { type: 'PROPERTY_REJECTED', title: 'Listing rejected', message: 'Your listing was rejected.' },
  'request-correction': {
    type: 'PROPERTY_CORRECTION_REQUIRED',
    title: 'Correction required',
    message: 'Your listing needs changes before it can be approved.',
  },
  archive: { type: 'SYSTEM', title: 'Listing archived', message: 'Your listing was archived.' },
  'mark-sold': { type: 'SYSTEM', title: 'Listing marked sold', message: 'Your listing was marked as sold.' },
  'mark-rented': { type: 'SYSTEM', title: 'Listing marked rented', message: 'Your listing was marked as rented.' },
  relist: { type: 'PROPERTY_RELISTED', title: 'Listing re-submitted', message: 'Your sold listing was re-submitted and is waiting for an admin to publish it.' },
  block: { type: 'SYSTEM', title: 'Listing suspended', message: 'Your listing was suspended.' },
  unpublish: { type: 'SYSTEM', title: 'Listing unpublished', message: 'Your listing was taken offline.' },
};

/** Tells the listing owner about a moderation decision, and admins about new submissions. */
async function notifyPropertyLifecycle(property: any, action: string, actorUserId: string, reason?: string) {
  const spec = LIFECYCLE_NOTIFICATIONS[action];
  if (!spec) return;

  const ownerIds = [property.ownerUserId, property.landlordUserId, property.createdBy, property.agentId]
    .filter(Boolean)
    .map((v: any) => String(v?._id ?? v));
  const agentUserId = await agentUserIdForProperty(property);
  const detail = reason ? `${spec.message} Reason: ${reason}` : spec.message;

  await notifyUsers([...ownerIds, agentUserId].filter((id) => id && id !== String(actorUserId)), {
    type: spec.type,
    title: spec.title,
    message: `"${property.title}": ${detail}`,
    data: { propertyId: String(property._id), action, status: property.status },
  });

  if (action === 'submit') {
    await notifyAdmins({
      type: 'NEW_PROPERTY_SUBMITTED',
      title: 'New listing submitted',
      message: `"${property.title}" is waiting for review.`,
      data: { propertyId: String(property._id) },
    });
  }
  if (action === 'relist') {
    await notifyAdmins({
      type: 'PROPERTY_RELISTED',
      title: 'Sold listing re-submitted',
      message: `"${property.title}" was re-listed by the agent and is waiting for review.`,
      data: { propertyId: String(property._id) },
    });
  }
}

/**
 * Payment-driven sale. A completed payment is authoritative — the money is in, so
 * the property leaves the public market regardless of its current status.
 *
 * Deliberately not routed through transitionProperty(): that enforces the
 * PUBLISHED→SOLD transition and the request-scoped actor permissions, neither of
 * which apply when the trigger is a payment link settlement.
 */
export async function markPropertySoldFromPayment(opts: {
  propertyId: string;
  paymentReference: string;
  amount: number;
  currency: string;
  payerPhone: string;
  linkId: string;
  actorUserId?: string;
  requestId?: string;
}): Promise<any | null> {
  const property = await Property.findById(opts.propertyId);
  if (!property) return null;
  if (property.status === 'SOLD') return property; // idempotent

  const oldStatus = property.status;
  property.status = 'SOLD';
  property.soldAt = new Date();
  if (property.badges) property.badges.isNew = false;
  await property.save();

  await auditLog({
    actorUserId: opts.actorUserId ?? null,
    action: 'PROPERTY_MARK_SOLD_BY_PAYMENT',
    resourceType: 'Property',
    resourceId: String(property._id),
    oldData: { status: oldStatus },
    newData: {
      status: 'SOLD',
      paymentReference: opts.paymentReference,
      amount: opts.amount,
      currency: opts.currency,
      paymentLinkId: opts.linkId,
    },
    requestId: opts.requestId,
  });

  const money = `${opts.amount} ${opts.currency}`;
  const ownerIds = [property.ownerUserId, property.landlordUserId, property.createdBy, property.agentId]
    .filter(Boolean)
    .map((v: any) => String(v?._id ?? v));
  const agentUserId = await agentUserIdForProperty(property);
  const propertyId = String(property._id);
  const data = {
    propertyId,
    paymentReference: opts.paymentReference,
    amount: opts.amount,
    currency: opts.currency,
    status: 'SOLD',
  };

  /* The listing agent / owner is told the deposit landed. */
  await notifyUsers([...new Set([...ownerIds, agentUserId].filter(Boolean))], {
    type: 'PROPERTY_SOLD_PAYMENT_RECEIVED',
    title: 'Payment received — listing sold',
    message: `"${property.title}" was paid (${money}, ref ${opts.paymentReference}). It has been taken off the public site.`,
    data,
  });

  /* Admins get the same event so it shows on their dashboard. */
  await notifyAdmins({
    type: 'PROPERTY_SOLD_PAYMENT_RECEIVED',
    title: 'Payment received — listing sold',
    message: `"${property.title}" was paid (${money}, ref ${opts.paymentReference}) and is now marked sold.`,
    data,
  });

  await postSoldThreadMessage(property, {
    paymentReference: opts.paymentReference,
    amount: opts.amount,
    currency: opts.currency,
  });

  return property;
}

/**
 * Drops a system message into the buyer/agent conversation for the property so the
 * sale is visible in the thread, not just in the notification bell. Attributed to
 * the agent side of the conversation and flagged isSystem so the UI can style it.
 */
async function postSoldThreadMessage(
  property: any,
  payment: { paymentReference: string; amount: number; currency: string },
): Promise<void> {
  try {
    const buyerId = await resolveBuyerIdForProperty(property);
    const agentUserId = await agentUserIdForProperty(property);
    if (!buyerId || !agentUserId || buyerId === agentUserId) return;

    const participants = [buyerId, agentUserId];
    let conversation = await Conversation.findOne({
      propertyId: property._id,
      participants: { $all: participants, $size: participants.length },
    });
    if (!conversation) {
      conversation = await Conversation.create({ propertyId: property._id, participants });
    }

    const text =
      `Payment received: ${payment.amount} ${payment.currency} (ref ${payment.paymentReference}). ` +
      `This property has been marked as sold and removed from public listings.`;
    const message = await Message.create({
      conversationId: conversation._id,
      senderId: agentUserId,
      message: text,
      isSystem: true,
    });

    conversation.lastMessageAt = new Date();
    await conversation.save();
    void message;
  } catch {
    /* A missing thread must never fail the payment. */
  }
}

/** The most recent enquirer on this property is treated as the buyer. */
async function resolveBuyerIdForProperty(property: any): Promise<string | null> {
  const enquiry = await Enquiry.findOne({ propertyId: property._id })
    .sort({ createdAt: -1 })
    .select('senderUserId')
    .lean();
  return enquiry?.senderUserId ? String(enquiry.senderUserId) : null;
}

export async function relatedProperties(id: string, limit = 12) {
  const property = await loadPropertyOr404(id);
  const items = await Property.find({
    _id: { $ne: property._id },
    status: 'PUBLISHED',
    propertyType: property.propertyType,
    provinceId: property.provinceId,
  })
    .sort({ publishedAt: -1 })
    .limit(limit)
    .populate(POPULATE as any);
  return items.map(toPropertySummaryDTO);
}

export async function toggleFavorite(id: string, userId: string) {
  const property = await loadPropertyOr404(id);
  const existing = await Favorite.findOne({ userId, propertyId: property._id });
  if (existing) {
    await existing.deleteOne();
    await Property.updateOne({ _id: property._id }, { $inc: { 'stats.favorites': -1 } });
    return { favorited: false, propertyId: String(property._id) };
  }
  await Favorite.create({ userId, propertyId: property._id });
  await Property.updateOne({ _id: property._id }, { $inc: { 'stats.favorites': 1 } });
  return { favorited: true, propertyId: String(property._id) };
}

export async function propertyAnalytics(id: string, req: Request) {
  const property = await loadPropertyOr404(id);
  if (!(await canManage(property, req))) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot view analytics for this property.');
  }
  const daily = await PropertyDailyAnalytics.find({ propertyId: property._id })
    .sort({ date: -1 })
    .limit(30)
    .lean();
  const stats = (property as any).stats ?? {};
  return {
    propertyId: property.propertyId,
    totals: {
      views: stats.views ?? 0,
      favorites: stats.favorites ?? 0,
      shares: stats.shares ?? 0,
      whatsappClicks: stats.whatsappClicks ?? 0,
      phoneClicks: stats.phoneClicks ?? 0,
      enquiries: stats.enquiries ?? 0,
      visitBookings: stats.visitBookings ?? 0,
    },
    daily,
  };
}

export async function propertyAuditTrail(id: string, limit = 50) {
  const property = await loadPropertyOr404(id);
  return AuditLog.find({ resourceType: 'Property', resourceId: String(property._id) })
    .sort({ createdAt: -1 })
    .limit(limit)
    .lean();
}
