import { Request, Response } from 'express';
import * as service from './properties.service.js';
import { asyncHandler, created, ok } from '../../helpers/http.js';
import { requireRole, requireUser } from '../../helpers/authz.js';

export const create = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const property = await service.createProperty(user.sub, req.body, { requestId: req.requestId });
  created(res, property);
});

export const list = asyncHandler(async (req: Request, res: Response) => {
  const { items, meta } = await service.listProperties(req);
  ok(res, items, meta);
});

export const listManaged = asyncHandler(async (req: Request, res: Response) => {
  const user = requireRole(req, ['AGENT', 'FIELD_AGENT']);
  const { items, meta } = await service.listManagedProperties(user.sub, req.query);
  ok(res, items, meta);
});

export const getManaged = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['AGENT', 'FIELD_AGENT']);
  ok(res, await service.getManagedProperty(String(req.params.id), req));
});

export const updateManaged = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['AGENT', 'FIELD_AGENT']);
  ok(res, await service.updateProperty(String(req.params.id), req, req.body));
});

export const deleteManaged = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['AGENT', 'FIELD_AGENT']);
  ok(res, await service.deleteProperty(String(req.params.id), req));
});

export const managedAnalytics = asyncHandler(async (req: Request, res: Response) => {
  requireRole(req, ['AGENT', 'FIELD_AGENT']);
  ok(res, await service.propertyAnalytics(String(req.params.id), req));
});

export const featured = asyncHandler(async (req: Request, res: Response) => {
  const limit = Math.min(50, Number(req.query.limit) || 12);
  ok(res, await service.featuredProperties(limit));
});

export const recent = asyncHandler(async (req: Request, res: Response) => {
  const limit = Math.min(50, Number(req.query.limit) || 12);
  ok(res, await service.recentProperties(limit));
});

export const verified = asyncHandler(async (req: Request, res: Response) => {
  const limit = Math.min(50, Number(req.query.limit) || 20);
  ok(res, await service.verifiedProperties(limit));
});

export const popularLocations = asyncHandler(async (_req: Request, res: Response) => {
  ok(res, await service.popularLocations());
});

export const getOne = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.getProperty(String(req.params.id), req));
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.updateProperty(String(req.params.id), req, req.body));
});

function transition(action: any) {
  return asyncHandler(async (req: Request, res: Response) => {
    ok(res, await service.transitionProperty(String(req.params.id), action, req, req.body));
  });
}

export const submit = transition('submit');
export const approve = transition('approve');
export const reject = transition('reject');
export const requestCorrection = transition('request-correction');
export const publish = transition('publish');
export const unpublish = transition('unpublish');
export const archive = transition('archive');
export const markSold = transition('mark-sold');
export const markRented = transition('mark-rented');
export const relist = transition('relist');

export const related = asyncHandler(async (req: Request, res: Response) => {
  const limit = Math.min(24, Number(req.query.limit) || 12);
  ok(res, await service.relatedProperties(String(req.params.id), limit));
});

export const favorite = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.toggleFavorite(String(req.params.id), user.sub));
});

export const analytics = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.propertyAnalytics(String(req.params.id), req));
});
