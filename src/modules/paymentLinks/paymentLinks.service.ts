import crypto from 'node:crypto';
import { Types } from 'mongoose';
import { Request } from 'express';
import { AppError } from '../../middleware/errorHandler.js';
import { PaymentLink } from '../../models/paymentLink.model.js';
import { Payment } from '../../models/payment.model.js';
import { Property } from '../../models/property.model.js';
import { Agent } from '../../models/agent.model.js';
import { User } from '../../models/users.model.js';
import '../../models/enquiry.model.js';
import '../../models/visitBooking.model.js';
import { auditLog } from '../../helpers/auditLog.js';
import { isAdmin } from '../../helpers/authz.js';
import { generatePaymentReference } from '../../helpers/codeGenerators.js';
import { markPropertySoldFromPayment } from '../properties/properties.service.js';
import { MOBILE_MONEY_PROVIDERS, type MobileMoneyProvider } from '@immo/shared-types';

const LINK_TTL_MS = 30 * 24 * 60 * 60 * 1000; // 30 days

/**
 * Normalises a Burundi mobile-money MSISDN to E.164 (+257XXXXXXXX).
 * Accepts 79 11 10 01, 25779111001, +257 79 111 001 and similar spacing.
 * Returns null when the subscriber part is not a valid Burundian mobile number.
 */
function normalizeMsisdn(raw: unknown): string | null {
  if (typeof raw !== 'string') return null;
  let digits = raw.replace(/[^\d+]/g, '');
  if (digits.startsWith('+')) digits = digits.slice(1);
  if (digits.startsWith('00')) digits = digits.slice(2);
  if (digits.startsWith('257')) digits = digits.slice(3);
  if (digits.startsWith('0')) digits = digits.slice(1);
  if (!/^\d{8}$/.test(digits)) return null;
  /* Burundian mobile ranges are 2x, 6x and 7x; 3x/4x/5x/8x/9x are landlines. */
  if (!/^[267]\d{7}$/.test(digits)) return null;
  return `+257${digits}`;
}

function resolveProvider(raw: unknown): MobileMoneyProvider {
  const value = String(raw ?? '').trim().toUpperCase();
  if (!(MOBILE_MONEY_PROVIDERS as readonly string[]).includes(value)) {
    throw new AppError(
      400,
      'UNSUPPORTED_PAYMENT_PROVIDER',
      'Choose a supported Burundi mobile money service.',
    );
  }
  return value as MobileMoneyProvider;
}

function newToken(): string {
  return crypto.randomBytes(24).toString('base64url');
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

function idFilter(id: string) {
  return Types.ObjectId.isValid(id) ? { $or: [{ _id: id }, { propertyId: id }] } : { propertyId: id };
}

/**
 * Agent creates a payment link for a specific requester on one of their
 * properties. The token is opaque; the binding lives server-side only.
 */
export async function createPaymentLink(req: Request, body: any) {
  const property: any = await Property.findOne(idFilter(body.propertyId));
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  if (!(await canManageProperty(property, req))) {
    throw new AppError(403, 'FORBIDDEN', 'You can only create payment links for your own properties.');
  }

  const requesterUserId = String(body.requesterUserId ?? '');
  const requester = await User.findById(requesterUserId).lean();
  if (!requester) throw new AppError(404, 'USER_NOT_FOUND', 'Requester account not found.');

  const amount = Number(body.amount);
  if (!Number.isFinite(amount) || amount <= 0) {
    throw new AppError(400, 'INVALID_AMOUNT', 'Provide a valid positive amount.');
  }
  const currency = body.currency ?? 'BIF';

  const agent = await Agent.findOne({ userId: req.user!.sub }).lean();

  const link = await PaymentLink.create({
    token: newToken(),
    createdByUserId: req.user!.sub,
    agentId: agent?._id,
    propertyId: property._id,
    requesterUserId,
    enquiryId: body.enquiryId || undefined,
    bookingId: body.bookingId || undefined,
    amount,
    currency,
    note: body.note,
    status: 'SENT', // the "Send payment link" action marks it as dispatched
    expiresAt: new Date(Date.now() + LINK_TTL_MS),
  });

  await auditLog({
    actorUserId: req.user!.sub,
    action: 'PAYMENT_LINK_SENT',
    resourceType: 'PaymentLink',
    resourceId: String(link._id),
    newData: { propertyId: String(property._id), requesterUserId, amount, currency },
    requestId: req.requestId,
  });

  return { ...link.toObject(), url: `/pay/${link.token}` };
}

/** Agent dashboard — all links created by this agent. */
export async function listAgentLinks(req: Request) {
  const userId = req.user!.sub;
  const agent = await Agent.findOne({ userId }).lean();

  const filter: Record<string, any> = { createdByUserId: userId };
  if (agent) filter.$or = [{ createdByUserId: userId }, { agentId: agent._id }];

  return PaymentLink.find(filter)
    .sort({ createdAt: -1 })
    .limit(100)
    .populate({ path: 'propertyId', select: 'title propertyId media listingType' })
    .populate({ path: 'requesterUserId', select: 'firstName lastName phone email' })
    .populate('paymentId');
}

/**
 * Anyone holding the token can resolve a link — the token is the credential, so
 * no account is required. A one-time OPENED marking is still recorded so the
 * agent can see that the buyer opened it.
 */
export async function resolvePaymentLink(req: Request, token: string) {
  const link: any = await PaymentLink.findOne({ token })
    .populate({ path: 'propertyId', select: 'title propertyId media listingType price cityName provinceName' })
    .populate({ path: 'requesterUserId', select: 'firstName lastName' });

  if (!link) throw new AppError(404, 'LINK_NOT_FOUND', 'This payment link is invalid or has been removed.');
  if (link.status === 'CANCELLED') {
    throw new AppError(400, 'LINK_CANCELLED', 'This payment link has been cancelled by the agent.');
  }
  if (link.status === 'EXPIRED' || (link.expiresAt && link.expiresAt < new Date())) {
    link.status = 'EXPIRED';
    await link.save();
    throw new AppError(400, 'LINK_EXPIRED', 'This payment link has expired.');
  }
  if (!link.openedAt) {
    link.openedAt = new Date();
    if (link.status === 'CREATED' || link.status === 'SENT') link.status = 'OPENED';
    await link.save();
  }

  const property = link.propertyId as any;
  const price = property?.price;
  return {
    token: link.token,
    reference: link._id,
    status: link.status,
    amount: link.amount,
    currency: link.currency,
    note: link.note,
    expiresAt: link.expiresAt,
    paidAt: link.paidAt,
    payee: link.requesterUserId
      ? { firstName: link.requesterUserId.firstName, lastName: link.requesterUserId.lastName }
      : null,
    property: property
      ? {
          title: property.title,
          propertyId: property.propertyId,
          listingType: property.listingType,
          thumbnail: property.media?.[0]?.thumbUrl ?? property.media?.[0]?.url ?? '',
          price: price?.amount ?? link.amount,
          currency: price?.currency ?? link.currency,
        }
      : null,
  };
}

/**
 * Requester completes the payment with their mobile money account. Creates a
 * real Payment record (category derived from the listing type) and flips the
 * link to PAID.
 *
 * NOTE: no mobile money aggregator is wired up yet, so the charge is recorded
 * rather than settled with the operator. Swap the Payment.create block for a
 * gateway call once operator credentials are available.
 */
export async function payPaymentLink(req: Request, token: string, body: any) {
  const link: any = await PaymentLink.findOne({ token }).populate({ path: 'propertyId', select: 'listingType title' });
  if (!link) throw new AppError(404, 'LINK_NOT_FOUND', 'This payment link is invalid or has been removed.');
  if (link.status === 'CANCELLED') throw new AppError(400, 'LINK_CANCELLED', 'This payment link has been cancelled by the agent.');
  if (link.status === 'EXPIRED' || (link.expiresAt && link.expiresAt < new Date())) {
    throw new AppError(400, 'LINK_EXPIRED', 'This payment link has expired.');
  }
  if (link.status === 'PAID') {
    throw new AppError(409, 'LINK_ALREADY_PAID', 'This payment link has already been paid.');
  }

  const listingType = link.propertyId?.listingType ?? 'SALE';
  const category =
    listingType === 'RENT' || listingType === 'LEASE' || listingType === 'INVESTMENT'
      ? 'RENTAL_COMMISSION'
      : listingType === 'SALE' || listingType === 'AUCTION'
        ? 'SALE_COMMISSION'
        : 'OTHER';

  const provider = resolveProvider(body.provider);
  const payerPhone = normalizeMsisdn(body.payerPhone);
  if (!payerPhone) {
    throw new AppError(
      400,
      'INVALID_MOBILE_MONEY_NUMBER',
      'Enter a valid Burundian mobile money number, for example 79 11 10 01.',
    );
  }

  const paymentReference = await generatePaymentReference(category);
  // payerId is a required FK. An anonymous payer has no user id, so the payment
  // is attributed to the account the link was issued to.
  const payerId = req.user?.sub ?? String(link.requesterUserId);
  const payment = await Payment.create({
    payerId,
    amount: link.amount,
    currency: link.currency,
    paymentReference,
    paymentMethod: 'MOBILE_MONEY',
    category,
    status: 'COMPLETED',
    relatedEntityType: 'PaymentLink',
    relatedEntityId: link._id,
    provider,
    payerPhone,
    providerTransactionId: `MM-${paymentReference}`,
    paidAt: new Date(),
  });

  link.status = 'PAID';
  link.paidAt = new Date();
  link.paymentId = payment._id;
  // A paid link is single-use: expiry is pulled forward so it can never be
  // presented again, in addition to the LINK_ALREADY_PAID guard.
  link.expiresAt = new Date();
  await link.save();

  await auditLog({
    actorUserId: req.user?.sub ?? null,
    action: 'PAYMENT_LINK_PAID',
    resourceType: 'PaymentLink',
    resourceId: String(link._id),
    newData: { paymentReference, amount: link.amount, currency: link.currency, provider, payerPhone },
    requestId: req.requestId,
  });

  /* Money received → the property is sold: taken off the public market, and the
   * agent plus every admin are told through notifications and the thread. */
  let propertyMarkedSold = false;
  if (link.propertyId?._id || link.propertyId) {
    const sold = await markPropertySoldFromPayment({
      propertyId: String(link.propertyId?._id ?? link.propertyId),
      paymentReference,
      amount: link.amount,
      currency: link.currency,
      payerPhone,
      linkId: String(link._id),
      actorUserId: req.user?.sub,
      requestId: req.requestId,
    });
    propertyMarkedSold = Boolean(sold);
  }

  return {
    paymentReference,
    amount: payment.amount,
    currency: payment.currency,
    status: payment.status,
    provider,
    payerPhone,
    paidAt: payment.paidAt,
    propertyMarkedSold,
  };
}