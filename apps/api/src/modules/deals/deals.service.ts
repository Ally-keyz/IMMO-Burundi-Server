import { Request } from 'express';
import { AppError } from '../../middleware/errorHandler.js';
import { Enquiry } from '../../models/enquiry.model.js';
import { VisitBooking } from '../../models/visitBooking.model.js';
import { Property } from '../../models/property.model.js';
import { Agent } from '../../models/agent.model.js';
import { Payment } from '../../models/payment.model.js';
import { auditLog } from '../../helpers/auditLog.js';
import { isAdmin } from '../../helpers/authz.js';
import { generatePaymentReference } from '../../helpers/codeGenerators.js';
import { markPropertySoldFromPayment } from '../properties/properties.service.js';

const PROPERTY_MANAGER_FIELDS = 'title listingType price status ownerUserId landlordUserId createdBy agentId';

/**
 * Payments are settled out-of-band (cash / mobile money handled by the agent),
 * so the dashboard only needs a single "mark as paid" action. This records a
 * completed Payment for the audit trail and takes the property off the market.
 */

async function canManageProperty(property: any, req: Request): Promise<boolean> {
  const userId = req.user!.sub;
  if (isAdmin(req)) return true;
  if (String(property.createdBy) === userId) return true;
  if (String(property.ownerUserId) === userId) return true;
  if (String(property.landlordUserId) === userId) return true;
  const agent = await Agent.findOne({ userId }).lean();
  return Boolean(agent && String(property.agentId) === String((agent as any)._id));
}

function categoryForListingType(listingType: string | undefined): 'SALE_COMMISSION' | 'RENTAL_COMMISSION' | 'OTHER' {
  if (listingType === 'RENT' || listingType === 'LEASE' || listingType === 'INVESTMENT') return 'RENTAL_COMMISSION';
  if (listingType === 'SALE' || listingType === 'AUCTION') return 'SALE_COMMISSION';
  return 'OTHER';
}

async function settle(
  req: Request,
  params: {
    entity: any;
    relatedEntityType: 'Enquiry' | 'VisitBooking';
    payerUserId: string;
    property: any;
  },
) {
  const { entity, relatedEntityType, payerUserId, property } = params;

  const amount = Number(property?.price?.amount);
  const currency = String(property?.price?.currency ?? 'BIF');
  if (!Number.isFinite(amount) || amount <= 0) {
    throw new AppError(
      400,
      'PROPERTY_PRICE_MISSING',
      'Add a price to the listing before marking the deal as paid.',
    );
  }

  const category = categoryForListingType(property.listingType);
  const paymentReference = await generatePaymentReference(category);

  const payment = await Payment.create({
    payerId: payerUserId,
    amount,
    currency,
    paymentReference,
    paymentMethod: 'MANUAL',
    category,
    status: 'COMPLETED',
    relatedEntityType,
    relatedEntityId: entity._id,
    confirmedBy: req.user!.sub,
    paidAt: new Date(),
  });

  const paidAt = new Date();
  entity.paidAt = paidAt;
  entity.paymentId = payment._id;
  await entity.save();

  await auditLog({
    actorUserId: req.user!.sub,
    action: 'DEAL_MARKED_PAID',
    resourceType: relatedEntityType,
    resourceId: String(entity._id),
    newData: {
      paymentReference,
      amount,
      currency,
      propertyId: String(property._id),
    },
    requestId: req.requestId,
  });

  const sold = await markPropertySoldFromPayment({
    propertyId: String(property._id),
    paymentReference,
    amount,
    currency,
    payerPhone: '',
    linkId: String(entity._id),
    actorUserId: req.user!.sub,
    requestId: req.requestId,
  });

  return {
    paymentReference,
    amount,
    currency,
    paidAt,
    propertyMarkedSold: Boolean(sold),
  };
}

export async function markDealPaid(req: Request, kindRaw: unknown, idRaw: unknown) {
  const kind = String(kindRaw ?? '');
  const id = String(idRaw ?? '');
  if (kind !== 'booking' && kind !== 'enquiry') {
    throw new AppError(400, 'INVALID_DEAL_KIND', "kind must be 'booking' or 'enquiry'.");
  }
  if (!id) throw new AppError(400, 'DEAL_ID_REQUIRED', 'Provide the deal id.');

  if (kind === 'enquiry') {
    const enquiry: any = await Enquiry.findById(id).populate({
      path: 'propertyId',
      select: PROPERTY_MANAGER_FIELDS,
    });
    if (!enquiry) throw new AppError(404, 'ENQUIRY_NOT_FOUND', 'Enquiry not found.');
    const property: any = enquiry.propertyId;
    if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
    if (!(await canManageProperty(property, req))) {
      throw new AppError(403, 'FORBIDDEN', 'You can only settle deals on your own properties.');
    }
    if (enquiry.paidAt) throw new AppError(409, 'DEAL_ALREADY_PAID', 'This deal is already marked as paid.');

    return settle(req, {
      entity: enquiry,
      relatedEntityType: 'Enquiry',
      payerUserId: String(enquiry.senderUserId),
      property,
    });
  }

  const booking: any = await VisitBooking.findById(id);
  if (!booking) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
  if (!booking.propertyId) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  const property: any = await Property.findById(booking.propertyId).select(PROPERTY_MANAGER_FIELDS);
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  if (!(await canManageProperty(property, req))) {
    throw new AppError(403, 'FORBIDDEN', 'You can only settle deals on your own properties.');
  }
  if (booking.paidAt) throw new AppError(409, 'DEAL_ALREADY_PAID', 'This deal is already marked as paid.');

  return settle(req, {
    entity: booking,
    relatedEntityType: 'VisitBooking',
    payerUserId: String(booking.userId),
    property,
  });
}
