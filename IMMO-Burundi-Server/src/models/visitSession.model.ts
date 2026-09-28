import { Schema, model } from 'mongoose';
import { VISIT_SESSION_STATUSES } from '@immo/shared-types';

export const visitSessionSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    date: { type: Date, required: true },
    startTime: { type: String, required: true },
    endTime: { type: String, required: true },
    capacity: { type: Number, required: true, min: 1 },
    bookedCount: { type: Number, default: 0, min: 0 },
    bookingDeadline: { type: Date },
    status: { type: String, enum: [...VISIT_SESSION_STATUSES], default: 'SCHEDULED', index: true },
    createdBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    timezone: { type: String, default: 'Africa/Bujumbura' },
  },
  { timestamps: true },
);

visitSessionSchema.index({ propertyId: 1, date: 1, status: 1 });

export const VisitSession = model('VisitSession', visitSessionSchema);
export default VisitSession;
