import { Request, Response } from 'express';
import multer from 'multer';
import { asyncHandler, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';
import { AppError } from '../../middleware/errorHandler.js';
import { storeImage, MAX_IMAGE_BYTES } from './files.service.js';

export const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_IMAGE_BYTES },
});

export const uploadImage = asyncHandler(async (req: Request, res: Response) => {
  requireUser(req);
  const file = (req as any).file as { buffer: Buffer; originalname: string; mimetype: string } | undefined;
  if (!file) {
    throw new AppError(400, 'FILE_REQUIRED', 'No file was provided. Multipart field name is "file".');
  }
  const stored = await storeImage(file.buffer, file.originalname, file.mimetype, (req as any).user?.sub ?? '');
  ok(res, stored);
});