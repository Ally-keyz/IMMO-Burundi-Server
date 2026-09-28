import { Request, Response } from 'express';
import * as service from './auditLogs.service.js';
import { asyncHandler, ok } from '../../helpers/http.js';
import { requireRole } from '../../helpers/authz.js';

export const list = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['MAIN_ADMIN']);
  const { items, meta } = await service.listAuditLogs(req.query);
  ok(res, items, meta);
});
