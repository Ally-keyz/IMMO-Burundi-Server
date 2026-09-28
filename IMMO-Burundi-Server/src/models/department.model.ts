import { Schema, model } from 'mongoose';
import { DEPARTMENTS, ENTITY_STATUS } from '@immo/shared-types';

export const departmentSchema = new Schema(
  {
    name: { type: String, enum: [...DEPARTMENTS], required: true, unique: true },
    description: { type: String },
    status: { type: String, enum: [...ENTITY_STATUS], default: 'ACTIVE' },
    headUserId: { type: Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true },
);

export const Department = model('Department', departmentSchema);
export default Department;
