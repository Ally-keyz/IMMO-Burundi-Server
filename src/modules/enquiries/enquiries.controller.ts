import { Request, Response } from 'express';
import * as service from './enquiries.service.js';
import { asyncHandler, created, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';

export const create = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  created(res, await service.createEnquiry(user.sub, req.body, req.requestId));
});

export const listMine = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const { items, meta } = await service.listMyEnquiries(user.sub, req.query);
  ok(res, items, meta);
});

export const listForProperty = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.listPropertyEnquiries(String(req.params.propertyId), req));
});

export const respond = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.respondToEnquiry(String(req.params.id), req));
});

export const agentInbox = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.listAgentInbox(req, { ...req.query, userId: user.sub }));
});

export const setStatus = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.setEnquiryStatus(String(req.params.id), String(req.body.status), req));
});
