import { Schema, model } from 'mongoose';
import { PERMISSION_SCOPES } from '@immo/shared-types';

export const rolePermissionSchema = new Schema(
  {
    roleId: { type: Schema.Types.ObjectId, ref: 'Role', required: true, index: true },
    permissionId: { type: Schema.Types.ObjectId, ref: 'Permission', required: true, index: true },
    scope: { type: String, enum: [...PERMISSION_SCOPES], required: true },
    provinceId: { type: Schema.Types.ObjectId, ref: 'Province' },
    communeId: { type: Schema.Types.ObjectId, ref: 'Commune' },
    departmentId: { type: Schema.Types.ObjectId, ref: 'Department' },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

rolePermissionSchema.index({ roleId: 1, permissionId: 1, scope: 1 }, { unique: true });

export const RolePermission = model('RolePermission', rolePermissionSchema);
export default RolePermission;
