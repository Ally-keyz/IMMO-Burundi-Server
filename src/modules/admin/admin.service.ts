import bcrypt from 'bcrypt';
import { randomBytes } from 'node:crypto';
import { Request } from 'express';
import {
  AdminAgentDTO,
  AdminBookingDTO,
  AdminDashboardSummary,
  AdminListQuery,
  AdminPropertyRow,
  AdminRequestDTO,
  CurrencyCode,
} from '@immo/shared-types';
import { Types } from 'mongoose';
import { AppError } from '../../middleware/errorHandler.js';
import { auditLog } from '../../helpers/auditLog.js';
import { notifyUser } from '../../helpers/notify.js';
import { generateAgentCode } from '../../helpers/codeGenerators.js';
import { paginationMeta, parsePagination } from '../../helpers/http.js';
import { toAdminPropertyDTO } from '../../helpers/dtoShapers.js';
import { User } from '../../models/users.model.js';
import { Agent } from '../../models/agent.model.js';
import { Role } from '../../models/role.model.js';
import { Province } from '../../models/province.model.js';
import { Property } from '../../models/property.model.js';
import { Enquiry } from '../../models/enquiry.model.js';
import { VisitBooking } from '../../models/visitBooking.model.js';
import { VisitSession } from '../../models/visitSession.model.js';
import { PropertyView } from '../../models/propertyView.model.js';
import { Payment } from '../../models/payment.model.js';
import { SalesCommission } from '../../models/salesCommission.model.js';
import { RentalCommission } from '../../models/rentalCommission.model.js';
import { Refund } from '../../models/refund.model.js';
import { VerificationRequest } from '../../models/verificationRequest.model.js';
import { setEnquiryStatus } from '../enquiries/enquiries.service.js';
import { updateBookingStatus } from '../visits/visits.service.js';
import { createAgentSetupToken } from '../auth/auth.service.js';
import { isSmtpConfigured, sendAgentSetupEmail } from '../auth/mail.service.js';
import { env } from '../../config/env.js';

const SALE_LISTING_TYPES = ['SALE', 'AUCTION'];

/* Statuses that mean "an administrator still has to decide something". Anything
   outside these lists is already settled and never earns a rail badge. */
const PENDING_REVIEW_PROPERTY_STATUSES = ['SUBMITTED', 'UNDER_REVIEW', 'NEEDS_CORRECTION', 'REJECTED'];
const PENDING_REQUEST_STATUSES = ['NEW', 'OPEN'];
const PENDING_BOOKING_STATUSES = ['PENDING'];
const SETTLED_VERIFICATION_STATUSES = ['COMPLETED', 'CANCELLED', 'REJECTED'];

const PROPERTY_POPULATE = [
  { path: 'provinceId', select: 'name code' },
  { path: 'communeId', select: 'name code' },
  { path: 'zoneId', select: 'name code' },
  { path: 'ownerUserId', select: 'firstName lastName phone email address' },
  { path: 'landlordUserId', select: 'firstName lastName phone email' },
  { path: 'createdBy', select: 'firstName lastName' },
  { path: 'approvedBy', select: 'firstName lastName' },
  { path: 'reviewedBy', select: 'firstName lastName' },
  { path: 'publishedBy', select: 'firstName lastName' },
  { path: 'agentId', populate: { path: 'userId', select: 'firstName lastName phone email' } },
];

const BOOKING_POPULATE = [
  { path: 'userId', select: 'firstName lastName phone email photoUrl' },
  {
    path: 'visitSessionId',
    select: 'date startTime endTime capacity bookedCount propertyId',
    populate: {
      path: 'propertyId',
      select: '_id propertyId title listingType media agentId',
      populate: { path: 'agentId', select: '_id userId', populate: { path: 'userId', select: 'firstName lastName' } },
    },
  },
  {
    path: 'propertyId',
    select: '_id propertyId title listingType media agentId',
    populate: { path: 'agentId', select: '_id userId', populate: { path: 'userId', select: 'firstName lastName' } },
  },
];

const REQUEST_POPULATE = [
  { path: 'senderUserId', select: 'firstName lastName phone email photoUrl' },
  {
    path: 'propertyId',
    select: '_id propertyId title listingType price media agentId',
    populate: { path: 'agentId', select: '_id userId', populate: { path: 'userId', select: 'firstName lastName' } },
  },
  { path: 'agentId', select: '_id userId', populate: { path: 'userId', select: 'firstName lastName' } },
];

function toPlain(value: any): any {
  if (!value) return value;
  return typeof value.toObject === 'function' ? value.toObject({ virtuals: false }) : value;
}

function escapeRegex(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function iso(value: any): string | undefined {
  if (!value) return undefined;
  const date = value instanceof Date ? value : new Date(value);
  return Number.isNaN(date.getTime()) ? undefined : date.toISOString();
}

function idOf(value: any): string {
  return String(value?._id ?? value ?? '');
}

function propertyIdFilter(value: string): Record<string, unknown> {
  return Types.ObjectId.isValid(value) ? { $or: [{ _id: value }, { propertyId: value }] } : { propertyId: value };
}

function nameOf(value: any): string {
  const user = toPlain(value);
  return [user?.firstName, user?.lastName].filter(Boolean).join(' ').trim();
}

function provinceOf(value: any): AdminAgentDTO['province'] {
  const province = toPlain(value);
  if (!province?._id) return undefined;
  return { _id: idOf(province), code: province.code ?? '', name: province.name ?? '' };
}

function shapeAgent(agent: any): AdminAgentDTO {
  const value = toPlain(agent);
  const user = toPlain(value.userId);
  return {
    id: idOf(value),
    userId: idOf(user),
    firstName: user?.firstName ?? '',
    lastName: user?.lastName ?? '',
    phone: user?.phone ?? '',
    email: user?.email,
    role: (user?.role ?? 'AGENT') as AdminAgentDTO['role'],
    status: user?.status ?? 'PENDING',
    agentStatus: value.status ?? 'ACTIVE',
    verificationStatus: value.verificationStatus ?? 'NOT_VERIFIED',
    verifiedAt: iso(value.verifiedAt),
    statusReason: value.statusReason,
    statusChangedAt: iso(value.statusChangedAt),
    statusChangedBy: value.statusChangedBy ? idOf(value.statusChangedBy) : undefined,
    agentCode: value.agentCode,
    agencyName: value.agencyName,
    licenseNumber: value.licenseNumber,
    province: provinceOf(value.provinceId),
    totalProperties: value.totalProperties ?? 0,
    totalSales: value.totalSales ?? 0,
    totalDeals: value.totalDeals ?? 0,
    createdAt: iso(value.createdAt) ?? new Date().toISOString(),
  };
}

export function shapeProperty(property: any): AdminPropertyRow {
  return toAdminPropertyDTO(property) as AdminPropertyRow;
}

function shapeBooking(booking: any): AdminBookingDTO {
  const value = toPlain(booking);
  const session = toPlain(value.visitSessionId);
  const property = toPlain(session?.propertyId ?? value.propertyId);
  const agentUser = toPlain(property?.agentId?.userId);
  return {
    id: idOf(value),
    bookingReference: value.bookingReference ?? '',
    status: value.status ?? 'PENDING',
    preferredDate: value.preferredDate,
    startTime: value.startTime ?? session?.startTime,
    numberOfPeople: value.numberOfPeople ?? 1,
    notes: value.notes,
    createdAt: iso(value.createdAt) ?? new Date().toISOString(),
    user: {
      id: idOf(value.userId),
      firstName: toPlain(value.userId)?.firstName ?? '',
      lastName: toPlain(value.userId)?.lastName ?? '',
      phone: toPlain(value.userId)?.phone,
      email: toPlain(value.userId)?.email,
    },
    property: property
      ? {
          id: idOf(property),
          propertyId: property.propertyId ?? '',
          title: property.title ?? '',
          listingType: property.listingType,
          media: property.media ?? [],
        }
      : undefined,
    agent: agentUser
      ? { id: idOf(property?.agentId), firstName: agentUser.firstName ?? '', lastName: agentUser.lastName ?? '' }
      : undefined,
    session: session
      ? {
          id: idOf(session),
          date: iso(session.date) ?? '',
          startTime: session.startTime ?? '',
          endTime: session.endTime ?? '',
          capacity: session.capacity ?? 0,
          bookedCount: session.bookedCount ?? 0,
        }
      : undefined,
  };
}

function shapeRequest(enquiry: any): AdminRequestDTO {
  const value = toPlain(enquiry);
  const sender = toPlain(value.senderUserId);
  const property = toPlain(value.propertyId);
  const agent = toPlain(value.agentId?.userId ?? property?.agentId?.userId);
  return {
    id: idOf(value),
    subject: value.subject,
    message: value.message ?? '',
    status: value.status ?? 'NEW',
    createdAt: iso(value.createdAt) ?? new Date().toISOString(),
    sender: {
      id: idOf(sender),
      firstName: sender?.firstName ?? '',
      lastName: sender?.lastName ?? '',
      phone: sender?.phone,
      email: sender?.email,
    },
    property: {
      id: idOf(property),
      propertyId: property?.propertyId ?? '',
      title: property?.title ?? '',
      price: property?.price,
      media: property?.media ?? [],
    },
    agent: agent ? { id: idOf(value.agentId ?? property?.agentId), firstName: agent.firstName ?? '', lastName: agent.lastName ?? '' } : undefined,
  };
}

async function dailySeries(model: any, field: string, from: Date): Promise<Map<string, number>> {
  const rows = await model.aggregate([
    { $match: { [field]: { $gte: from } } },
    { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: `$${field}` } }, count: { $sum: 1 } } },
  ]);
  return new Map(rows.map((row: any) => [String(row._id), Number(row.count ?? 0)]));
}

async function sumByCurrency(model: any, match: Record<string, unknown>, field = 'amount'): Promise<Map<string, number>> {
  const rows = await model.aggregate([
    { $match: match },
    { $group: { _id: '$currency', total: { $sum: `$${field}` } } },
  ]);
  return new Map(rows.map((row: any) => [String(row._id), Number(row.total ?? 0)]));
}

function mergeFinance(
  payments: Map<string, number>,
  sales: Map<string, number>,
  rentals: Map<string, number>,
  refunds: Map<string, number>,
): Array<{ currency: CurrencyCode; payments: number; commissions: number; refunds: number }> {
  const currencies = new Set<string>([...payments.keys(), ...sales.keys(), ...rentals.keys(), ...refunds.keys()]);
  return Array.from(currencies).map((currency) => ({
    currency: currency as CurrencyCode,
    payments: payments.get(currency) ?? 0,
    commissions: (sales.get(currency) ?? 0) + (rentals.get(currency) ?? 0),
    refunds: refunds.get(currency) ?? 0,
  }));
}

export async function getSummary(query: any = {}): Promise<AdminDashboardSummary> {
  const periodDays = Math.min(90, Math.max(7, Number(query.periodDays) || 30));
  const from = new Date(Date.now() - (periodDays - 1) * 24 * 60 * 60 * 1000);
  from.setUTCHours(0, 0, 0, 0);
  const saleFilter = { deletedAt: null, listingType: { $in: SALE_LISTING_TYPES } };
  const salePropertyIds = (await Property.find(saleFilter).select('_id').lean()).map((property: any) => property._id);

  const [
    users,
    activeUsers,
    agents,
    activeAgents,
    properties,
    publishedProperties,
    underReviewProperties,
    bookings,
    saleRequests,
    views,
    viewDays,
    enquiryDays,
    bookingDays,
    propertyStatusRows,
    agentStatusRows,
    paymentTotals,
    salesTotals,
    rentalTotals,
    refundTotals,
    topAgents,
    recentProperties,
    pendingAgents,
    pendingProperties,
    pendingBookings,
    pendingRequests,
    pendingVerification,
    pendingAgentVerification,
  ] = await Promise.all([
    User.countDocuments({ deletedAt: null }),
    User.countDocuments({ status: 'ACTIVE', deletedAt: null }),
    Agent.countDocuments(),
    Agent.countDocuments({ status: 'ACTIVE' }),
    Property.countDocuments({ deletedAt: null }),
    Property.countDocuments({ status: 'PUBLISHED', deletedAt: null }),
    Property.countDocuments({ status: { $in: ['SUBMITTED', 'UNDER_REVIEW'] }, deletedAt: null }),
    VisitBooking.countDocuments(),
    Enquiry.countDocuments({ propertyId: { $in: salePropertyIds } }),
    PropertyView.countDocuments({ viewedAt: { $gte: from } }),
    dailySeries(PropertyView, 'viewedAt', from),
    dailySeries(Enquiry, 'createdAt', from),
    dailySeries(VisitBooking, 'createdAt', from),
    Property.aggregate([{ $match: { deletedAt: null } }, { $group: { _id: '$status', count: { $sum: 1 } } }]),
    Agent.aggregate([{ $group: { _id: '$status', count: { $sum: 1 } } }]),
    sumByCurrency(Payment, { status: 'COMPLETED', paidAt: { $gte: from } }),
    sumByCurrency(SalesCommission, { status: { $in: ['PAID', 'DUE'] } }),
    sumByCurrency(RentalCommission, { status: { $in: ['PAID', 'DUE'] } }),
    sumByCurrency(Refund, { status: 'PROCESSED', processedAt: { $gte: from } }),
    Agent.find().sort({ totalProperties: -1, totalDeals: -1 }).limit(5).populate('userId', 'firstName lastName phone email').populate('provinceId', 'name code'),
    Property.find({ deletedAt: null }).sort({ createdAt: -1 }).limit(6).populate(PROPERTY_POPULATE as any),
    /* Rail badges: one actionable queue per dashboard tab. */
    Agent.countDocuments({ status: { $ne: 'ACTIVE' } }),
    Property.countDocuments({ status: { $in: PENDING_REVIEW_PROPERTY_STATUSES }, deletedAt: null }),
    VisitBooking.countDocuments({ status: { $in: PENDING_BOOKING_STATUSES } }),
    Enquiry.countDocuments({ propertyId: { $in: salePropertyIds }, status: { $in: PENDING_REQUEST_STATUSES } }),
    VerificationRequest.countDocuments({ status: { $nin: SETTLED_VERIFICATION_STATUSES } }),
    Agent.countDocuments({ verificationStatus: { $ne: 'VERIFIED' } }),
  ]);

  const trend = Array.from({ length: periodDays }, (_, index) => {
    const date = new Date(from.getTime() + index * 24 * 60 * 60 * 1000);
    const key = date.toISOString().slice(0, 10);
    return { date: key, views: viewDays.get(key) ?? 0, enquiries: enquiryDays.get(key) ?? 0, bookings: bookingDays.get(key) ?? 0 };
  });

  return {
    generatedAt: new Date().toISOString(),
    periodDays,
    totals: {
      users,
      activeUsers,
      agents,
      activeAgents,
      properties,
      publishedProperties,
      underReviewProperties,
      bookings,
      saleRequests,
      views,
    },
    /* The Verification tab holds two queues (property requests and agent files), so
       its badge is the sum of both - the same total its own sub-tabs show. */
    pending: {
      agents: pendingAgents,
      properties: pendingProperties,
      bookings: pendingBookings,
      requests: pendingRequests,
      verification: pendingVerification + pendingAgentVerification,
      total: pendingAgents + pendingProperties + pendingBookings + pendingRequests + pendingVerification + pendingAgentVerification,
    },
    trend,
    propertyStatus: propertyStatusRows.map((row: any) => ({ label: String(row._id ?? 'UNKNOWN'), value: Number(row.count ?? 0) })),
    agentStatus: agentStatusRows.map((row: any) => ({ label: String(row._id ?? 'UNKNOWN'), value: Number(row.count ?? 0) })),
    finance: mergeFinance(paymentTotals, salesTotals, rentalTotals, refundTotals),
    topAgents: (topAgents as any[]).map(shapeAgent),
    recentProperties: (recentProperties as any[]).map(shapeProperty),
  };
}

export async function listAgents(query: AdminListQuery) {
  const { page, pageSize, skip } = parsePagination(query);
  const match: Record<string, any> = {};
  if (query.status) match.status = query.status;

  const pipeline: any[] = [
    { $match: match },
    { $lookup: { from: 'users', localField: 'userId', foreignField: '_id', as: 'user' } },
    { $addFields: { userId: { $arrayElemAt: ['$user', 0] } } },
  ];

  if (query.q) {
    const rx = new RegExp(escapeRegex(query.q), 'i');
    pipeline.push({
      $match: {
        $or: [
          { agentCode: rx },
          { agencyName: rx },
          { 'userId.firstName': rx },
          { 'userId.lastName': rx },
          { 'userId.phone': rx },
          { 'userId.email': rx },
        ],
      },
    });
  }

  pipeline.push(
    { $sort: { createdAt: -1 } },
    { $facet: { total: [{ $count: 'count' }], items: [{ $skip: skip }, { $limit: pageSize }] } },
  );

  const result = await Agent.aggregate(pipeline);
  const facet = result[0] ?? { total: [], items: [] };
  const total = facet.total?.[0]?.count ?? 0;
  await Agent.populate(facet.items, { path: 'provinceId', select: 'name code' });
  return { items: facet.items.map(shapeAgent), meta: paginationMeta(page, pageSize, total) };
}

export async function createAgent(body: any, actorUserId: string, requestId?: string): Promise<AdminAgentDTO> {
  const phone = String(body.phone).trim();
  const email = String(body.email ?? '').trim().toLowerCase();
  if (!email) {
    throw new AppError(400, 'SETUP_EMAIL_REQUIRED', 'An email address is required to set up the agent account.');
  }
  if (env.NODE_ENV === 'production' && !isSmtpConfigured()) {
    throw new AppError(503, 'SETUP_EMAIL_NOT_CONFIGURED', 'Agent setup email delivery is not configured.');
  }
  if (await User.exists({ $or: [{ phone }, { email }] })) {
    throw new AppError(409, 'AGENT_ACCOUNT_EXISTS', 'An account with this phone or email already exists.');
  }

  const province = body.provinceId ? await Province.findById(body.provinceId).lean() : null;
  if (body.provinceId && !province) throw new AppError(400, 'INVALID_PROVINCE', 'Province does not exist.');
  const role = await Role.findOne({ name: body.role }).lean();
  const user = await User.create({
    firstName: body.firstName,
    lastName: body.lastName,
    phone,
    email,
    passwordHash: await bcrypt.hash(randomBytes(48).toString('hex'), 12),
    role: body.role,
    roleId: role?._id,
    status: 'PENDING',
  });

  let agent: any;
  try {
    agent = await Agent.create({
      userId: user._id,
      agentCode: await generateAgentCode((province as any)?.code),
      agencyName: body.agencyName,
      licenseNumber: body.licenseNumber,
      provinceId: body.provinceId,
      status: 'ACTIVE',
    });
  } catch (err) {
    await User.deleteOne({ _id: user._id });
    throw err;
  }

  let setupEmailSent = false;
  let setupUrl: string | undefined;
  try {
    const setup = await createAgentSetupToken(String(user._id));
    const delivery = await sendAgentSetupEmail({ email, firstName: user.firstName, setupToken: setup.token });
    setupEmailSent = delivery.sent;
    setupUrl = delivery.setupUrl;
  } catch (err) {
    await Agent.deleteOne({ _id: agent._id });
    await User.deleteOne({ _id: user._id });
    throw new AppError(502, 'SETUP_EMAIL_FAILED', 'The agent account could not be created because the setup email could not be sent.');
  }

  await auditLog({
    actorUserId,
    action: 'AGENT_CREATED',
    resourceType: 'Agent',
    resourceId: idOf(agent),
    newData: { role: body.role, agentCode: agent.agentCode, setupEmailSent },
    requestId,
  });
  const populated = await Agent.findById(agent._id).populate('userId', 'firstName lastName phone email role status').populate('provinceId', 'name code');
  const shaped = shapeAgent(populated);
  return {
    ...shaped,
    setupEmailSent,
    ...(env.NODE_ENV !== 'production' && setupUrl ? { setupUrl } : {}),
  };
}

export async function updateAgentStatus(id: string, body: any, actorUserId: string, requestId?: string): Promise<AdminAgentDTO> {
  const agent = await Agent.findById(id).populate('userId');
  if (!agent) throw new AppError(404, 'AGENT_NOT_FOUND', 'Agent not found.');

  const user = await User.findById((agent as any).userId?._id ?? (agent as any).userId);
  if (!user) throw new AppError(409, 'AGENT_USER_NOT_FOUND', 'The agent user account could not be found.');
  if (body.status === 'ACTIVE' && user.deletedAt) throw new AppError(409, 'USER_DELETED', 'A deleted user cannot be reactivated.');

  const previous = { status: agent.status, userStatus: user.status };
  (agent as any).status = body.status;
  (agent as any).statusReason = body.reason;
  (agent as any).statusChangedAt = new Date();
  (agent as any).statusChangedBy = actorUserId;
  user.status = body.status === 'ACTIVE' ? 'ACTIVE' : 'SUSPENDED';
  await Promise.all([agent.save(), user.save()]);

  await auditLog({
    actorUserId,
    action: 'AGENT_STATUS_UPDATED',
    resourceType: 'Agent',
    resourceId: id,
    oldData: previous,
    newData: { status: body.status, reason: body.reason },
    requestId,
  });
  const populated = await Agent.findById(id).populate('userId', 'firstName lastName phone email role status').populate('provinceId', 'name code');
  return shapeAgent(populated);
}

export async function setAgentVerification(
  id: string,
  body: { status: 'VERIFIED' | 'NOT_VERIFIED'; note?: string; reason?: string },
  actorUserId: string,
  requestId?: string,
): Promise<AdminAgentDTO> {
  const agent = await Agent.findById(id);
  if (!agent) throw new AppError(404, 'AGENT_NOT_FOUND', 'Agent not found.');

  /* Revoking or rejecting an agent without a reason leaves them with nothing to act on. */
  const reason = typeof body.reason === 'string' ? body.reason.trim() : '';
  if (body.status === 'NOT_VERIFIED' && !reason) {
    throw new AppError(400, 'REJECTION_REASON_REQUIRED', 'Explain why the agent is not verified.');
  }

  const previous = { verificationStatus: agent.verificationStatus };
  (agent as any).verificationStatus = body.status;
  (agent as any).verificationNote = body.status === 'VERIFIED' ? body.note : reason;
  (agent as any).verifiedAt = body.status === 'VERIFIED' ? new Date() : undefined;
  (agent as any).verifiedBy = body.status === 'VERIFIED' ? actorUserId : undefined;
  await agent.save();

  await auditLog({
    actorUserId,
    action: body.status === 'VERIFIED' ? 'AGENT_VERIFIED' : 'AGENT_VERIFICATION_REVOKED',
    resourceType: 'Agent',
    resourceId: id,
    oldData: previous,
    newData: { verificationStatus: body.status, note: body.note, reason: reason || undefined },
    requestId,
  });

  /* The agent owns the outcome of their own verification review. */
  await notifyUser(String(agent.userId), {
    type: 'VERIFICATION_COMPLETED',
    title: body.status === 'VERIFIED' ? 'You are verified' : 'Verification was rejected',
    message:
      body.status === 'VERIFIED'
        ? 'Your agent account has been verified by the IMMO BURUNDI team.'
        : `Your agent verification was not approved: ${reason}`,
    data: { agentId: id, status: body.status, reason: reason || undefined },
  });

  const populated = await Agent.findById(id).populate('userId', 'firstName lastName phone email role status').populate('provinceId', 'name code');
  return shapeAgent(populated);
}

export async function listProperties(query: AdminListQuery) {
  const { page, pageSize, skip } = parsePagination(query);
  const filter: Record<string, any> = { deletedAt: null };
  if (query.status) filter.status = query.status;
  if (query.listingType) filter.listingType = query.listingType;
  if (query.agentId) filter.agentId = query.agentId;
  if (query.q) {
    const rx = new RegExp(escapeRegex(query.q), 'i');
    filter.$or = [{ title: rx }, { propertyId: rx }, { description: rx }];
  }
  const [items, total] = await Promise.all([
    Property.find(filter).sort({ createdAt: -1 }).skip(skip).limit(pageSize).populate(PROPERTY_POPULATE as any),
    Property.countDocuments(filter),
  ]);
  return { items: (items as any[]).map(shapeProperty), meta: paginationMeta(page, pageSize, total) };
}

export async function listBookings(query: AdminListQuery) {
  const { page, pageSize, skip } = parsePagination(query);
  const filter: Record<string, any> = {};
  const and: Record<string, any>[] = [];
  if (query.status) filter.status = query.status;
  if (query.q) {
    const rx = new RegExp(escapeRegex(query.q), 'i');
    and.push({ $or: [{ bookingReference: rx }, { notes: rx }] });
  }
  if (query.propertyId) {
    const property = await Property.findOne(propertyIdFilter(query.propertyId)).select('_id').lean();
    if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
    const sessions = await VisitSession.find({ propertyId: property._id }).select('_id').lean();
    and.push({ $or: [{ propertyId: property._id }, { visitSessionId: { $in: sessions.map((session) => session._id) } }] });
  }
  if (query.agentId) {
    const properties = await Property.find({ agentId: query.agentId }).select('_id').lean();
    const propertyIds = properties.map((property) => property._id);
    const sessions = await VisitSession.find({ propertyId: { $in: propertyIds } }).select('_id').lean();
    and.push({ $or: [{ propertyId: { $in: propertyIds } }, { visitSessionId: { $in: sessions.map((session) => session._id) } }] });
  }
  if (and.length) filter.$and = and;
  const [items, total] = await Promise.all([
    VisitBooking.find(filter).sort({ createdAt: -1 }).skip(skip).limit(pageSize).populate(BOOKING_POPULATE as any),
    VisitBooking.countDocuments(filter),
  ]);
  return { items: (items as any[]).map(shapeBooking), meta: paginationMeta(page, pageSize, total) };
}

export async function updateBooking(id: string, status: string, req: Request): Promise<AdminBookingDTO> {
  await updateBookingStatus(id, status, req);
  const booking = await VisitBooking.findById(id).populate(BOOKING_POPULATE as any);
  if (!booking) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
  return shapeBooking(booking);
}

export async function listRequests(query: AdminListQuery) {
  const { page, pageSize, skip } = parsePagination(query);
  const filter: Record<string, any> = {};
  const conditions: Record<string, any>[] = [];
  if (query.status) filter.status = query.status;
  if (query.q) {
    const rx = new RegExp(escapeRegex(query.q), 'i');
    conditions.push({ $or: [{ subject: rx }, { message: rx }] });
  }
  if (query.propertyId) {
    const property = await Property.findOne(propertyIdFilter(query.propertyId)).select('_id').lean();
    if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
    conditions.push({ propertyId: property._id });
  }
  if (query.agentId) {
    const properties = await Property.find({ agentId: query.agentId }).select('_id').lean();
    conditions.push({ propertyId: { $in: properties.map((property) => property._id) } });
  }
  const saleProperties = await Property.find({ listingType: { $in: SALE_LISTING_TYPES }, deletedAt: null }).select('_id').lean();
  conditions.push({ propertyId: { $in: saleProperties.map((property: any) => property._id) } });
  if (conditions.length) filter.$and = conditions;
  const [items, total] = await Promise.all([
    Enquiry.find(filter).sort({ createdAt: -1 }).skip(skip).limit(pageSize).populate(REQUEST_POPULATE as any),
    Enquiry.countDocuments(filter),
  ]);
  return { items: (items as any[]).map(shapeRequest), meta: paginationMeta(page, pageSize, total) };
}

export async function updateRequestStatus(id: string, status: string, req: Request): Promise<AdminRequestDTO> {
  await setEnquiryStatus(id, status, req);
  const enquiry = await Enquiry.findById(id).populate(REQUEST_POPULATE as any);
  if (!enquiry) throw new AppError(404, 'ENQUIRY_NOT_FOUND', 'Enquiry not found.');
  return shapeRequest(enquiry);
}
