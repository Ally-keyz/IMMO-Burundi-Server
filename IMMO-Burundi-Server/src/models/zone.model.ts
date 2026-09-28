import { Schema, model } from 'mongoose';
import { ENTITY_STATUS } from '@immo/shared-types';

export const zoneSchema = new Schema(
  {
    name: { type: String, required: true, trim: true },
    code: { type: String, required: true, uppercase: true, trim: true },
    communeId: { type: Schema.Types.ObjectId, ref: 'Commune', required: true, index: true },
    status: { type: String, enum: [...ENTITY_STATUS], default: 'ACTIVE' },
  },
  { timestamps: true },
);

zoneSchema.index({ communeId: 1, code: 1 }, { unique: true });

export const Zone = model('Zone', zoneSchema);
export default Zone;
