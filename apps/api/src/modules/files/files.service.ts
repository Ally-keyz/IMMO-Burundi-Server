import { mkdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { v4 as uuidv4 } from 'uuid';
import { AppError } from '../../middleware/errorHandler.js';
import { env } from '../../config/env.js';
import { FileModel } from '../../models/file.model.js';

export const MAX_IMAGE_BYTES = 5 * 1024 * 1024;

const ALLOWED_EXT: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'image/gif': 'gif',
};

const UPLOAD_DIR = path.resolve(process.cwd(), env.STORAGE_LOCAL_DIR);

export function ensureUploadDir(): void {
  mkdirSync(UPLOAD_DIR, { recursive: true });
}

export interface StoredFile {
  url: string;
  uuid: string;
  mimeType: string;
  size: number;
}

/**
 * `/uploads/<file>` is enough when the web app reverse-proxies the API
 * (netlify.toml, or the Vite dev server). When the API is served from its own
 * origin — the Netlify and Render split — a browser would resolve that path
 * against the *web* origin and 404, so return an absolute URL instead.
 */
function publicUrl(fileName: string): string {
  const base = env.PUBLIC_BASE_URL?.trim();
  if (!base) return `/uploads/${fileName}`;
  return `${base.replace(/\/+$/, '')}/uploads/${fileName}`;
}

export async function storeImage(
  buffer: Buffer,
  originalName: string,
  mimeType: string,
  uploadedBy: string,
): Promise<StoredFile> {
  const ext = ALLOWED_EXT[mimeType];
  if (!ext) {
    throw new AppError(
      400,
      'UNSUPPORTED_FILE_TYPE',
      `Unsupported file type "${mimeType}". Upload a JPEG, PNG, WEBP or GIF image.`,
    );
  }
  if (buffer.byteLength === 0) throw new AppError(400, 'EMPTY_FILE', 'The uploaded file is empty.');
  if (buffer.byteLength > MAX_IMAGE_BYTES) {
    throw new AppError(413, 'FILE_TOO_LARGE', 'Image must be 5 MB or smaller.');
  }

  ensureUploadDir();
  const uid = uuidv4();
  const fileName = `${uid}.${ext}`;
  writeFileSync(path.join(UPLOAD_DIR, fileName), buffer);

  await FileModel.create({
    uuid: uid,
    originalName: originalName || fileName,
    mimeType,
    size: buffer.byteLength,
    storageKey: fileName,
    visibility: 'PUBLIC',
    uploadedBy,
  });

  return { url: publicUrl(fileName), uuid: uid, mimeType, size: buffer.byteLength };
}