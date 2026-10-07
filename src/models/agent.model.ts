import { Schema, model } from 'mongoose';
import { AGENT_VERIFICATION_STATUSES } from '@immo/shared-types';

export const AGENT_STATUSES = ['ACTIVE', 'SUSPENDED', 'INACTIVE'] as const;

export const agentSchema = new Schema(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    agentCode: { type: String, unique: true, trim: true },
    licenseNumber: { type: String },
    agencyName: { type: String },
    bio: { type: String },
    slogan: { type: String },
    reviewsCount: { type: Number, default: 0 },
    photo: { type: String },
    provinceId: { type: Schema.Types.ObjectId, ref: 'Province', index: true },
    communeId: { type: Schema.Types.ObjectId, ref: 'Commune', index: true },
    status: { type: String, enum: [...AGENT_STATUSES], default: 'ACTIVE' },
    statusReason: { type: String },
    statusChangedAt: { type: Date },
    statusChangedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    verificationStatus: { type: String, enum: [...AGENT_VERIFICATION_STATUSES], default: 'NOT_VERIFIED', index: true },
    verifiedAt: { type: Date },
    verifiedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    verificationNote: { type: String },
    topAgent: { type: Boolean, default: false },
    rating: { type: Number, default: 0 },
    totalProperties: { type: Number, default: 0 },
    totalSales: { type: Number, default: 0 },
    totalRentals: { type: Number, default: 0 },
    totalDeals: { type: Number, default: 0 },
  },
  { timestamps: true },
);

export const Agent = model('Agent', agentSchema);
export default Agent;
