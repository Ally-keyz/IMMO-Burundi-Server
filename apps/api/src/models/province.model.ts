import { Schema, model } from 'mongoose';
import { ENTITY_STATUS } from '@immo/shared-types';

export const provinceSchema = new Schema(
  {
    name: { type: String, required: true, trim: true },
    code: { type: String, required: true, unique: true, uppercase: true, trim: true },
    status: { type: String, enum: [...ENTITY_STATUS], default: 'ACTIVE' },
  },
  { timestamps: true },
);

export const Province = model('Province', provinceSchema);
export default Province;
