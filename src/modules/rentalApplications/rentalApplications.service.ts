import { Types } from 'mongoose';
import { Request } from 'express';
import { AppError } from '../../middleware/errorHandler.js';
import { RentalApplication } from '../../models/rentalApplication.model.js';
import { Property } from '../../models/property.model.js';
import { Agent } from '../../models/agent.model.js';
import '../../models/users.model.js';
import { generateApplicationCode } from '../../helpers/codeGenerators.js';
import { auditLog } from '../../helpers/auditLog.js';
import { agentUserIdForProperty, notifyUser, notifyUsers } from '../../helpers/notify.js';
import { isAdmin } from '../../helpers/authz.js';

/** Owner, landlord and agent all need to see new applications for a listing. */
async function notifyTargetsForProperty(property: any): Promise<string[]> {
  if (!property) return [];
  const agentUserId = await agentUserIdForProperty(property);
  return [property.ownerUserId, property.landlordUserId, property.createdBy, agentUserId]
    .filter(Boolean)
    .map((v: any) => String(v?._id ?? v));
}

const LANDLORD_STATUSES = ['UNDER_REVIEW', 'SHORTLISTED', 'ACCEPTED', 'REJECTED'];

function idFilter(id: string) {
  return Types.ObjectId.isValid(id) ? { $or: [{ _id: id }, { propertyId: id }] } : { propertyId: id };
}

async function assertLandlord(property: any, req: Request): Promise<void> {
  const userId = req.user!.sub;
  if (isAdmin(req)) return;
  if (String(property.ownerUserId) === userId || String(property.landlordUserId) === userId) return;
  if (String(property.createdBy) === userId) return;
  const agent = await Agent.findOne({ userId }).lean();
  if (agent && String(property.agentId) === String((agent as any)._id)) return;
  throw new AppError(403, 'FORBIDDEN', 'You cannot view applications for this property.');
}

export async function createApplication(userId: string, body: any) {
  const property: any = await Property.findOne(idFilter(body.propertyId));
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  if (!['RENT', 'LEASE'].includes(property.listingType)) {
    throw new AppError(400, 'NOT_A_RENTAL', 'Applications can only be submitted for rental properties.');
  }

  const applicationCode = await generateApplicationCode();
  const application = await RentalApplication.create({
    propertyId: property._id,
    applicantId: userId,
    applicationCode,
    fullName: body.fullName,
    phone: body.phone,
    email: body.email,
    address: body.address,
    totalOccupants: body.totalOccupants,
    numberOfChildren: body.numberOfChildren,
    occupation: body.occupation,
    advanceAvailable: body.advanceAvailable,
    moveInDate: body.moveInDate,
    status: 'SUBMITTED',
  });

  await auditLog({
    actorUserId: userId,
    action: 'RENTAL_APPLICATION_CREATED',
    resourceType: 'RentalApplication',
    resourceId: String(application._id),
    newData: { propertyId: String(property._id), applicationCode },
  });

  await notifyUsers(await notifyTargetsForProperty(property), {
    type: 'NEW_RENTAL_APPLICATION',
    title: 'New rental application',
    message: `Someone applied to rent "${property.title}".`,
    data: { applicationId: String(application._id), propertyId: String(property._id), applicationCode },
  });

  return application;
}

export async function myApplications(userId: string, query: any) {
  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const skip = (page - 1) * pageSize;
  const filter: Record<string, any> = { applicantId: userId };
  if (query.status) filter.status = query.status;

  const [items, total] = await Promise.all([
    RentalApplication.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .populate({ path: 'propertyId', select: 'title propertyId price media listingType' }),
    RentalApplication.countDocuments(filter),
  ]);

  return {
    items,
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}

export async function propertyApplications(propertyId: string, req: Request) {
  const property: any = await Property.findOne(idFilter(propertyId));
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  await assertLandlord(property, req);

  // Rule 12 — a landlord only ever sees applications for their own property.
  return RentalApplication.find({ propertyId: property._id })
    .select('+landlordNotes')
    .sort({ createdAt: -1 })
    .populate({ path: 'applicantId', select: 'firstName lastName phone email' });
}

export async function updateApplication(id: string, req: Request, body: any) {
  const application: any = await RentalApplication.findById(id).select('+landlordNotes');
  if (!application) throw new AppError(404, 'APPLICATION_NOT_FOUND', 'Application not found.');

  const property: any = await Property.findById(application.propertyId);
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');

  const userId = req.user!.sub;
  const isApplicant = String(application.applicantId) === userId;
  const status = body.status as string;

  if (isApplicant) {
    if (status !== 'WITHDRAWN') {
      throw new AppError(403, 'FORBIDDEN', 'Applicants may only withdraw their own application.');
    }
    if (['ACCEPTED', 'REJECTED'].includes(application.status)) {
      throw new AppError(409, 'INVALID_STATUS_TRANSITION', 'This application can no longer be withdrawn.');
    }
  } else {
    await assertLandlord(property, req);
    if (!LANDLORD_STATUSES.includes(status)) {
      throw new AppError(400, 'INVALID_STATUS', `Landlords may set: ${LANDLORD_STATUSES.join(', ')}.`);
    }
  }

  const oldStatus = application.status;
  application.status = status;
  if (body.landlordNotes !== undefined) application.landlordNotes = body.landlordNotes;
  await application.save();

  await auditLog({
    actorUserId: userId,
    action: 'RENTAL_APPLICATION_STATUS_UPDATED',
    resourceType: 'RentalApplication',
    resourceId: String(application._id),
    oldData: { status: oldStatus },
    newData: { status },
    requestId: req.requestId,
  });

  /* Applicant hears about every decision on their application. */
  await notifyUser(application.applicantId, {
    type: 'RENTAL_APPLICATION_UPDATED',
    title: 'Application updated',
    message: `Your application for "${property.title}" is now ${status}.`,
    data: { applicationId: String(application._id), propertyId: String(property._id), status },
  });

  return application;
}
