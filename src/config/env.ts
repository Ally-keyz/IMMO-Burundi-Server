import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config({ path: new URL('../../.env', import.meta.url) });

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']).default('development'),
  PORT: z.coerce.number().default(4000),
  MONGODB_URI: z.string().default('mongodb://127.0.0.1:27017/immo-burundi'),
  JWT_SECRET: z.string().min(16).default('change-me-access-secret'),
  REFRESH_TOKEN_SECRET: z.string().min(16).default('change-me-refresh-secret'),
  JWT_ACCESS_TTL: z.string().default('15m'),
  JWT_REFRESH_TTL: z.string().default('30d'),
  WEB_ORIGIN: z.string().default('http://localhost:5173'),
  GOOGLE_CLIENT_ID: z.string().optional(),
  GOOGLE_CLIENT_SECRET: z.string().optional(),
  SMTP_HOST: z.string().optional(),
  SMTP_PORT: z.coerce.number().int().min(1).max(65535).default(587),
  SMTP_SECURE: z.string().optional().transform((v) => v === 'true').default('false'),
  SMTP_USER: z.string().optional(),
  SMTP_PASSWORD: z.string().optional(),
  SMTP_FROM: z.string().optional(),
  SMTP_FROM_NAME: z.string().default('IMMO BURUNDI'),
  SETUP_ACCOUNT_TTL_HOURS: z.coerce.number().int().min(1).max(168).default(72),
  REDIS_URL: z.string().optional().default('redis://127.0.0.1:6379'),
  BULLMQ_ENABLED: z
    .string()
    .optional()
    .transform((v) => v === 'true')
    .default('false'),
  STORAGE_DRIVER: z.enum(['LOCAL', 'S3', 'CLOUDINARY']).default('LOCAL'),
  STORAGE_LOCAL_DIR: z.string().default('./data/storage'),
  STORAGE_ACCESS_KEY: z.string().optional(),
  STORAGE_SECRET_KEY: z.string().optional(),
  STORAGE_BUCKET: z.string().optional(),
  STORAGE_ENDPOINT: z.string().optional(),
  STORAGE_REGION: z.string().optional(),
  /**
   * Cloudinary holds every uploaded image. Render's filesystem is ephemeral,
   * so LOCAL loses profile photos and property media on each deploy; S3 was
   * never implemented. These three are required when the driver is CLOUDINARY.
   */
  CLOUDINARY_CLOUD_NAME: z.string().optional(),
  CLOUDINARY_API_KEY: z.string().optional(),
  CLOUDINARY_API_SECRET: z.string().optional(),
  /** Folder in the Cloudinary cloud that receives uploads. */
  CLOUDINARY_FOLDER: z.string().default('immo'),
  /**
   * Public origin of this API, e.g. https://immo-api.onrender.com.
   * When set, uploaded-file URLs are returned absolute instead of
   * backend-relative, which is what a separate web origin needs.
   */
  PUBLIC_BASE_URL: z.string().optional(),
  /**
   * Keep-warm for Render's free plan, which suspends the service after ~15
   * minutes of no traffic and then charges the next visitor ~1 minute of boot
   * time. When enabled the API pings itself on a timer; see config/keepWarm.ts.
   *
   * Must be the PUBLIC origin -- a loopback target is refused, because Render
   * only resets the idle timer for requests that reach its router.
   */
  KEEP_WARM_ENABLED: z
    .string()
    .optional()
    .transform((v) => v === 'true')
    .default('false'),
  /** Full URL to ping, e.g. https://immo-api.onrender.com/api/health. */
  KEEP_WARM_URL: z.string().optional(),
  KEEP_WARM_INTERVAL_MS: z.coerce.number().int().min(5_000).default(20_000),
  SEED_MAIN_ADMIN_PHONE: z.string().optional(),
  SEED_MAIN_ADMIN_EMAIL: z.string().optional(),
  SEED_MAIN_ADMIN_PASSWORD: z.string().optional(),
});

const PLACEHOLDER_SECRETS = new Set(['change-me-access-secret', 'change-me-refresh-secret']);

/**
 * The database name in a connection URI, or `''` when it carries none.
 *
 * This one has already cost a production deploy: a `mongodb+srv://` URI with no
 * path is legal and resolves to the database literally named "test". The API
 * boots, /api/health is green, every collection is created on connect — and the
 * whole site reads as "0 announcements, 0 provinces, 0 agents" while the real
 * data sits one path segment away in another database.
 */
export function databaseFromUri(uri: string): string {
  const schemeEnd = uri.indexOf('://');
  if (schemeEnd === -1) return '';
  const afterScheme = uri.slice(schemeEnd + 3);
  const slash = afterScheme.indexOf('/');
  if (slash === -1) return '';
  const withoutQuery = afterScheme.slice(slash + 1).split('?')[0] ?? '';
  return decodeURIComponent(withoutQuery);
}

const parsed = envSchema.parse(process.env);

/**
 * A production deploy must never fall back to the dev defaults. `MONGODB_URI`
 * silently pointing at 127.0.0.1 or a placeholder JWT secret produces a service
 * that boots, answers /api/health, and then fails every real request — so
 * refuse to start instead.
 */
function assertProductionSafe(): void {
  if (parsed.NODE_ENV !== 'production') return;

  const problems: string[] = [];

  if (!process.env.MONGODB_URI) {
    problems.push('MONGODB_URI is not set (it would default to mongodb://127.0.0.1:27017/immo-burundi)');
  } else if (!databaseFromUri(parsed.MONGODB_URI)) {
    problems.push(
      'MONGODB_URI names no database, so MongoDB would use "test". Append /immo-burundi to the URI.',
    );
  }

  for (const key of ['JWT_SECRET', 'REFRESH_TOKEN_SECRET'] as const) {
    const value = process.env[key];
    if (!value) problems.push(`${key} is not set`);
    else if (PLACEHOLDER_SECRETS.has(value)) problems.push(`${key} still holds its placeholder value`);
  }

  // Falling back to local disk here is the failure this project already hit:
  // uploads are accepted, returned as /uploads/<file>, and 404 from the second
  // deploy onwards. Fail loudly at boot instead.
  if (parsed.STORAGE_DRIVER === 'CLOUDINARY') {
    for (const key of [
      'CLOUDINARY_CLOUD_NAME',
      'CLOUDINARY_API_KEY',
      'CLOUDINARY_API_SECRET',
    ] as const) {
      if (!process.env[key]) problems.push(`${key} is not set but STORAGE_DRIVER=CLOUDINARY`);
    }
  }

  if (problems.length > 0) {
    throw new Error(
      `Refusing to start in production with an unsafe environment:\n  - ${problems.join('\n  - ')}`,
    );
  }
}

assertProductionSafe();

export const env = parsed;