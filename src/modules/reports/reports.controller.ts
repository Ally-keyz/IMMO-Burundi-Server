import { Request, Response } from 'express';
import * as service from './reports.service.js';
import { asyncHandler, created, ok } from '../../helpers/http.js';
import { requireAdmin, requireUser } from '../../helpers/authz.js';

export const create = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  created(res, await service.createReport(user.sub, req.body));
});

export const list = asyncHandler(async (req: Request, res: Response) => {
  requireAdmin(req);
  const { items, meta } = await service.listReports(req.query);
  ok(res, items, meta);
});
