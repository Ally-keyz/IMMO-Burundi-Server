import { Request, Response } from 'express';
import * as service from './verification.service.js';
import { asyncHandler, created, ok } from '../../helpers/http.js';
import { requireAdmin, requireUser } from '../../helpers/authz.js';

export const createRequest = asyncHandler(async (req: Request, res: Response) => {
  created(res, await service.createRequest(req, req.body));
});

export const listRequests = asyncHandler(async (req: Request, res: Response) => {
  const { items, meta } = await service.listRequests(req, req.query);
  ok(res, items, meta);
});

/** Agent-facing: their whole verification portfolio in one payload. */
export const portfolio = asyncHandler(async (req: Request, res: Response) => {
  requireUser(req);
  ok(res, await service.agentPortfolio(req));
});

export const getRequest = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.getRequest(String(req.params.id), req));
});

export const assign = asyncHandler(async (req: Request, res: Response) => {
  requireAdmin(req);
  ok(res, await service.assignOfficer(String(req.params.id), req, req.body));
});

export const start = asyncHandler(async (req: Request, res: Response) => {
  requireUser(req);
  ok(res, await service.startRequest(String(req.params.id), req));
});

export const addCheck = asyncHandler(async (req: Request, res: Response) => {
  requireUser(req);
  created(res, await service.addCheck(String(req.params.id), req, req.body));
});

export const complete = asyncHandler(async (req: Request, res: Response) => {
  requireUser(req);
  ok(res, await service.completeRequest(String(req.params.id), req, req.body));
});
