import { Schema, model } from 'mongoose';
import { CURRENCIES, FINANCIAL_ADJUSTMENT_CATEGORIES } from '@immo/shared-types';

export const financialAdjustmentSchema = new Schema(
  {
    adjustmentReference: { type: String, required: true, unique: true },
    amount: { type: Number, required: true },
    currency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
    category: { type: String, enum: [...FINANCIAL_ADJUSTMENT_CATEGORIES], required: true, index: true },
    reason: { type: String },
    relatedRecord: { type: String },
    createdBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    approvedBy: { type: Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

export const FinancialAdjustment = model('FinancialAdjustment', financialAdjustmentSchema);
export default FinancialAdjustment;
