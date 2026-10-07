import crypto from 'node:crypto';
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
 *
 * Only the LOCAL driver needs this: Cloudinary already hands back an absolute
 * `https://res.cloudinary.com/...` URL that resolves from any origin.
 */
function publicUrl(fileName: string): string {
  const base = env.PUBLIC_BASE_URL?.trim();
  if (!base) return `/uploads/${fileName}`;
  return `${base.replace(/\/+$/, '')}/uploads/${fileName}`;
}

interface CloudinaryUpload {
  publicId: string;
  secureUrl: string;
}

/**
 * Signed upload to the configured cloud. Cloudinary is the production store:
 * Render's filesystem is ephemeral, so a file written to STORAGE_LOCAL_DIR is
 * gone on the next deploy and every stored URL 404s. Uses the signed REST
 * endpoint rather than the SDK so the dependency tree stays unchanged.
 */
async function uploadToCloudinary(
  buffer: Buffer,
  uid: string,
  ext: string,
): Promise<CloudinaryUpload> {
  const cloud = env.CLOUDINARY_CLOUD_NAME;
  const apiKey = env.CLOUDINARY_API_KEY;
  const apiSecret = env.CLOUDINARY_API_SECRET;
  if (!cloud || !apiKey || !apiSecret) {
    throw new AppError(
      500,
      'STORAGE_NOT_CONFIGURED',
      'STORAGE_DRIVER is CLOUDINARY but CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY or CLOUDINARY_API_SECRET is missing.',
    );
  }

  const folder = `${env.CLOUDINARY_FOLDER}/uploads`;
  const publicId = uid;
  const timestamp = Math.floor(Date.now() / 1000).toString();
  // Cloudinary signs the sorted parameter list plus the secret.
  const signature = crypto
    .createHash('sha1')
    .update(
      `folder=${folder}&public_id=${publicId}&timestamp=${timestamp}${apiSecret}`,
    )
    .digest('hex');

  const body = new FormData();
  body.append('file', new Blob([new Uint8Array(buffer)]), `${publicId}.${ext}`);
  body.append('api_key', apiKey);
  body.append('timestamp', timestamp);
  body.append('folder', folder);
  body.append('public_id', publicId);
  body.append('signature', signature);

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 30_000);
  try {
    const res = await fetch(`https://api.cloudinary.com/v1_1/${cloud}/image/upload`, {
      method: 'POST',
      body,
      signal: controller.signal,
    });
    const json = (await res.json().catch(() => null)) as
      | { secure_url?: string; public_id?: string; error?: { message?: string } }
      | null;
    if (!res.ok || !json?.secure_url) {
      throw new AppError(
        502,
        'STORAGE_UPLOAD_FAILED',
        `Cloudinary rejected the upload (${res.status}): ${json?.error?.message ?? 'unknown error'}`,
      );
    }
    return { publicId: json.public_id ?? `${folder}/${publicId}`, secureUrl: json.secure_url };
  } catch (err) {
    if (err instanceof AppError) throw err;
    throw new AppError(502, 'STORAGE_UPLOAD_FAILED', 'Cloudinary upload failed.');
  } finally {
    clearTimeout(timer);
  }
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
  if (env.STORAGE_DRIVER === 'S3') {
    throw new AppError(501, 'STORAGE_DRIVER_UNSUPPORTED', 'STORAGE_DRIVER=S3 is not implemented.');
  }

  const uid = uuidv4();
  const fileName = `${uid}.${ext}`;

  let storageKey = fileName;
  let url = publicUrl(fileName);

  if (env.STORAGE_DRIVER === 'CLOUDINARY') {
    const uploaded = await uploadToCloudinary(buffer, uid, ext);
    // The key is the public id, so a later migration or delete addresses the
    // exact asset; the document also keeps the absolute secure_url.
    storageKey = uploaded.publicId;
    url = uploaded.secureUrl;
  } else {
    ensureUploadDir();
    writeFileSync(path.join(UPLOAD_DIR, fileName), buffer);
  }

  await FileModel.create({
    uuid: uid,
    originalName: originalName || fileName,
    mimeType,
    size: buffer.byteLength,
    storageKey,
    visibility: 'PUBLIC',
    uploadedBy,
  });

  return { url, uuid: uid, mimeType, size: buffer.byteLength };
}