import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { createHash, randomBytes, randomUUID } from 'crypto';
import { AppError } from '../../middleware/errorHandler.js';
import { env } from '../../config/env.js';
import { User } from '../../models/users.model.js';
import { Client } from '../../models/client.model.js';
import { Role } from '../../models/role.model.js';
import '../../models/permission.model.js';
import { RolePermission } from '../../models/rolePermission.model.js';
import { UserPermission } from '../../models/userPermission.model.js';
import { auditLog } from '../../helpers/auditLog.js';
import { RegisterBody, UserPublicDTO } from '@immo/shared-types';

/** In-memory refresh-token revocation list (Phase 1 — swap for Redis later). */
const revokedRefreshTokens = new Set<string>();

const BCRYPT_ROUNDS = 12;

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

export function toUserPublicDTO(user: any): UserPublicDTO {
  const u = typeof user.toObject === 'function' ? user.toObject() : user;
  return {
    _id: String(u._id),
    firstName: u.firstName,
    lastName: u.lastName,
    phone: u.phone,
    email: u.email,
    role: u.role,
    roleId: u.roleId ? String(u.roleId) : undefined,
    photoUrl: u.photoUrl,
    preferredLanguage: u.preferredLanguage ?? 'fr',
    preferredCurrency: u.preferredCurrency ?? 'BIF',
    status: u.status,
    createdAt: u.createdAt ? new Date(u.createdAt).toISOString() : new Date().toISOString(),
  };
}

function hashSetupToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

function setupTokenExpiry(): Date {
  return new Date(Date.now() + env.SETUP_ACCOUNT_TTL_HOURS * 60 * 60 * 1000);
}

export async function createAgentSetupToken(userId: string): Promise<{ token: string; user: UserPublicDTO }> {
  const token = randomBytes(32).toString('hex');
  const user = await User.findOneAndUpdate(
    { _id: userId, status: 'PENDING', role: { $in: ['AGENT', 'FIELD_AGENT'] } },
    { $set: { setupTokenHash: hashSetupToken(token), setupTokenExpiresAt: setupTokenExpiry() } },
    { new: true },
  );
  if (!user) throw new AppError(409, 'SETUP_ACCOUNT_UNAVAILABLE', 'The agent account is not awaiting activation.');
  return { token, user: toUserPublicDTO(user) };
}

export async function getAccountSetup(token: string): Promise<{ firstName: string; lastName: string; email: string; expiresAt: string }> {
  if (!token || token.length < 32) {
    throw new AppError(400, 'SETUP_LINK_INVALID', 'This account setup link is invalid.');
  }
  const user = await User.findOne({
    setupTokenHash: hashSetupToken(token),
    setupTokenExpiresAt: { $gt: new Date() },
  }).select('firstName lastName email status setupTokenExpiresAt');
  if (!user) {
    throw new AppError(400, 'SETUP_LINK_INVALID', 'This account setup link is invalid or has expired.');
  }
  if (user.status !== 'PENDING') {
    throw new AppError(410, 'SETUP_LINK_USED', 'This account setup link has already been used.');
  }
  return {
    firstName: user.firstName,
    lastName: user.lastName,
    email: user.email ?? '',
    expiresAt: user.setupTokenExpiresAt!.toISOString(),
  };
}

export async function activateAccount(token: string, password: string) {
  const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
  const user = await User.findOneAndUpdate(
    {
      setupTokenHash: hashSetupToken(token),
      status: 'PENDING',
      role: { $in: ['AGENT', 'FIELD_AGENT'] },
      setupTokenExpiresAt: { $gt: new Date() },
    },
    {
      $set: {
        passwordHash,
        status: 'ACTIVE',
        emailVerifiedAt: new Date(),
        accountActivatedAt: new Date(),
      },
      $unset: { setupTokenHash: 1, setupTokenExpiresAt: 1 },
    },
    { new: true },
  );
  if (!user) {
    throw new AppError(400, 'SETUP_LINK_INVALID', 'This account setup link is invalid or has expired.');
  }

  await auditLog({
    actorUserId: String(user._id),
    action: 'ACCOUNT_ACTIVATED',
    resourceType: 'User',
    resourceId: String(user._id),
  });

  const tokens = await issueTokens(user);
  return { user: toUserPublicDTO(user), ...tokens };
}

/** Pack effective permissions (role grants + temporary user grants) into JWT scopes. */
async function buildScopes(user: any): Promise<string[]> {
  const scopes: string[] = [];
  const seen = new Set<string>();

  const role = user.roleId
    ? await Role.findById(user.roleId).lean()
    : await Role.findOne({ name: user.role }).lean();

  if (role) {
    const grants = await RolePermission.find({ roleId: (role as any)._id })
      .populate('permissionId')
      .lean();
    for (const grant of grants) {
      const permission: any = (grant as any).permissionId;
      if (!permission?.code) continue;
      const packed = [
        permission.code,
        (grant as any).scope,
        (grant as any).provinceId ?? '',
        (grant as any).communeId ?? '',
        (grant as any).departmentId ?? '',
      ].join('|');
      if (!seen.has(packed)) {
        seen.add(packed);
        scopes.push(packed);
      }
    }
  }

  const overrides = await UserPermission.find({
    userId: user._id,
    revokedAt: null,
    $or: [{ expiresAt: null }, { expiresAt: { $gt: new Date() } }],
  })
    .populate('permissionId')
    .lean();
  for (const grant of overrides) {
    const permission: any = (grant as any).permissionId;
    if (!permission?.code) continue;
    const packed = [
      permission.code,
      (grant as any).scope,
      (grant as any).provinceId ?? '',
      (grant as any).communeId ?? '',
      (grant as any).departmentId ?? '',
    ].join('|');
    if (!seen.has(packed)) {
      seen.add(packed);
      scopes.push(packed);
    }
  }

  return scopes;
}

async function issueTokens(user: any): Promise<TokenPair> {
  const scopes = await buildScopes(user);
  const accessJti = randomUUID();
  const accessToken = jwt.sign(
    { sub: String(user._id), role: user.role, scopes },
    env.JWT_SECRET,
    { expiresIn: env.JWT_ACCESS_TTL as any, jwtid: accessJti },
  );
  const refreshToken = jwt.sign(
    { sub: String(user._id) },
    env.REFRESH_TOKEN_SECRET,
    { expiresIn: env.JWT_REFRESH_TTL as any, jwtid: randomUUID() },
  );
  return { accessToken, refreshToken };
}

function isAgentAccount(user: any): boolean {
  return ['AGENT', 'FIELD_AGENT'].includes(String(user.role ?? ''));
}

function assertLoginAllowed(user: any): boolean {
  const status = String(user.status ?? '');
  if (status === 'PENDING') {
    if (isAgentAccount(user)) {
      throw new AppError(403, 'ACCOUNT_SETUP_REQUIRED', 'Complete your account setup before signing in.');
    }
    user.status = 'ACTIVE';
    user.accountActivatedAt = new Date();
    return true;
  }
  if (['SUSPENDED', 'DELETED', 'LOCKED', 'DISABLED'].includes(status)) {
    throw new AppError(403, 'ACCOUNT_INACTIVE', `This account is ${status.toLowerCase()}.`);
  }
  return false;
}

export async function register(body: RegisterBody & { password: string }) {
  const phone = body.phone.trim();
  const email = body.email?.toLowerCase().trim();

  const existingPhone = await User.findOne({ phone }).lean();
  if (existingPhone) {
    throw new AppError(409, 'PHONE_TAKEN', 'An account with this phone number already exists.');
  }
  if (email) {
    const existingEmail = await User.findOne({ email }).lean();
    if (existingEmail) {
      throw new AppError(409, 'EMAIL_TAKEN', 'An account with this email already exists.');
    }
  }

  const selectedRole = body.role === 'CUSTOMER' ? 'CUSTOMER' : 'CLIENT';

  const passwordHash = await bcrypt.hash(body.password, BCRYPT_ROUNDS);
  const user = await User.create({
    firstName: body.firstName.trim(),
    lastName: body.lastName.trim(),
    phone,
    email,
    photoUrl: body.photoUrl,
    passwordHash,
    preferredLanguage: body.preferredLanguage,
    preferredCurrency: body.preferredCurrency,
    role: selectedRole,
    status: 'ACTIVE',
  });

  await Client.create({ userId: user._id });

  await auditLog({
    actorUserId: String(user._id),
    action: 'USER_REGISTERED',
    resourceType: 'User',
    resourceId: String(user._id),
    newData: { role: selectedRole },
  });

  const tokens = await issueTokens(user);
  return { user: toUserPublicDTO(user), ...tokens };
}

export async function login(identifier: string, password: string, meta?: { ipHash?: string; userAgent?: string; requestId?: string }) {
  const id = identifier.trim();
  const user = await User.findOne({
    $or: [{ phone: id }, { email: id.toLowerCase() }],
  }).select('+passwordHash');

  if (!user) {
    throw new AppError(401, 'INVALID_CREDENTIALS', 'Invalid phone/email or password.');
  }

  const valid = await bcrypt.compare(password, (user as any).passwordHash);
  if (!valid) {
    throw new AppError(401, 'INVALID_CREDENTIALS', 'Invalid phone/email or password.');
  }

  assertLoginAllowed(user);

  (user as any).lastLoginAt = new Date();
  await user.save();

  await auditLog({
    actorUserId: String(user._id),
    action: 'USER_LOGIN',
    resourceType: 'User',
    resourceId: String(user._id),
    ipHash: meta?.ipHash,
    userAgent: meta?.userAgent,
    requestId: meta?.requestId,
  });

  const tokens = await issueTokens(user);
  return { user: toUserPublicDTO(user), ...tokens };
}

interface GoogleTokenPayload {
  iss: string;
  sub: string;
  aud: string;
  email?: string;
  email_verified?: boolean | string;
  name?: string;
  given_name?: string;
  family_name?: string;
  picture?: string;
  exp: number;
}

/** Sign in (or auto-register) using a Google OAuth access token, verified via Google's tokeninfo endpoint. */
export async function googleLogin(accessToken: string, requestedRole?: string) {
  if (!env.GOOGLE_CLIENT_ID) {
    throw new AppError(503, 'GOOGLE_NOT_CONFIGURED', 'Google sign-in is not configured.');
  }

  let payload: GoogleTokenPayload | null = null;
  try {
    const res = await fetch(`https://oauth2.googleapis.com/tokeninfo?access_token=${encodeURIComponent(accessToken)}`, {
      method: 'GET',
      headers: { Accept: 'application/json' },
    });
    const raw = await res.text();
    if (raw) {
      try {
        payload = JSON.parse(raw) as GoogleTokenPayload;
      } catch {
        payload = null;
      }
    }
    if (!res.ok || !payload || (payload as { error?: string }).error) {
      throw new Error('tokeninfo rejected the token');
    }
  } catch (err) {
    if (err instanceof AppError) throw err;
    throw new AppError(401, 'INVALID_GOOGLE_TOKEN', 'Google token could not be verified.');
  }

  if (!payload || payload.aud !== env.GOOGLE_CLIENT_ID) {
    throw new AppError(401, 'INVALID_GOOGLE_TOKEN', 'Google token audience mismatch.');
  }
  if (!payload.email || payload.email_verified !== true && payload.email_verified !== 'true') {
    throw new AppError(401, 'UNVERIFIED_EMAIL', 'A verified Google email is required to sign in.');
  }
  if (payload.exp && payload.exp * 1000 < Date.now()) {
    throw new AppError(401, 'INVALID_GOOGLE_TOKEN', 'Google token has expired.');
  }

  const email = payload.email.toLowerCase();
  let user = await User.findOne({ email });

  if (!user) {
    if (requestedRole === 'AGENT') {
      throw new AppError(403, 'AGENT_SELF_REGISTRATION_DISALLOWED', 'Agent accounts are provisioned by the system administrator.');
    }
    const selectedRole = requestedRole === 'CUSTOMER' ? 'CUSTOMER' : 'CLIENT';

    const userDoc = await User.create({
      firstName: payload.given_name || payload.name?.split(' ')[0] || 'Google',
      lastName: payload.family_name || payload.name?.split(' ').slice(1).join(' ') || 'User',
      phone: `GOOGLE_${payload.sub}`,
      email,
      emailVerifiedAt: new Date(),
      photoUrl: payload.picture,
      passwordHash: await bcrypt.hash(randomUUID(), BCRYPT_ROUNDS),
      role: selectedRole,
      status: 'ACTIVE',
    });

    await Client.create({ userId: userDoc._id });

    await auditLog({
      actorUserId: String(userDoc._id),
      action: 'USER_REGISTERED_VIA_GOOGLE',
      resourceType: 'User',
      resourceId: String(userDoc._id),
      newData: { role: selectedRole, email },
    });

    const tokens = await issueTokens(userDoc);
    return { user: toUserPublicDTO(userDoc), ...tokens };
  }

  assertLoginAllowed(user);

  if (payload.picture && !user.photoUrl) {
    user.photoUrl = payload.picture;
  }
  user.lastLoginAt = new Date();
  await user.save();

  await auditLog({
    actorUserId: String(user._id),
    action: 'USER_LOGIN_VIA_GOOGLE',
    resourceType: 'User',
    resourceId: String(user._id),
  });

  const tokens = await issueTokens(user);
  return { user: toUserPublicDTO(user), ...tokens };
}

export async function refresh(refreshToken: string): Promise<TokenPair> {
  let decoded: any;
  try {
    decoded = jwt.verify(refreshToken, env.REFRESH_TOKEN_SECRET);
  } catch {
    throw new AppError(401, 'INVALID_REFRESH_TOKEN', 'Refresh token is invalid or expired.');
  }

  const jti = decoded.jti as string | undefined;
  if (jti && revokedRefreshTokens.has(jti)) {
    throw new AppError(401, 'REFRESH_REVOKED', 'Refresh token has been revoked.');
  }

  const user = await User.findById(decoded.sub);
  if (!user) throw new AppError(401, 'INVALID_REFRESH_TOKEN', 'Account no longer exists.');
  const activated = assertLoginAllowed(user);
  if (activated) await user.save();

  if (jti) revokedRefreshTokens.add(jti);
  return issueTokens(user);
}

export async function logout(userId: string, refreshToken?: string): Promise<void> {
  if (refreshToken) {
    try {
      const decoded: any = jwt.verify(refreshToken, env.REFRESH_TOKEN_SECRET);
      if (decoded.jti) revokedRefreshTokens.add(decoded.jti);
    } catch {
      /* expired / invalid token — nothing to revoke */
    }
  }

  await auditLog({
    actorUserId: userId,
    action: 'USER_LOGOUT',
    resourceType: 'User',
    resourceId: userId,
  });
}

export async function getMe(userId: string): Promise<UserPublicDTO> {
  const user = await User.findById(userId);
  if (!user) throw new AppError(404, 'USER_NOT_FOUND', 'User not found.');
  return toUserPublicDTO(user);
}

/** Phase 1 OTP stubs — real providers are wired in a later phase. */
export async function sendOtp(phone: string, purpose: string) {
  return { phone, purpose, sent: true, provider: 'STUB', message: 'OTP delivery is stubbed in Phase 1.' };
}

export async function verifyOtp(phone: string, code: string, purpose: string) {
  void phone;
  void code;
  void purpose;
  return { verified: true, provider: 'STUB', message: 'OTP verification is stubbed in Phase 1.' };
}
