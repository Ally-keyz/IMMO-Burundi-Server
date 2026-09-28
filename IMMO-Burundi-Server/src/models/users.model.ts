import { Schema, model } from 'mongoose';
import { ACCOUNT_STATUSES, CURRENCIES, LANGUAGES, USER_ROLES } from '@immo/shared-types';

/**
 * User account — Backend Spec §5–6.
 * `role` links the user to a Role document used to compute effective permissions.
 * (The variable permission set lives in role_permissions / user_permissions.)
 */
export const userSchema = new Schema(
  {
    firstName: { type: String, required: true, trim: true },
    lastName: { type: String, required: true, trim: true },
    phone: { type: String, required: true, unique: true, trim: true },
    phoneVerifiedAt: { type: Date },
    email: { type: String, unique: true, sparse: true, lowercase: true, trim: true },
    emailVerifiedAt: { type: Date },
    photoUrl: { type: String, trim: true },
    passwordHash: { type: String, required: true, select: false },
    setupTokenHash: { type: String, select: false, index: true },
    setupTokenExpiresAt: { type: Date },
    accountActivatedAt: { type: Date },
    role: { type: String, enum: [...USER_ROLES], default: 'CLIENT', index: true },
    roleId: { type: Schema.Types.ObjectId, ref: 'Role' },
    preferredLanguage: { type: String, enum: [...LANGUAGES], default: 'fr' },
    preferredCurrency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
    status: { type: String, enum: [...ACCOUNT_STATUSES], default: 'PENDING', index: true },
    lastLoginAt: { type: Date },
    deletedAt: { type: Date },
  },
  { timestamps: true },
);

export const User = model('User', userSchema);
export default User;
