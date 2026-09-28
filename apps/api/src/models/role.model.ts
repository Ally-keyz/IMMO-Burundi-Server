import { Schema, model } from 'mongoose';

export const roleSchema = new Schema(
  {
    name: { type: String, required: true, unique: true, trim: true },
    description: { type: String },
    isSystemRole: { type: Boolean, default: false },
  },
  { timestamps: true },
);

export const Role = model('Role', roleSchema);
export default Role;
