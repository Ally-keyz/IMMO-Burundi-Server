import { Schema, model } from 'mongoose';
import { ENTITY_STATUS } from '@immo/shared-types';

export const communeSchema = new Schema(
  {
    name: { type: String, required: true, trim: true },
    code: { type: String, required: true, unique: true, uppercase: true, trim: true },
    provinceId: { type: Schema.Types.ObjectId, ref: 'Province', required: true, index: true },
    status: { type: String, enum: [...ENTITY_STATUS], default: 'ACTIVE' },
  },
  { timestamps: true },
);

export const Commune = model('Commune', communeSchema);
export default Commune;
