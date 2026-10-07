/**
 * Authorization middleware — checks permission + data-scope + resource ownership.
 *
 * Spec references:
 *  - §22  granular resource.action format
 *  - §23  data-scope (GLOBAL / DEPARTMENT / PROVINCE / COMMUNE / TEAM / OWN / ASSIGNED / PUBLIC)
 *  - §96  every API must answer "does this user have the right to see THIS specific record?"
 *  - §38  authorization flow: identity → account status → role → permission → scope → ownership
 *
 * Usage:
 *   router.get('/:id', authenticate, authorize('properties.view'), controller.getOne)
 *
 * The middleware loads the user's effective permissions (role + overrides) into req.auth
 * so controllers can further scope queries (e.g. filter by provinceId, communeId, or ownerId).
 */
import { Request, Response, NextFunction } from 'express';
import { AppError } from './errorHandler.js';
import { AuthTokenPayload, PermissionCode } from '@immo/shared-types';

export interface EffectivePermission {
  permission: string;
  scope: string;
  provinceId?: string;
  communeId?: string;
  departmentId?: string;
}

declare global {
  namespace Express {
    interface Request {
      effectivePermissions?: EffectivePermission[];
      auth?: {
        user: AuthTokenPayload;
        effectivePermissions: EffectivePermission[];
        hasPermission: (permission: PermissionCode, resourceId?: string) => boolean;
        getScope: (permission: PermissionCode) => string | undefined;
      };
    }
  }
}

/**
 * Build effective permissions from the JWT payload.
 *
 * In Phase 1, we store the permission list on the JWT (populated at login).
 * Phase 2+ should move to a DB-cached permission set per user for live revocation.
 */
function buildEffective(req: Request): EffectivePermission[] {
  const user = req.user!;
  const perms: EffectivePermission[] = [];

  // JWT carries `scopes: Array<string>` where each string is "permissionCode|scope|provinceId|communeId|deptId"
  // (packed by the auth service at login). We unpack here.
  if (Array.isArray((user as any).scopes)) {
    for (const entry of (user as any).scopes as string[]) {
      const [permission, scope, provinceId, communeId, departmentId] = entry.split('|');
      perms.push({ permission, scope, provinceId: provinceId || undefined, communeId: communeId || undefined, departmentId: departmentId || undefined });
    }
  }

  return perms;
}

function userHasPermission(
  effectivePermissions: EffectivePermission[],
  requiredPermission: PermissionCode,
): { allowed: boolean; scope?: string; provinceId?: string; communeId?: string; departmentId?: string } {
  for (const ep of effectivePermissions) {
    if (ep.permission === requiredPermission || ep.permission === '*') {
      return { allowed: true, scope: ep.scope, provinceId: ep.provinceId, communeId: ep.communeId, departmentId: ep.departmentId };
    }
  }
  return { allowed: false };
}

/**
 * Factory that returns Express middleware checking the given permission.
 */
export function authorize(...requiredPermissions: PermissionCode[]) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      throw new AppError(401, 'UNAUTHENTICATED', 'Authentication required');
    }

    const effectivePermissions = buildEffective(req);
    req.effectivePermissions = effectivePermissions;

    for (const required of requiredPermissions) {
      const result = userHasPermission(effectivePermissions, required);
      if (!result.allowed) {
        throw new AppError(
          403,
          'FORBIDDEN',
          `You do not have permission to access this resource (${required}).`,
        );
      }
    }

    // Attach a convenience helper to req.auth for controllers.
    req.auth = {
      user: req.user,
      effectivePermissions,
      hasPermission: (permission: PermissionCode) => {
        return userHasPermission(effectivePermissions, permission).allowed;
      },
      getScope: (permission: PermissionCode) => {
        return userHasPermission(effectivePermissions, permission).scope;
      },
    };

    next();
  };
}

/**
 * Helper: checks if the requesting user owns the given resource.
 * Used inside controllers for OWN-scope records.
 */
export function assertOwnershipOrAdmin(
  req: Request,
  resourceOwnerId: string | undefined | null,
): void {
  if (!req.auth) throw new AppError(401, 'UNAUTHENTICATED', 'Authentication required');
  const scope = req.auth.getScope('*' as PermissionCode);
  if (scope === 'GLOBAL') return; // Main Admin
  if (!resourceOwnerId || resourceOwnerId !== req.auth.user.sub) {
    throw new AppError(403, 'FORBIDDEN', 'You do not have access to this resource.');
  }
}

/**
 * Helper: get the province/commune/department scope filters from the current request.
 * Controllers pass this to Mongoose queries to enforce geographic/departmental restrictions.
 */
export function getScopeFilters(req: Request, permission: PermissionCode): Record<string, string> {
  if (!req.auth) return {};
  const ep = req.auth.effectivePermissions.find((p) => p.permission === permission || p.permission === '*');
  if (!ep || ep.scope === 'GLOBAL' || ep.scope === 'OWN' || ep.scope === 'ASSIGNED') return {};
  const filters: Record<string, string> = {};
  if (ep.provinceId) filters.provinceId = ep.provinceId;
  if (ep.communeId) filters.communeId = ep.communeId;
  if (ep.departmentId) filters.departmentId = ep.departmentId;
  return filters;
}