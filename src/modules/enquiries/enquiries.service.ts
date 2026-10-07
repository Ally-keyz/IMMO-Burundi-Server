import { Types } from 'mongoose';
import { Request } from 'express';
import { AppError } from '../../middleware/errorHandler.js';
import { Enquiry } from '../../models/enquiry.model.js';
import { Property } from '../../models/property.model.js';
import { Agent } from '../../models/agent.model.js';
import '../../models/users.model.js';
import { auditLog } from '../../helpers/auditLog.js';
import { notifyUser } from '../../helpers/notify.js';
import { isAdmin } from '../../helpers/authz.js';

function idFilter(id: string) {
  return Types.ObjectId.isValid(id) ? { $or: [{ _id: id }, { propertyId: id }] } : { propertyId: id };
}

export async function createEnquiry(userId: string, body: any, requestId?: string) {
  const property: any = await Property.findOne(idFilter(body.propertyId)).populate('agentId');
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');

  const agent: any = property.agentId;
  const agentUserId = agent?.userId ? String(agent.userId) : undefined;
  const recipientUserId =
    property.ownerUserId ?? property.landlordUserId ?? agentUserId ?? undefined;

  const enquiry = await Enquiry.create({
    propertyId: property._id,
    senderUserId: userId,
    recipientUserId,
    agentId: agent?._id,
    subject: body.subject,
    message: body.message,
    status: 'NEW',
  });

  await Property.updateOne({ _id: property._id }, { $inc: { 'stats.enquiries': 1 } });

  /* The agent/owner gets told about the new request; the customer gets a receipt. */
  await notifyUser(recipientUserId, {
    type: 'NEW_ENQUIRY',
    title: 'New request received',
    message: `Someone is interested in "${property.title}".`,
    data: { enquiryId: String(enquiry._id), propertyId: String(property._id), subject: body.subject },
  });
  await notifyUser(userId, {
    type: 'SYSTEM',
    title: 'Request sent',
    message: `Your request about "${property.title}" was sent to the agent.`,
    data: { enquiryId: String(enquiry._id), propertyId: String(property._id) },
  });

  await auditLog({
    actorUserId: userId,
    action: 'ENQUIRY_CREATED',
    resourceType: 'Enquiry',
    resourceId: String(enquiry._id),
    newData: { propertyId: String(property._id) },
    requestId,
  });

  return enquiry;
}

export async function listMyEnquiries(userId: string, query: any) {
  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const skip = (page - 1) * pageSize;
  const filter: Record<string, any> = { senderUserId: userId };
  if (query.status) filter.status = query.status;

  const [items, total] = await Promise.all([
    Enquiry.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .populate({ path: 'propertyId', select: 'title propertyId price media' })
      /* Needed so the client can offer a direct WhatsApp/call button per request. */
      .populate({ path: 'agentId', populate: { path: 'userId', select: 'firstName lastName phone email photoUrl' } }),
    Enquiry.countDocuments(filter),
  ]);

  return {
    items,
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}

export async function listPropertyEnquiries(propertyId: string, req: Request) {
  const property: any = await Property.findOne(idFilter(propertyId));
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');

  const userId = req.user!.sub;
  const agent = await Agent.findOne({ userId }).lean();
  const allowed =
    isAdmin(req) ||
    String(property.ownerUserId) === userId ||
    String(property.landlordUserId) === userId ||
    String(property.createdBy) === userId ||
    (agent && String(property.agentId) === String((agent as any)._id));
  if (!allowed) throw new AppError(403, 'FORBIDDEN', 'You cannot view enquiries for this property.');

  return Enquiry.find({ propertyId: property._id })
    .sort({ createdAt: -1 })
    .populate({ path: 'senderUserId', select: 'firstName lastName phone' });
}

export async function respondToEnquiry(id: string, req: Request) {
  const enquiry: any = await Enquiry.findById(id);
  if (!enquiry) throw new AppError(404, 'ENQUIRY_NOT_FOUND', 'Enquiry not found.');

  const userId = req.user!.sub;
  if (!isAdmin(req) && String(enquiry.recipientUserId) !== userId) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot respond to this enquiry.');
  }

  enquiry.status = 'RESPONDED';
  await enquiry.save();

  await notifyUser(enquiry.senderUserId, {
    type: 'NEW_MESSAGE',
    title: 'The agent replied',
    message: 'Your request has been answered. Open it to read the reply.',
    data: { enquiryId: String(enquiry._id), propertyId: String(enquiry.propertyId?._id ?? enquiry.propertyId) },
  });

  await auditLog({
    actorUserId: userId,
    action: 'ENQUIRY_RESPONDED',
    resourceType: 'Enquiry',
    resourceId: String(enquiry._id),
    requestId: req.requestId,
  });

  return enquiry;
}

/**
 * "Bookings & Inquiries" inbox — every enquiry sent to a property this agent
 * manages (recipient = the agent's account, or agent record match, or created/owned).
 */
export async function listAgentInbox(req: Request, query: any) {
  const userId = req.user!.sub;
  const agent = await Agent.findOne({ userId }).lean();

  const props = await Property.find({
    $or: [
      { createdBy: userId },
      { ownerUserId: userId },
      { landlordUserId: userId },
      ...(agent ? [{ agentId: (agent as any)._id }] : []),
    ],
  })
    .select('_id title propertyId price media listingType')
    .lean();

  const propertyIds = props.map((p) => p._id);
  if (propertyIds.length === 0) return [];

  const filter: Record<string, any> = { propertyId: { $in: propertyIds } };
  if (query.status) filter.status = query.status;

  const enquiries = await Enquiry.find(filter)
    .sort({ createdAt: -1 })
    .limit(Math.min(200, Number(query.limit) || 100))
    .populate({ path: 'senderUserId', select: 'firstName lastName phone email photoUrl' })
    .populate({ path: 'propertyId', select: 'title propertyId price media listingType' });

  const propById = new Map(props.map((p: any) => [String(p._id), p]));
  return enquiries.map((e: any) => ({
    ...e.toObject(),
    sender: e.senderUserId,
    property: e.propertyId ?? propById.get(String(e.propertyId)) ?? null,
  }));
}

/** Agent marks an enquiry deal-agreed (enables "Send payment link"). */
export async function setEnquiryStatus(id: string, status: string, req: Request) {
  const enquiry: any = await Enquiry.findById(id);
  if (!enquiry) throw new AppError(404, 'ENQUIRY_NOT_FOUND', 'Enquiry not found.');

  const userId = req.user!.sub;
  if (!isAdmin(req) && String(enquiry.recipientUserId) !== userId) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot update this enquiry.');
  }

  enquiry.status = status;
  await enquiry.save();

  await notifyUser(enquiry.senderUserId, {
    type: 'RENTAL_APPLICATION_UPDATED',
    title: 'Request updated',
    message: `Your request is now "${status}".`,
    data: { enquiryId: String(enquiry._id), propertyId: String(enquiry.propertyId?._id ?? enquiry.propertyId), status },
  });

  await auditLog({
    actorUserId: userId,
    action: 'ENQUIRY_STATUS_UPDATED',
    resourceType: 'Enquiry',
    resourceId: String(enquiry._id),
    newData: { status },
    requestId: req.requestId,
  });

  return enquiry;
}
