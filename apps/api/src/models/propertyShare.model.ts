import { Schema, model } from 'mongoose';
import { SHARE_PLATFORMS } from '@immo/shared-types';

export const propertyShareSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User' },
    platform: { type: String, enum: [...SHARE_PLATFORMS], required: true },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

export const PropertyShare = model('PropertyShare', propertyShareSchema);
export default PropertyShare;
