import { Schema, model } from 'mongoose';

export const propertyViewSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User' },
    anonymousId: { type: String },
    sessionId: { type: String },
    deviceType: { type: String },
    browser: { type: String },
    ipHash: { type: String },
    referrer: { type: String },
    cityApproximate: { type: String },
    country: { type: String },
    viewedAt: { type: Date, default: Date.now },
  },
  { timestamps: false },
);

propertyViewSchema.index({ propertyId: 1, viewedAt: -1 });
propertyViewSchema.index({ propertyId: 1, sessionId: 1, viewedAt: -1 });

export const PropertyView = model('PropertyView', propertyViewSchema);
export default PropertyView;
