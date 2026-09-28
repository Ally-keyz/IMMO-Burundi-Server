import { Schema, model } from 'mongoose';
import { EMPLOYMENT_STATUSES } from '@immo/shared-types';

const emergencyContactSchema = new Schema(
  {
    name: { type: String },
    phone: { type: String },
    relationship: { type: String },
  },
  { _id: false },
);

export const staffProfileSchema = new Schema(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    staffCode: { type: String, unique: true, trim: true },
    departmentId: { type: Schema.Types.ObjectId, ref: 'Department', index: true },
    provinceId: { type: Schema.Types.ObjectId, ref: 'Province', index: true },
    communeId: { type: Schema.Types.ObjectId, ref: 'Commune', index: true },
    jobTitle: { type: String },
    phone: { type: String },
    email: { type: String },
    address: { type: String },
    photoUrl: { type: String },
    employmentStatus: { type: String, enum: [...EMPLOYMENT_STATUSES], default: 'ACTIVE' },
    startDate: { type: Date },
    internalNotes: { type: String },
    emergencyContact: { type: emergencyContactSchema },
  },
  { timestamps: true },
);

export const StaffProfile = model('StaffProfile', staffProfileSchema);
export default StaffProfile;
