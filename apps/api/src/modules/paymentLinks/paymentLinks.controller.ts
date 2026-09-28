import { Request, Response } from 'express';
import * as service from './paymentLinks.service.js';
import { asyncHandler, created, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';

export const create = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const link = await service.createPaymentLink(req, { ...req.body, createdByUserId: user.sub });
  created(res, link);
});

export const listAgentLinks = asyncHandler(async (req: Request, res: Response) => {
  requireUser(req);
  ok(res, await service.listAgentLinks(req));
});

export const resolveLink = asyncHandler(async (req: Request, res: Response) => {
  requireUser(req);
  ok(res, await service.resolvePaymentLink(req, String(req.params.token)));
});

export const payLink = asyncHandler(async (req: Request, res: Response) => {
  requireUser(req);
  created(res, await service.payPaymentLink(req, String(req.params.token), req.body));
});