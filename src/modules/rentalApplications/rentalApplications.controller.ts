import { Request, Response } from 'express';
import * as service from './rentalApplications.service.js';
import { asyncHandler, created, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';

export const create = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  created(res, await service.createApplication(user.sub, req.body));
});

export const myApplications = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const { items, meta } = await service.myApplications(user.sub, req.query);
  ok(res, items, meta);
});

export const propertyApplications = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.propertyApplications(String(req.params.propertyId), req));
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.updateApplication(String(req.params.id), req, req.body));
});
