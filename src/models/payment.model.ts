import { Schema, model } from 'mongoose';
import { CURRENCIES, PAYMENT_CATEGORIES, PAYMENT_STATUSES } from '@immo/shared-types';

export const paymentSchema = new Schema(
  {
    payerId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    amount: { type: Number, required: true, min: 0 },
    currency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
    paymentReference: { type: String, required: true, unique: true },
    paymentMethod: { type: String },
    category: { type: String, enum: [...PAYMENT_CATEGORIES], required: true, index: true },
    status: { type: String, enum: [...PAYMENT_STATUSES], default: 'PENDING', index: true },
    relatedEntityType: { type: String },
    relatedEntityId: { type: Schema.Types.ObjectId, refPath: 'relatedEntityType' },
    provider: { type: String },
    providerTransactionId: { type: String },
    payerPhone: { type: String },
    confirmedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    paidAt: { type: Date },
  },
  { timestamps: true },
);

paymentSchema.index({ category: 1, status: 1, createdAt: -1 });

export const Payment = model('Payment', paymentSchema);
export default Payment;
