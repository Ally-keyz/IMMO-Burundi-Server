import { Schema, model } from 'mongoose';
import { RENTAL_APPLICATION_STATUSES } from '@immo/shared-types';

export const rentalApplicationSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    applicantId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    applicationCode: { type: String, required: true, unique: true },
    fullName: { type: String, required: true },
    phone: { type: String, required: true },
    email: { type: String },
    address: { type: String },
    totalOccupants: { type: Number },
    numberOfChildren: { type: Number },
    occupation: { type: String },
    advanceAvailable: { type: Boolean },
    moveInDate: { type: Date },
    status: {
      type: String,
      enum: [...RENTAL_APPLICATION_STATUSES],
      default: 'SUBMITTED',
      index: true,
    },
    landlordNotes: { type: String, select: false },
  },
  { timestamps: true },
);

export const RentalApplication = model('RentalApplication', rentalApplicationSchema);
export default RentalApplication;
