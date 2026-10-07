/**
 * One-off media migration — moves images out of local disk storage and into
 * Cloudinary. `pnpm media:to-cloudinary -- [--dir <path>] [--apply]`
 *
 * Why this exists: STORAGE_DRIVER=LOCAL wrote every upload to
 * STORAGE_LOCAL_DIR, which on Render is the ephemeral filesystem. The bytes
 * were already gone on the first deploy, while the `files` collection and
 * `properties.media[].url` kept pointing at `/uploads/<uuid>.<ext>`.
 *
 * The script is a dry run unless `--apply` is passed, so it is safe to point at
 * a production cluster. It is idempotent: an asset whose public id already
 * carries a folder (i.e. already migrated) is skipped, and re-uploading the
 * same public id overwrites in place.
 *
 * Credentials come from the environment (CLOUDINARY_CLOUD_NAME,
 * CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET); the database comes from
 * MONGODB_URI. Nothing is read from or written to a committed file.
 */
import crypto from 'node:crypto';
import { existsSync, readFileSync } from 'node:fs';
import path from 'node:path';
import mongoose from 'mongoose';
import { env } from '../config/env.js';

/** `<uuid>.<ext>` — a LOCAL-driver storageKey. A migrated one contains a '/'. */
const LOCAL_KEY = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.[a-z0-9]+$/i;

/**
 * The LOCAL driver named files `<uuid>.<ext>`, and the originalName/mimeType is
 * all that is left to rebuild that name once storageKey has been overwritten
 * with a public id.
 */
const EXT_BY_MIME: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/jfif': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'image/gif': 'gif',
};

interface Remap {
  publicId: string;
  secureUrl: string;
}

function parseArgs(): { localDir: string; apply: boolean } {
  const argv = process.argv.slice(2);
  const dirFlag = argv.indexOf('--dir');
  const localDir = path.resolve(
    dirFlag !== -1 && argv[dirFlag + 1] ? argv[dirFlag + 1]! : env.STORAGE_LOCAL_DIR,
  );
  return { localDir, apply: argv.includes('--apply') };
}

function requireCreds(): { cloud: string; key: string; secret: string } {
  const cloud = env.CLOUDINARY_CLOUD_NAME;
  const key = env.CLOUDINARY_API_KEY;
  const secret = env.CLOUDINARY_API_SECRET;
  if (!cloud || !key || !secret) {
    throw new Error(
      'CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY and CLOUDINARY_API_SECRET must all be set.',
    );
  }
  return { cloud, key, secret };
}

async function upload(
  creds: { cloud: string; key: string; secret: string },
  buffer: Buffer,
  publicId: string,
  ext: string,
): Promise<Remap> {
  const folder = publicId.slice(0, publicId.lastIndexOf('/'));
  const timestamp = Math.floor(Date.now() / 1000).toString();
  // overwrite + invalidate keep a re-run idempotent: the public id is stable,
  // so a second pass replaces the asset instead of failing on "already exists".
  const params: Record<string, string> = {
    folder,
    invalidate: '1',
    overwrite: 'true',
    public_id: publicId.slice(publicId.lastIndexOf('/') + 1),
    timestamp,
  };
  const signature = crypto
    .createHash('sha1')
    .update(
      `${Object.keys(params)
        .sort()
        .map((k) => `${k}=${params[k]}`)
        .join('&')}${creds.secret}`,
    )
    .digest('hex');

  const body = new FormData();
  body.append(
    'file',
    new Blob([new Uint8Array(buffer)]),
    `${params.public_id}.${ext}`,
  );
  for (const [k, v] of Object.entries(params)) body.append(k, v);
  body.append('api_key', creds.key);
  body.append('signature', signature);

  const res = await fetch(`https://api.cloudinary.com/v1_1/${creds.cloud}/image/upload`, {
    method: 'POST',
    body,
  });
  const json = (await res.json().catch(() => null)) as
    | { secure_url?: string; public_id?: string; error?: { message?: string } }
    | null;
  if (!res.ok || !json?.secure_url) {
    throw new Error(
      `Cloudinary upload failed (${res.status}): ${json?.error?.message ?? 'unknown error'}`,
    );
  }
  return { publicId: json.public_id ?? publicId, secureUrl: json.secure_url };
}

/**
 * Collects the leaf paths that name a migrated file, e.g. `media.fileKey` and
 * `media.url` on a property.
 *
 * Only the paths are returned — the documents themselves are never rebuilt.
 * Re-serialising a whole document turns every BSON value it contains (ObjectId,
 * Decimal128, Date) into a plain object, and the replacement is then rejected
 * because `_id` no longer looks immutable to the server. Updating the leaves in
 * place leaves every other BSON value untouched.
 */
function findMediaRefs(
  value: unknown,
  map: Map<string, Remap>,
  prefix: string,
  arrayPath: string,
  out: Map<string, { filterPath: string; targetPath: string; key: string }>,
): void {
  if (typeof value === 'string') {
    const bare = value.startsWith('/uploads/') ? value.slice('/uploads/'.length) : value;
    if (prefix && map.has(bare)) {
      // Inside an array the update path needs the positional operator between
      // the array and the leaf: media.$.fileKey, never media.fileKey.$.
      const leaf = prefix.split('.').pop()!;
      const inArray = arrayPath.length > 0;
      const isArrayElement = inArray && prefix === arrayPath;
      const filterPath = !inArray ? prefix : isArrayElement ? arrayPath : `${arrayPath}.${leaf}`;
      const targetPath = !inArray
        ? prefix
        : isArrayElement
          ? `${arrayPath}.$`
          : `${arrayPath}.$.${leaf}`;
      out.set(`${filterPath} ${bare}`, { filterPath, targetPath, key: bare });
    }
    return;
  }
  if (Array.isArray(value)) {
    for (const item of value) findMediaRefs(item, map, prefix, prefix || arrayPath, out);
    return;
  }
  if (value && typeof value === 'object') {
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      if (k === '_id' || k === '__v') continue;
      findMediaRefs(v, map, prefix ? `${prefix}.${k}` : k, arrayPath, out);
    }
  }
}

async function main(): Promise<void> {
  const { localDir, apply } = parseArgs();
  const creds = requireCreds();

  await mongoose.connect(env.MONGODB_URI);
  const db = mongoose.connection.db;
  if (!db) throw new Error('No database handle.');

  const folder = env.CLOUDINARY_FOLDER;
  const fileDocs = await db.collection('files').find({}).toArray();

  const map = new Map<string, Remap>();
  const missing: string[] = [];
  const planned: string[] = [];
  let alreadyMigrated = 0;

  for (const doc of fileDocs) {
    const storageKey = String(doc.storageKey ?? '');
    const uuid = String(doc.uuid ?? storageKey.replace(/\.[a-z0-9]+$/i, ''));
    const ext = EXT_BY_MIME[String(doc.mimeType ?? '')] ?? 'jpg';
    // The local filename the documents out in the wild still reference.
    const localKey = `${uuid}.${ext}`;

    if (storageKey.includes('/')) {
      // A previous run already moved this row. Re-derive its mapping so the
      // reference sweep below still finds documents pointing at the old
      // /uploads/<uuid>.<ext> path.
      alreadyMigrated += 1;
      map.set(localKey, {
        publicId: storageKey,
        secureUrl: `https://res.cloudinary.com/${creds.cloud}/image/upload/${storageKey}`,
      });
      continue;
    }

    if (!LOCAL_KEY.test(storageKey)) continue;

    const filePath = path.join(localDir, storageKey);
    if (!existsSync(filePath)) {
      missing.push(`${storageKey} (${String(doc.originalName ?? '?')})`);
      continue;
    }
    const publicId = `${folder}/uploads/${uuid}`;
    if (apply) {
      console.log(`[upload] ${storageKey} -> ${publicId}`);
      map.set(storageKey, await upload(creds, readFileSync(filePath), publicId, ext));
    } else {
      console.log(`[plan] ${storageKey} -> ${publicId}`);
      planned.push(storageKey);
    }
  }

  console.log(
    `\nmigrated=${map.size} alreadyOnCloudinary=${alreadyMigrated} missingOnDisk=${missing.length}`,
  );
  if (missing.length) {
    console.log('no bytes on disk, row left untouched:');
    for (const m of missing) console.log(`  - ${m}`);
  }

  if (!apply) {
    console.log('\nDRY RUN — nothing uploaded, nothing written.');
    console.log(`would upload ${planned.length} file(s) and rewrite references to them`);
    await mongoose.disconnect();
    return;
  }

  for (const [storageKey, remap] of map) {
    const res = await db
      .collection('files')
      .updateMany({ storageKey }, { $set: { storageKey: remap.publicId } });
    if (res.modifiedCount) console.log(`[db] files.storageKey ${storageKey} -> ${remap.publicId}`);
  }

  // Sweep every collection: a filename can be embedded in any document.
  const collections = await db.listCollections().toArray();
  let touched = 0;
  for (const { name } of collections) {
    if (name === 'files') continue;
    const found = new Map<string, { filterPath: string; targetPath: string; key: string }>();
    for (const doc of await db.collection(name).find({}).toArray()) {
      findMediaRefs(doc, map, '', '', found);
    }
    for (const { filterPath, targetPath, key } of found.values()) {
      const remap = map.get(key)!;
      // `fileKey` names the asset; every other field is the URL to load.
      const next = filterPath.endsWith('fileKey') ? remap.publicId : remap.secureUrl;
      const res = await db
        .collection(name)
        .updateMany(
          { [filterPath]: { $in: [`/uploads/${key}`, key] } },
          { $set: { [targetPath]: next } },
        );
      if (res.modifiedCount) {
        console.log(`[db] ${name}.${targetPath} (${res.modifiedCount}) -> ${next}`);
        touched += res.modifiedCount;
      }
    }
  }
  console.log(`[db] rewrote ${touched} references across ${collections.length} collections`);

  await mongoose.disconnect();
  console.log('\nDone.');
}

main().catch((err) => {
  console.error('[MIGRATE] Failed:', err);
  process.exit(1);
});
