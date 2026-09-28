import { Schema, model } from 'mongoose';

export const propertyDailyAnalyticsSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    date: { type: Date, required: true },
    views: { type: Number, default: 0 },
    uniqueVisitors: { type: Number, default: 0 },
    whatsappClicks: { type: Number, default: 0 },
    phoneClicks: { type: Number, default: 0 },
    enquiries: { type: Number, default: 0 },
    favorites: { type: Number, default: 0 },
    shares: { type: Number, default: 0 },
  },
  { timestamps: true },
);

propertyDailyAnalyticsSchema.index({ propertyId: 1, date: 1 }, { unique: true });

export const PropertyDailyAnalytics = model('PropertyDailyAnalytics', propertyDailyAnalyticsSchema);
export default PropertyDailyAnalytics;
