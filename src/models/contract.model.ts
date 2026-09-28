import { Schema, model } from 'mongoose';
import { CONTRACT_STATUSES, CONTRACT_TYPES } from '@immo/shared-types';

export const contractSchema = new Schema(
  {
    contractNumber: { type: String, required: true, unique: true },
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', index: true },
    clientId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    agentId: { type: Schema.Types.ObjectId, ref: 'Agent' },
    contractType: { type: String, enum: [...CONTRACT_TYPES], required: true },
    status: { type: String, enum: [...CONTRACT_STATUSES], default: 'DRAFT', index: true },
    version: { type: Number, default: 1 },
    fileId: { type: String },
    signedAt: { type: Date },
  },
  { timestamps: true },
);

export const Contract = model('Contract', contractSchema);
export default Contract;
