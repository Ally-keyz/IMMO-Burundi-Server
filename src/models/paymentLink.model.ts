import { Schema, model } from 'mongoose';
import { CURRENCIES, PAYMENT_LINK_STATUSES } from '@immo/shared-types';

/**
 * Payment link — Migration §8. An opaque token bound server-side to a
 * specific (requester account, property) pair. Only the bound requester can
 * open or pay the link; anyone else gets a clear "not for you" block.
 */
export const paymentLinkSchema = new Schema(
  {
    token: { type: String, required: true, unique: true, index: true },
    createdByUserId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    agentId: { type: Schema.Types.ObjectId, ref: 'Agent', index: true },
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    requesterUserId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    enquiryId: { type: Schema.Types.ObjectId, ref: 'Enquiry', index: true },
    bookingId: { type: Schema.Types.ObjectId, ref: 'VisitBooking', index: true },
    amount: { type: Number, required: true, min: 0 },
    currency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
    note: { type: String },
    status: { type: String, enum: [...PAYMENT_LINK_STATUSES], default: 'CREATED', index: true },
    paymentId: { type: Schema.Types.ObjectId, ref: 'Payment', index: true },
    openedAt: { type: Date },
    paidAt: { type: Date },
    expiresAt: { type: Date, required: true },
  },
  { timestamps: true },
);

paymentLinkSchema.index({ requesterUserId: 1, status: 1 });
paymentLinkSchema.index({ agentId: 1, createdAt: -1 });

export const PaymentLink = model('PaymentLink', paymentLinkSchema);
export default PaymentLink;