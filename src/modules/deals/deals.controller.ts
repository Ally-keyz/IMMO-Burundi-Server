import { Request, Response } from 'express';
import * as service from './deals.service.js';
import { asyncHandler, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';

export const markPaid = asyncHandler(async (req: Request, res: Response) => {
  requireUser(req);
  const result = await service.markDealPaid(req, req.body?.kind, req.body?.id);
  ok(res, result);
});
