import { Request, Response } from 'express';
import { asyncHandler, created, ok } from '../../helpers/http.js';
import { requireRole } from '../../helpers/authz.js';
import * as service from './admin.service.js';
import * as propertiesService from '../properties/properties.service.js';

function queryOf(req: Request): any {
  return (req as any).validatedQuery ?? req.query;
}

export const summary = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['MAIN_ADMIN']);
  ok(res, await service.getSummary(queryOf(req)));
});

export const listAgents = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['MAIN_ADMIN']);
  const { items, meta } = await service.listAgents(queryOf(req));
  ok(res, items, meta);
});

export const createAgent = asyncHandler(async (req: Request, res: Response) => {
  const actor = requireRole(req, ['MAIN_ADMIN']);
  created(res, await service.createAgent(req.body, actor.sub, req.requestId));
});

export const updateAgentStatus = asyncHandler(async (req: Request, res: Response) => {
  const actor = requireRole(req, ['MAIN_ADMIN']);
  ok(res, await service.updateAgentStatus(String(req.params.id), req.body, actor.sub, req.requestId));
});

export const setAgentVerification = asyncHandler(async (req: Request, res: Response) => {
  const actor = requireRole(req, ['MAIN_ADMIN']);
  ok(res, await service.setAgentVerification(String(req.params.id), req.body, actor.sub, req.requestId));
});

export const listProperties = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['MAIN_ADMIN']);
  const { items, meta } = await service.listProperties(queryOf(req));
  ok(res, items, meta);
});

function transition(action: 'approve' | 'reject' | 'request-correction' | 'block' | 'unblock') {
  return asyncHandler(async (req: Request, res: Response) => {
    requireRole(req, ['MAIN_ADMIN']);
    const property = await propertiesService.transitionProperty(String(req.params.id), action, req, req.body);
    ok(res, service.shapeProperty(property));
  });
}

export const approveProperty = transition('approve');
export const rejectProperty = transition('reject');
export const requestPropertyCorrection = transition('request-correction');
export const blockProperty = transition('block');
export const unblockProperty = transition('unblock');

export const setPropertyVerification = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['MAIN_ADMIN']);
  const property = await propertiesService.setPropertyVerification(String(req.params.id), req.body, req);
  ok(res, service.shapeProperty(property));
});

export const listBookings = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['MAIN_ADMIN']);
  const { items, meta } = await service.listBookings(queryOf(req));
  ok(res, items, meta);
});

export const updateBookingStatus = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['MAIN_ADMIN']);
  ok(res, await service.updateBooking(String(req.params.id), req.body.status, req));
});

export const listRequests = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['MAIN_ADMIN']);
  const { items, meta } = await service.listRequests(queryOf(req));
  ok(res, items, meta);
});

export const updateRequestStatus = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['MAIN_ADMIN']);
  ok(res, await service.updateRequestStatus(String(req.params.id), req.body.status, req));
});
