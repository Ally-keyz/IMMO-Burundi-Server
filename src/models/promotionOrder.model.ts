import { Schema, model } from 'mongoose';
import { CURRENCIES, PROMOTION_ORDER_STATUSES } from '@immo/shared-types';

export const promotionOrderSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    packageId: { type: Schema.Types.ObjectId, ref: 'PromotionPackage', required: true },
    promotionCode: { type: String, required: true, unique: true },
    requestedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    amount: { type: Number, required: true, min: 0 },
    currency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
    status: {
      type: String,
      enum: [...PROMOTION_ORDER_STATUSES],
      default: 'PENDING_PAYMENT',
      index: true,
    },
    startsAt: { type: Date },
    endsAt: { type: Date },
  },
  { timestamps: true },
);

export const PromotionOrder = model('PromotionOrder', promotionOrderSchema);
export default PromotionOrder;
