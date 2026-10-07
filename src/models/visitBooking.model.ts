import { Schema, model } from 'mongoose';
import { VISIT_BOOKING_STATUSES } from '@immo/shared-types';

export const visitBookingSchema = new Schema(
  {
    visitSessionId: { type: Schema.Types.ObjectId, ref: 'VisitSession', index: true },
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', index: true },
    preferredDate: { type: String },
    startTime: { type: String },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    bookingReference: { type: String, required: true, unique: true },
    numberOfPeople: { type: Number, default: 1, min: 1 },
    notes: { type: String },
    status: { type: String, enum: [...VISIT_BOOKING_STATUSES], default: 'PENDING', index: true },
    confirmedAt: { type: Date },
    cancelledAt: { type: Date },
  },
  { timestamps: true },
);

visitBookingSchema.index({ visitSessionId: 1, userId: 1 });

export const VisitBooking = model('VisitBooking', visitBookingSchema);
export default VisitBooking;
