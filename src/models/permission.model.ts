import { Schema, model } from 'mongoose';

export const permissionSchema = new Schema(
  {
    code: { type: String, required: true, unique: true, trim: true },
    resource: { type: String, required: true, index: true },
    action: { type: String, required: true },
    name: { type: String },
    description: { type: String },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

export const Permission = model('Permission', permissionSchema);
export default Permission;
