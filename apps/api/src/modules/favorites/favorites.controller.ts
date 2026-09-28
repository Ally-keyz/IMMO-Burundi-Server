import { Request, Response } from 'express';
import * as service from './favorites.service.js';
import { asyncHandler, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';

export const add = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.addFavorite(user.sub, String(req.body.propertyId)));
});

export const list = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const { items, meta } = await service.listFavorites(user.sub, req.query);
  ok(res, items, meta);
});

export const remove = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.removeFavorite(user.sub, String(req.params.propertyId)));
});
