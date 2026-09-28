import { Request } from 'express';
import { AppError } from '../middleware/errorHandler.js';
import { AuthTokenPayload } from '@immo/shared-types';

/** Staff roles — hold platform operational privileges. */
export const STAFF_ROLES = [
  'MAIN_ADMIN',
  'CHIEF',
  'DEPARTMENT_HEAD',
  'PROVINCIAL_ADMIN',
  'COMMUNE_ADMIN',
  'REGIONAL_SUPERVISOR',
  'VERIFICATION_OFFICER',
  'ACCOUNTANT',
  'MODERATOR',
  'SUPPORT_OFFICER',
  'MARKETING_OFFICER',
] as const;

/** Admin roles — may review/approve/publish property records. */
export const ADMIN_ROLES = [
  'MAIN_ADMIN',
  'CHIEF',
  'DEPARTMENT_HEAD',
  'PROVINCIAL_ADMIN',
  'COMMUNE_ADMIN',
] as const;

export function roleOf(req: Request): string {
  return req.user?.role ?? 'GUEST';
}

export function isMainAdmin(req: Request): boolean {
  return roleOf(req) === 'MAIN_ADMIN';
}

export function isAdmin(req: Request): boolean {
  return (ADMIN_ROLES as readonly string[]).includes(roleOf(req));
}

export function isStaff(req: Request): boolean {
  return (STAFF_ROLES as readonly string[]).includes(roleOf(req));
}

/** Returns the authenticated token payload or throws 401. */
export function requireUser(req: Request): AuthTokenPayload {
  if (!req.user) throw new AppError(401, 'UNAUTHENTICATED', 'Authentication required');
  return req.user;
}

/** Throws 403 unless the caller has one of the given roles. */
export function requireRole(req: Request, roles: readonly string[]): AuthTokenPayload {
  const user = requireUser(req);
  if (!roles.includes(user.role)) {
    throw new AppError(403, 'FORBIDDEN', 'You do not have permission to perform this action.');
  }
  return user;
}

/** Throws 403 unless the caller is an admin. */
export function requireAdmin(req: Request): AuthTokenPayload {
  return requireRole(req, ADMIN_ROLES);
}

export function denyRoles(req: Request, roles: readonly string[]): void {
  if (roles.includes(roleOf(req))) {
    throw new AppError(403, 'AGENT_SURFACE_FORBIDDEN', 'Agents cannot access public marketplace pages.');
  }
}
