import { Request, Response } from 'express';
import * as service from './users.service.js';
import { asyncHandler, ok } from '../../helpers/http.js';
import { requireAdmin, requireUser } from '../../helpers/authz.js';
import { AppError } from '../../middleware/errorHandler.js';

export const me = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.getUser(user.sub));
});

export const recentViews = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const { items, meta } = await service.getRecentViews(user.sub, req.query);
  ok(res, items, meta);
});

export const list = asyncHandler(async (req: Request, res: Response) => {
  requireAdmin(req);
  const { items, meta } = await service.listUsers(req.query);
  ok(res, items, meta);
});

export const getOne = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const id = String(req.params.id);
  const admin = (await import('../../helpers/authz.js')).isAdmin(req);
  if (id !== user.sub && !admin) {
    throw new AppError(403, 'FORBIDDEN', 'You may only view your own profile.');
  }
  ok(res, await service.getUser(id));
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const id = String(req.params.id);
  const admin = (await import('../../helpers/authz.js')).isAdmin(req);
  if (id !== user.sub && !admin) {
    throw new AppError(403, 'FORBIDDEN', 'You may only update your own profile.');
  }
  ok(res, await service.updateUser(id, req.body, { isAdmin: admin }));
});
