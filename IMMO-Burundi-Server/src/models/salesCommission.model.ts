import { Schema, model } from 'mongoose';
import { COMPLETION_STATUSES, CURRENCIES } from '@immo/shared-types';

export const salesCommissionSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    transactionId: { type: Schema.Types.ObjectId, ref: 'Transaction', index: true },
    agentId: { type: Schema.Types.ObjectId, ref: 'Agent', index: true },
    buyerId: { type: Schema.Types.ObjectId, ref: 'User' },
    sellerId: { type: Schema.Types.ObjectId, ref: 'User' },
    commissionCode: { type: String, required: true, unique: true },
    saleAmount: { type: Number, required: true, min: 0 },
    commissionRate: { type: Number, required: true },
    commissionAmount: { type: Number, required: true, min: 0 },
    currency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
    dueDate: { type: Date },
    paidAt: { type: Date },
    status: { type: String, enum: [...COMPLETION_STATUSES], default: 'PENDING', index: true },
  },
  { timestamps: true },
);

export const SalesCommission = model('SalesCommission', salesCommissionSchema);
export default SalesCommission;
