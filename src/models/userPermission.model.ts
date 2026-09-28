import { Schema, model } from 'mongoose';
import { PERMISSION_SCOPES } from '@immo/shared-types';

/** Temporary / overridden permission grant for a single user. */
export const userPermissionSchema = new Schema(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    permissionId: { type: Schema.Types.ObjectId, ref: 'Permission', required: true, index: true },
    scope: { type: String, enum: [...PERMISSION_SCOPES], required: true },
    provinceId: { type: Schema.Types.ObjectId, ref: 'Province' },
    communeId: { type: Schema.Types.ObjectId, ref: 'Commune' },
    departmentId: { type: Schema.Types.ObjectId, ref: 'Department' },
    reason: { type: String },
    grantedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    startsAt: { type: Date, default: Date.now },
    expiresAt: { type: Date },
    revokedAt: { type: Date },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

userPermissionSchema.index({ userId: 1, permissionId: 1, scope: 1 });

export const UserPermission = model('UserPermission', userPermissionSchema);
export default UserPermission;
