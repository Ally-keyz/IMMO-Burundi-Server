import { Schema, model } from 'mongoose';
import { CURRENCIES, ENTITY_STATUS } from '@immo/shared-types';

export const promotionPackageSchema = new Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String },
    price: { type: Number, required: true, min: 0 },
    currency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
    durationDays: { type: Number, required: true, min: 1 },
    features: { type: [String], default: [] },
    status: { type: String, enum: [...ENTITY_STATUS], default: 'ACTIVE' },
  },
  { timestamps: true },
);

export const PromotionPackage = model('PromotionPackage', promotionPackageSchema);
export default PromotionPackage;
