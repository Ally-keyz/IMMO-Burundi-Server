import { Schema, model } from 'mongoose';
import { CURRENCIES, REFUND_STATUSES } from '@immo/shared-types';

export const refundSchema = new Schema(
  {
    paymentId: { type: Schema.Types.ObjectId, ref: 'Payment', required: true, index: true },
    refundReference: { type: String, required: true, unique: true },
    amount: { type: Number, required: true, min: 0 },
    currency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
    reason: { type: String },
    status: { type: String, enum: [...REFUND_STATUSES], default: 'REQUESTED', index: true },
    requestedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    approvedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    processedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    processedAt: { type: Date },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

export const Refund = model('Refund', refundSchema);
export default Refund;
