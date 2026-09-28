import { NextFunction, Request, RequestHandler, Response } from 'express';

/** Wraps an async route handler so rejected promises reach the error handler. */
export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>,
): RequestHandler {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

export interface PaginationMeta {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
}

export function ok(res: Response, data: unknown, meta?: PaginationMeta): void {
  res.status(200).json({ success: true, data, ...(meta ? { meta } : {}) });
}

export function created(res: Response, data: unknown): void {
  res.status(201).json({ success: true, data });
}

export function parsePagination(query: any): { page: number; pageSize: number; skip: number } {
  const page = Math.max(1, Number(query?.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query?.pageSize) || 20));
  return { page, pageSize, skip: (page - 1) * pageSize };
}

export function paginationMeta(page: number, pageSize: number, total: number): PaginationMeta {
  return { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) };
}
