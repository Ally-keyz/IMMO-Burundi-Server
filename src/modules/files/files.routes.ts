import { Router } from 'express';
import multer from 'multer';
import { authenticate } from '../../middleware/authenticate.js';
import { AppError } from '../../middleware/errorHandler.js';
import * as controller from './files.controller.js';

const router = Router();

router.post(
  '/upload',
  authenticate,
  (req, res, next) => {
    controller.upload.single('file')(req, res, (err: unknown) => {
      if (err) {
        const status =
          err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE' ? 413 : 400;
        next(new AppError(status, 'FILE_UPLOAD_ERROR', (err as Error).message));
        return;
      }
      next();
    });
  },
  controller.uploadImage,
);

export default router;