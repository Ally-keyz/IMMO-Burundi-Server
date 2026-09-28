/**
 * Authentication middleware — extracts and verifies JWT, attaches req.user.
 * Backend Spec §34, §38: every protected endpoint verifies identity + account status.
 */
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { AppError } from './errorHandler.js';
import { AuthTokenPayload } from '@immo/shared-types';
import { User } from '../models/users.model.js';

declare global {
  namespace Express {
    interface Request {
      user?: AuthTokenPayload;
    }
  }
}

async function loadActiveUser(decoded: AuthTokenPayload): Promise<AuthTokenPayload> {
  const user = await User.findById(decoded.sub).select('role status deletedAt').lean();
  if (!user || user.deletedAt) {
    throw new AppError(401, 'UNAUTHENTICATED', 'Account not found');
  }
  if (user.status !== 'ACTIVE') {
    throw new AppError(403, 'ACCOUNT_INACTIVE', 'Account is not active');
  }
  return { ...decoded, role: user.role };
}

export function authenticate(req: Request, _res: Response, next: NextFunction): void {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    throw new AppError(401, 'UNAUTHENTICATED', 'Authentication required');
  }

  let decoded: AuthTokenPayload;
  try {
    decoded = jwt.verify(header.slice(7), env.JWT_SECRET) as AuthTokenPayload;
  } catch (err: any) {
    if (err.name === 'TokenExpiredError') {
      throw new AppError(401, 'TOKEN_EXPIRED', 'Access token expired');
    }
    throw new AppError(401, 'INVALID_TOKEN', 'Invalid access token');
  }

  void loadActiveUser(decoded)
    .then((user) => {
      req.user = user;
      next();
    })
    .catch(next);
}

export function optionalAuth(req: Request, _res: Response, next: NextFunction): void {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) return next();

  let decoded: AuthTokenPayload;
  try {
    decoded = jwt.verify(header.slice(7), env.JWT_SECRET) as AuthTokenPayload;
  } catch {
    return next();
  }

  void loadActiveUser(decoded)
    .then((user) => {
      req.user = user;
      next();
    })
    .catch(() => next());
}