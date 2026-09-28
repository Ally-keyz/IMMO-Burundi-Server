import { Types } from 'mongoose';
import { Request } from 'express';
import { AppError } from '../../middleware/errorHandler.js';
import { VisitSession } from '../../models/visitSession.model.js';
import { VisitBooking } from '../../models/visitBooking.model.js';
import { Property } from '../../models/property.model.js';
import { Agent } from '../../models/agent.model.js';
import { generateVisitBookingRef } from '../../helpers/codeGenerators.js';
import { auditLog } from '../../helpers/auditLog.js';
import { agentUserIdForProperty, notifyUser, notifyUsers } from '../../helpers/notify.js';
import { isAdmin } from '../../helpers/authz.js';

/**
 * Tells the listing's agent/owner about a new visit request and confirms to the
 * customer. No-ops quietly when the property has no resolvable recipient.
 */
async function notifyVisitBooking(booking: any, property: any, bookingReference: string) {
  const propertyId = String(property?._id ?? booking?.propertyId ?? '');
  const title = property?.title ?? 'a property';
  const recipients = await notifyTargetsForProperty(property);

  await notifyUsers(recipients, {
    type: 'NEW_VISIT_BOOKING',
    title: 'New visit request',
    message: `A visit was requested for "${title}".`,
    data: { bookingId: String(booking?._id ?? ''), propertyId, bookingReference },
  });

  await notifyUser(booking?.userId, {
    type: 'SYSTEM',
    title: 'Visit requested',
    message: `Your visit request for "${title}" was sent. Reference ${bookingReference}.`,
    data: { bookingId: String(booking?._id ?? ''), propertyId, bookingReference },
  });
}

/** Everyone who should be told about activity on a property: owner, landlord, agent. */
async function notifyTargetsForProperty(property: any): Promise<string[]> {
  if (!property) return [];
  const agentUserId = await agentUserIdForProperty(property);
  return [property.ownerUserId, property.landlordUserId, property.createdBy, agentUserId]
    .filter(Boolean)
    .map((v: any) => String(v?._id ?? v));
}

function idFilter(id: string) {
  return Types.ObjectId.isValid(id) ? { $or: [{ _id: id }, { propertyId: id }] } : { propertyId: id };
}

async function canManageProperty(property: any, req: Request): Promise<boolean> {
  const userId = req.user!.sub;
  if (isAdmin(req)) return true;
  if (String(property.createdBy) === userId) return true;
  if (String(property.ownerUserId) === userId) return true;
  if (String(property.landlordUserId) === userId) return true;
  const agent = await Agent.findOne({ userId }).lean();
  return Boolean(agent && String(property.agentId) === String((agent as any)._id));
}

export async function createSession(req: Request, body: any) {
  const property = await Property.findOne(idFilter(body.propertyId));
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  if (!(await canManageProperty(property, req))) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot create visit sessions for this property.');
  }

  const session = await VisitSession.create({
    propertyId: property._id,
    date: body.date,
    startTime: body.startTime,
    endTime: body.endTime,
    capacity: body.capacity,
    bookingDeadline: body.bookingDeadline,
    status: 'SCHEDULED',
    createdBy: req.user!.sub,
    timezone: body.timezone ?? 'Africa/Bujumbura',
  });

  await auditLog({
    actorUserId: req.user!.sub,
    action: 'VISIT_SESSION_CREATED',
    resourceType: 'VisitSession',
    resourceId: String(session._id),
    newData: { propertyId: String(property._id), date: body.date },
    requestId: req.requestId,
  });

  return session;
}

export async function listSessions(propertyId: string) {
  const property = await Property.findOne(idFilter(propertyId)).lean();
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');

  const sessions = await VisitSession.find({
    propertyId: (property as any)._id,
    status: 'SCHEDULED',
    bookingDeadline: { $gt: new Date() },
  })
    .sort({ date: 1, startTime: 1 })
    .lean();

  return sessions.map((s: any) => ({
    ...s,
    capacityRemaining: Math.max(0, (s.capacity ?? 0) - (s.bookedCount ?? 0)),
    isFull: (s.bookedCount ?? 0) >= (s.capacity ?? 0),
  }));
}

/**
 * Atomic reservation — Backend Spec §102.
 * The capacity guard is enforced in a single findOneAndUpdate so concurrent
 * requests can never oversell a session.
 *
 * Two booking modes:
 *  1. `visitSessionId`  → book against a scheduled session (atomic capacity).
 *  2. `propertyId`      → any-time request: choose a preferred date/time.
 */
export async function bookVisit(userId: string, body: any) {
  const sessionId = body.visitSessionId;
  const propertyId = body.propertyId;

  if (!sessionId && !propertyId) {
    throw new AppError(400, 'BOOKING_TARGET_REQUIRED', 'provide visitSessionId or propertyId.');
  }

  if (!sessionId) {
    const property = await Property.findOne(idFilter(propertyId)).lean();
    if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');

    const existing = await VisitBooking.findOne({
      propertyId: (property as any)._id,
      userId,
      status: { $nin: ['CANCELLED', 'NO_SHOW'] },
    }).lean();
    if (existing) {
      throw new AppError(409, 'ALREADY_BOOKED', 'You already have a visit request for this property.');
    }

    const bookingReference = await generateVisitBookingRef();
    const booking = await VisitBooking.create({
      propertyId: (property as any)._id,
      userId,
      bookingReference,
      preferredDate: body.preferredDate,
      startTime: body.startTime,
      numberOfPeople: body.numberOfPeople ?? 1,
      notes: body.notes,
      status: 'PENDING',
    });

    await auditLog({
      actorUserId: userId,
      action: 'VISIT_BOOKED',
      resourceType: 'VisitBooking',
      resourceId: String(booking._id),
      newData: { propertyId: String((property as any)._id), bookingReference },
    });

    await notifyVisitBooking(booking, property as any, bookingReference);

    return booking;
  }

  const existing = await VisitBooking.findOne({
    visitSessionId: sessionId,
    userId,
    status: { $nin: ['CANCELLED', 'NO_SHOW'] },
  }).lean();
  if (existing) {
    throw new AppError(409, 'ALREADY_BOOKED', 'You already have a booking for this session.');
  }

  const session = await VisitSession.findOneAndUpdate(
    {
      _id: sessionId,
      status: 'SCHEDULED',
      bookingDeadline: { $gt: new Date() },
      $expr: { $lt: ['$bookedCount', '$capacity'] },
    },
    { $inc: { bookedCount: 1 } },
    { new: true },
  );

  if (!session) {
    throw new AppError(
      409,
      'SESSION_UNAVAILABLE',
      'This visit session is full, closed or no longer accepting bookings.',
    );
  }

  try {
    const bookingReference = await generateVisitBookingRef();
    const booking = await VisitBooking.create({
      visitSessionId: session._id,
      propertyId: session.propertyId,
      userId,
      bookingReference,
      numberOfPeople: body.numberOfPeople ?? 1,
      notes: body.notes,
      status: 'PENDING',
    });

    await auditLog({
      actorUserId: userId,
      action: 'VISIT_BOOKED',
      resourceType: 'VisitBooking',
      resourceId: String(booking._id),
      newData: { visitSessionId: String(session._id), bookingReference },
    });

    const property = await Property.findById(session.propertyId).lean();
    await notifyVisitBooking(booking, property as any, bookingReference);

    return booking;
  } catch (err) {
    await VisitSession.updateOne({ _id: session._id }, { $inc: { bookedCount: -1 } });
    throw err;
  }
}

export async function cancelBooking(bookingId: string, userId: string, requestId?: string) {
  const booking = await VisitBooking.findById(bookingId);
  if (!booking) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
  if (String((booking as any).userId) !== userId) {
    throw new AppError(403, 'FORBIDDEN', 'You can only cancel your own bookings.');
  }
  if ((booking as any).status === 'CANCELLED') return booking;

  (booking as any).status = 'CANCELLED';
  (booking as any).cancelledAt = new Date();
  await booking.save();

  await VisitSession.updateOne(
    { _id: (booking as any).visitSessionId, bookedCount: { $gt: 0 } },
    { $inc: { bookedCount: -1 } },
  );

  await auditLog({
    actorUserId: userId,
    action: 'VISIT_BOOKING_CANCELLED',
    resourceType: 'VisitBooking',
    resourceId: String(booking._id),
    requestId,
  });

  return booking;
}

export async function myBookings(userId: string, query: any) {
  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const skip = (page - 1) * pageSize;
  const filter: Record<string, any> = { userId };
  if (query.status) filter.status = query.status;

  const [items, total] = await Promise.all([
    VisitBooking.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .populate({ path: 'visitSessionId', populate: { path: 'propertyId', select: 'title propertyId media' } })
      .populate('propertyId', 'title propertyId media'),
    VisitBooking.countDocuments(filter),
  ]);

  return {
    items,
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}

/** Called by an owner/agent to confirm or complete a booking. */
export async function updateBookingStatus(bookingId: string, status: string, req: Request) {
  const booking: any = await VisitBooking.findById(bookingId).populate('visitSessionId');
  if (!booking) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');

  const session: any = booking.visitSessionId;
  const property = await Property.findById(session?.propertyId ?? booking.propertyId).lean();
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  if (!(await canManageProperty(property, req))) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot update this booking.');
  }

  booking.status = status;
  if (status === 'CONFIRMED') booking.confirmedAt = new Date();
  if (status === 'CANCELLED') booking.cancelledAt = new Date();
  await booking.save();

  if (session && status === 'CANCELLED') {
    await VisitSession.updateOne(
      { _id: session._id, bookedCount: { $gt: 0 } },
      { $inc: { bookedCount: -1 } },
    );
  }

  await auditLog({
    actorUserId: req.user!.sub,
    action: 'VISIT_BOOKING_STATUS_UPDATED',
    resourceType: 'VisitBooking',
    resourceId: String(booking._id),
    newData: { status },
    requestId: req.requestId,
  });

  /* The customer is the one waiting on this decision. */
  await notifyUser(booking.userId, {
    type: status === 'CONFIRMED' ? 'VISIT_CONFIRMED' : status === 'CANCELLED' ? 'VISIT_CANCELLED' : 'SYSTEM',
    title:
      status === 'CONFIRMED'
        ? 'Visit confirmed'
        : status === 'CANCELLED'
          ? 'Visit cancelled'
          : 'Visit updated',
    message: `Your visit for "${property.title}" is now ${status}.`,
    data: { bookingId: String(booking._id), propertyId: String(property._id), status },
  });

  return booking;
}

/** Owner/agent view — all bookings (session or any-time) for one property. */
export async function propertyBookings(req: Request, propertyId: string, query: any) {
  const property = await Property.findOne(idFilter(propertyId)).lean();
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  if (!(await canManageProperty(property, req))) {
    throw new AppError(403, 'FORBIDDEN', 'You cannot view bookings for this property.');
  }

  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const skip = (page - 1) * pageSize;
  const filter: Record<string, any> = { propertyId: (property as any)._id };
  if (query.status) filter.status = query.status;

  const [items, total] = await Promise.all([
    VisitBooking.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .populate('userId', 'firstName lastName phone email photoUrl')
      .populate('visitSessionId', 'date startTime endTime'),
    VisitBooking.countDocuments(filter),
  ]);

  return {
    items,
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}
