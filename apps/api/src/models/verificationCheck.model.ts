import { Schema, model } from 'mongoose';
import { CHECK_STATUSES } from '@immo/shared-types';

export const verificationCheckSchema = new Schema(
  {
    verificationRequestId: {
      type: Schema.Types.ObjectId,
      ref: 'VerificationRequest',
      required: true,
      index: true,
    },
    documentId: { type: String },
    checkType: { type: String, required: true },
    status: { type: String, enum: [...CHECK_STATUSES], required: true },
    notes: { type: String },
    checkedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    checkedAt: { type: Date, default: Date.now },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

export const VerificationCheck = model('VerificationCheck', verificationCheckSchema);
export default VerificationCheck;
