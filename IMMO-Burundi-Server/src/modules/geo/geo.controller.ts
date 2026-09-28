import { Request, Response } from 'express';
import * as service from './geo.service.js';
import { asyncHandler, ok } from '../../helpers/http.js';

export const provinces = asyncHandler(async (_req: Request, res: Response) => {
  ok(res, await service.listProvinces());
});

export const communes = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.listCommunes(String(req.params.id)));
});

export const zones = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.listZones(String(req.params.id)));
});

export const exchangeRates = asyncHandler(async (_req: Request, res: Response) => {
  ok(res, await service.listExchangeRates());
});
