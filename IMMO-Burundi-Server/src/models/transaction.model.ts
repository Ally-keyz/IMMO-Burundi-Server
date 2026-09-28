import { Schema, model } from 'mongoose';
import { COMPLETION_STATUSES, CURRENCIES, TRANSACTION_TYPES } from '@immo/shared-types';

export const transactionSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    transactionCode: { type: String, required: true, unique: true },
    transactionType: { type: String, enum: [...TRANSACTION_TYPES], required: true },
    amount: { type: Number, required: true, min: 0 },
    currency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
    buyerId: { type: Schema.Types.ObjectId, ref: 'User' },
    sellerId: { type: Schema.Types.ObjectId, ref: 'User' },
    tenantId: { type: Schema.Types.ObjectId, ref: 'User' },
    landlordId: { type: Schema.Types.ObjectId, ref: 'User' },
    agentId: { type: Schema.Types.ObjectId, ref: 'Agent' },
    status: { type: String, enum: [...COMPLETION_STATUSES], default: 'PENDING', index: true },
    transactionDate: { type: Date },
  },
  { timestamps: true },
);

export const Transaction = model('Transaction', transactionSchema);
export default Transaction;
