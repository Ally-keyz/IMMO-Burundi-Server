import { Request, Response } from 'express';
import * as service from './notifications.service.js';
import { asyncHandler, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';

export const list = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const { items, meta } = await service.listNotifications(user.sub, req.query);
  ok(res, items, meta);
});

export const markRead = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.markRead(String(req.params.id), user.sub));
});

export const unreadCount = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.countUnread(user.sub));
});

export const markAllRead = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.markAllRead(user.sub));
});
