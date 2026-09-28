import { Schema, model } from 'mongoose';

export const userConsentSchema = new Schema(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    documentType: { type: String, required: true },
    documentVersion: { type: String, required: true },
    accepted: { type: Boolean, default: false },
    acceptedAt: { type: Date },
    ipHash: { type: String },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

userConsentSchema.index({ userId: 1, documentType: 1, documentVersion: 1 });

export const UserConsent = model('UserConsent', userConsentSchema);
export default UserConsent;
