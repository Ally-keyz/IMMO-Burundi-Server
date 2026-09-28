import { Schema, model } from 'mongoose';
import { VERIFICATION_REQUEST_STATUSES, VERIFICATION_RESULTS } from '@immo/shared-types';

export const verificationRequestSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    verificationCode: { type: String, required: true, unique: true },
    status: {
      type: String,
      enum: [...VERIFICATION_REQUEST_STATUSES],
      default: 'PENDING_PAYMENT',
      index: true,
    },
    priority: { type: Number, default: 0 },
    result: { type: String, enum: [...VERIFICATION_RESULTS] },
    rejectionReason: { type: String },
    requestedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    assignedOfficer: { type: Schema.Types.ObjectId, ref: 'User', index: true },
    completedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    notes: { type: String },
    disclaimerVersion: { type: String },
    disclaimerAcceptedAt: { type: Date },
    requestedAt: { type: Date, default: Date.now },
    startedAt: { type: Date },
    completedAt: { type: Date },
  },
  { timestamps: true },
);

export const VerificationRequest = model('VerificationRequest', verificationRequestSchema);
export default VerificationRequest;
