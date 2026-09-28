/**
 * Development seed script — `pnpm --filter @immo/api db:seed`.
 * Drops the database, then seeds roles, permissions, geography, an admin
 * account and a set of demo agents / properties / visit sessions. When
 * CLOUDINARY_* credentials are present the property photos (real Unsplash
 * house photography) are pushed to the cloud; otherwise they fall back to
 * the remote source URLs.
 */
import mongoose from 'mongoose';
import bcrypt from 'bcrypt';
import crypto from 'node:crypto';
import { env } from '../config/env.js';
import { connectDB, disconnectDB } from '../config/db.js';
import {
  PERMISSIONS,
  ROLE_DEFAULT_MATRIX,
  USER_ROLES,
  type UserRole,
} from '@immo/shared-types';

import { User } from '../models/users.model.js';
import { Role } from '../models/role.model.js';
import { Permission } from '../models/permission.model.js';
import { RolePermission } from '../models/rolePermission.model.js';
import { Province } from '../models/province.model.js';
import { Commune } from '../models/commune.model.js';
import { Zone } from '../models/zone.model.js';
import { Agent } from '../models/agent.model.js';
import { Client } from '../models/client.model.js';
import { Property } from '../models/property.model.js';
import { VisitSession } from '../models/visitSession.model.js';
import { ExchangeRate } from '../models/exchangeRate.model.js';
import { generatePropertyId, generateAgentCode } from '../helpers/codeGenerators.js';

const UNS = 'auto=format&fit=crop&w=1400&q=80';

/**
 * Real property photography (stable Unsplash CDN URLs). Uploaded to the
 * configured Cloudinary cloud at seed time when credentials are present,
 * otherwise used directly as remote URLs.
 */
const IMAGE_POOL: string[] = [
  // HOUSES — 0..9
  `https://images.unsplash.com/photo-1568605114967-8130f3a36994?${UNS}`,
  `https://images.unsplash.com/photo-1570129477492-45c003edd2be?${UNS}`,
  `https://images.unsplash.com/photo-1600585154340-be6161a56a0c?${UNS}`,
  `https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?${UNS}`,
  `https://images.unsplash.com/photo-1564013799919-ab600027ffc6?${UNS}`,
  `https://images.unsplash.com/photo-1580587771525-78b9dba3b914?${UNS}`,
  `https://images.unsplash.com/photo-1512917774080-9991f1c4c750?${UNS}`,
  `https://images.unsplash.com/photo-1592595896551-12b371d546d5?${UNS}`,
  `https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?${UNS}`,
  `https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?${UNS}`,
  // APARTMENTS — 10..16
  `https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?${UNS}`,
  `https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?${UNS}`,
  `https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?${UNS}`,
  `https://images.unsplash.com/photo-1493809842364-78817add7ffb?${UNS}`,
  `https://images.unsplash.com/photo-1519389950473-47ba0277781c?${UNS}`,
  `https://images.unsplash.com/photo-1524758631624-e2822e304c36?${UNS}`,
  `https://images.unsplash.com/photo-1490885578174-acda8905c2c6?${UNS}`,
  // VILLAS — 17..21
  `https://images.unsplash.com/photo-1613490493576-7fde63acd811?${UNS}`,
  `https://images.unsplash.com/photo-1574362848149-11496d93a7c7?${UNS}`,
  `https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?${UNS}`,
  `https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?${UNS}`,
  `https://images.unsplash.com/photo-1598928506311-c55ded91a20c?${UNS}`,
  // LAND — 22..25
  `https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?${UNS}`,
  `https://images.unsplash.com/photo-1500382017468-9049fed747ef?${UNS}`,
  `https://images.unsplash.com/photo-1500076656116-558758c991c1?${UNS}`,
  `https://images.unsplash.com/photo-1441974231531-c6227db76b6e?${UNS}`,
  // COMMERCIAL — 26..31
  `https://images.unsplash.com/photo-1560179707-f14e90ef3623?${UNS}`,
  `https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?${UNS}`,
  `https://images.unsplash.com/photo-1497366216548-37526070297c?${UNS}`,
  `https://images.unsplash.com/photo-1497215728101-856f4ea42174?${UNS}`,
  `https://images.unsplash.com/photo-1497366754035-f200968a6e72?${UNS}`,
  `https://images.unsplash.com/photo-1497366811353-6870744d04b2?${UNS}`,
  // GUEST HOUSE / HOTEL — 32..33
  `https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?${UNS}`,
  `https://images.unsplash.com/photo-1566073771259-6a8506099945?${UNS}`,
];

const PROVINCE_COORDS: Record<string, [number, number]> = {
  BJM: [-3.3822, 29.3644],
  GIT: [-3.4264, 29.9255],
  NGO: [-2.9085, 29.8256],
  MUY: [-2.8451, 30.3414],
  RUM: [-3.9736, 29.4386],
  BUR: [-3.9501, 29.6193],
  KAY: [-2.9221, 29.5608],
  CIB: [-2.8876, 29.1228],
  BUB: [-3.0908, 29.3968],
  RUV: [-3.4763, 30.2485],
  MAK: [-4.1337, 29.795],
  MUR: [-3.2738, 29.6088],
};

/** Upload-in-progress cache so each unique image is only pushed once. */
const uploadedCache = new Map<string, string>();

function cloudinaryCreds(): { cloud: string; key: string; secret: string } | null {
  const cloud = process.env.CLOUDINARY_CLOUD_NAME;
  const key = process.env.CLOUDINARY_API_KEY;
  const secret = process.env.CLOUDINARY_API_SECRET;
  if (!cloud || !key || !secret) return null;
  if (process.env.SEED_CLOUDINARY_UPLOAD === 'false') return null;
  return { cloud, key, secret };
}

/** Upload a remote image to Cloudinary; falls back to the source URL. */
async function resolveImage(source: string, index: number): Promise<string> {
  const cached = uploadedCache.get(source);
  if (cached) return cached;
  const creds = cloudinaryCreds();
  let finalUrl = source;
  if (creds) {
    try {
      const timestamp = Math.floor(Date.now() / 1000).toString();
      const publicId = `property-${String(index).padStart(3, '0')}`;
      const params: Record<string, string> = {
        folder: 'seed',
        timestamp,
        public_id: publicId,
      };
      const toSign =
        Object.keys(params)
          .sort()
          .map((k) => `${k}=${params[k]}`)
          .join('&') + creds.secret;
      const signature = crypto.createHash('sha1').update(toSign).digest('hex');
      const body = new FormData();
      body.append('file', source);
      body.append('timestamp', timestamp);
      body.append('api_key', creds.key);
      body.append('public_id', publicId);
      body.append('folder', 'seed');
      body.append('signature', signature);
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), 20000);
      const res = await fetch(`https://api.cloudinary.com/v1_1/${creds.cloud}/image/upload`, {
        method: 'POST',
        body,
        signal: controller.signal,
      });
      clearTimeout(timer);
      if (res.ok) {
        const json: any = await res.json();
        finalUrl = json.secure_url ?? json.url ?? source;
        console.log(`[SEED] Cloudinary upload ok: ${finalUrl}`);
      } else {
        console.warn(`[SEED] Cloudinary upload failed (${res.status}), using remote URL.`);
      }
    } catch {
      console.warn('[SEED] Cloudinary upload error, using remote URL.');
    }
  }
  uploadedCache.set(source, finalUrl);
  return finalUrl;
}

const PROVINCES: { name: string; code: string; communes: string[] }[] = [
  { name: 'Bujumbura Mairie', code: 'BJM', communes: ['Mukaza', 'Ntahangwa', 'Muha'] },
  { name: 'Gitega', code: 'GIT', communes: ['Gitega', 'Bugendana', 'Gishubi', 'Makebuko'] },
  { name: 'Ngozi', code: 'NGO', communes: ['Ngozi', 'Busiga', 'Kiremba', 'Mwumba'] },
  { name: 'Muyinga', code: 'MUY', communes: ['Muyinga', 'Butihinda', 'Gasorwe', 'Giteranyi'] },
  { name: 'Rumonge', code: 'RUM', communes: ['Rumonge', 'Burambi', 'Muhuta'] },
  { name: 'Bururi', code: 'BUR', communes: ['Bururi', 'Matana', 'Rutovu', 'Vyanda'] },
  { name: 'Kayanza', code: 'KAY', communes: ['Kayanza', 'Gatara', 'Matongo', 'Muruta'] },
  { name: 'Cibitoke', code: 'CIB', communes: ['Cibitoke', 'Bukinanyana', 'Mabayi', 'Murwi'] },
  { name: 'Bubanza', code: 'BUB', communes: ['Bubanza', 'Gihanga', 'Musigati', 'Rugazi'] },
  { name: 'Cankuzo', code: 'CAN', communes: ['Cankuzo', 'Cendajuru', 'Kigamba'] },
  { name: 'Kirundo', code: 'KIR', communes: ['Kirundo', 'Busoni', 'Gitobe', 'Ntega'] },
  { name: 'Makamba', code: 'MAK', communes: ['Makamba', 'Kibago', 'Nyanza-Lac', 'Vugizo'] },
  { name: 'Muramvya', code: 'MUR', communes: ['Muramvya', 'Bukeye', 'Kiganda', 'Rutegama'] },
  { name: 'Mwaro', code: 'MWA', communes: ['Mwaro', 'Bisoro', 'Gisozi', 'Nyabihanga'] },
  { name: 'Ruyigi', code: 'RUY', communes: ['Ruyigi', 'Butaganzwa', 'Gisuru', 'Kinyinya'] },
];

/**
 * Hosts that are safe to wipe without ceremony. Anything else is treated as
 * a real environment and requires an explicit opt-in, so that a stray
 * MONGODB_URI pointing at production cannot be destroyed by a routine
 * `pnpm db:seed`.
 */
const LOCAL_HOSTS = new Set(['127.0.0.1', 'localhost', '::1', '0.0.0.0']);

function targetHost(): string {
  try {
    return new URL(env.MONGODB_URI).hostname;
  } catch {
    return '(unparseable)';
  }
}

async function dropDatabase(): Promise<void> {
  const host = targetHost();
  const isLocal = LOCAL_HOSTS.has(host);
  const allowProduction = process.env.SEED_ALLOW_PRODUCTION === 'true';

  if (env.NODE_ENV === 'production' && !allowProduction) {
    throw new Error(
      'Refusing to drop the database in production.\n' +
        'This script DROPS the entire database before seeding. To seed a\n' +
        'production cluster deliberately, re-run with SEED_ALLOW_PRODUCTION=true\n' +
        'and double-check MONGODB_URI points where you think it does.',
    );
  }

  if (!isLocal && !allowProduction) {
    throw new Error(
      `Refusing to drop the non-local database at "${host}" without SEED_ALLOW_PRODUCTION=true.\n` +
        'This script DROPS the entire database before seeding.',
    );
  }

  if (!isLocal) {
    console.warn(
      `[SEED] WARNING: dropping ALL data in "${env.MONGODB_URI.replace(/\/\/([^@/]+)@/, '//***:***@')}"`,
    );
  }

  await mongoose.connection.db?.dropDatabase();
  console.log('[SEED] Dropped database');
}

async function seedRoles() {
  const docs = await Role.insertMany(
    USER_ROLES.map((name) => ({ name, isSystemRole: true, description: `${name} system role` })),
  );
  const map = new Map<string, any>();
  for (const doc of docs) map.set((doc as any).name, doc);
  console.log(`[SEED] Roles: ${docs.length}`);
  return map;
}

async function seedPermissions() {
  const docs = await Permission.insertMany(
    PERMISSIONS.map((code) => {
      const [resource, action] = code.split('.');
      return {
        code,
        resource,
        action,
        name: `${resource} ${action}`.replace(/_/g, ' '),
        description: `Allows ${action?.replace(/_/g, ' ')} on ${resource}`,
      };
    }),
  );
  const map = new Map<string, any>();
  for (const doc of docs) map.set((doc as any).code, doc);
  console.log(`[SEED] Permissions: ${docs.length}`);
  return map;
}

async function seedRolePermissions(roles: Map<string, any>, permissions: Map<string, any>, provinceId: any, communeId: any) {
  const entries: any[] = [];
  for (const [roleName, grants] of Object.entries(ROLE_DEFAULT_MATRIX)) {
    const role = roles.get(roleName);
    if (!role) continue;
    for (const grant of grants as { permission: string; scope: string }[]) {
      const permission = permissions.get(grant.permission);
      if (!permission) continue;
      entries.push({
        roleId: role._id,
        permissionId: permission._id,
        scope: grant.scope,
        provinceId: grant.scope === 'PROVINCE' ? provinceId : undefined,
        communeId: grant.scope === 'COMMUNE' ? communeId : undefined,
      });
    }
  }
  await RolePermission.insertMany(entries);
  console.log(`[SEED] Role permissions: ${entries.length}`);
}

async function seedGeo() {
  const provinces: any[] = [];
  const communes: any[] = [];
  for (const province of PROVINCES) {
    const provinceDoc = await Province.create({ name: province.name, code: province.code });
    provinces.push(provinceDoc);
    for (let i = 0; i < province.communes.length; i += 1) {
      const communeDoc = await Commune.create({
        name: province.communes[i],
        code: `${province.code}-C${String(i + 1).padStart(2, '0')}`,
        provinceId: provinceDoc._id,
      });
      communes.push(communeDoc);
      await Zone.create({
        name: `${province.communes[i]} Centre`,
        code: `${province.code}-Z${String(i + 1).padStart(2, '0')}`,
        communeId: communeDoc._id,
      });
    }
  }
  console.log(`[SEED] Provinces: ${provinces.length}, Communes: ${communes.length}`);
  return { provinces, communes };
}

/**
 * Placeholder values that must never be used for a real deployment.
 * Kept in source (rather than falling back to one of them) so that a
 * missing or unchanged value fails loudly instead of silently creating a
 * super-admin account whose password is public knowledge.
 */
const REJECTED_SEED_PASSWORDS = new Set([
  'changeme123!',
  'change-me-before-deploying',
  'password',
  'admin',
]);

async function seedAdmin(roles: Map<string, any>) {
  const phone = env.SEED_MAIN_ADMIN_PHONE || '+25779000000';
  const email = env.SEED_MAIN_ADMIN_EMAIL || 'admin@immoburundi.bi';
  const password = env.SEED_MAIN_ADMIN_PASSWORD;

  if (!password || REJECTED_SEED_PASSWORDS.has(password.toLowerCase())) {
    throw new Error(
      'SEED_MAIN_ADMIN_PASSWORD must be set to a strong, unique value before seeding. ' +
        'Refusing to create a MAIN_ADMIN account with a known or placeholder password.',
    );
  }
  if (password.length < 12) {
    throw new Error('SEED_MAIN_ADMIN_PASSWORD must be at least 12 characters long.');
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const role = roles.get('MAIN_ADMIN');

  const admin = await User.create({
    firstName: 'Main',
    lastName: 'Admin',
    phone,
    email,
    passwordHash,
    role: 'MAIN_ADMIN',
    roleId: role?._id,
    preferredLanguage: 'fr',
    preferredCurrency: 'BIF',
    status: 'ACTIVE',
    phoneVerifiedAt: new Date(),
    emailVerifiedAt: new Date(),
  });
  // Never echo the password — seed output lands in CI logs and shell history.
  console.log(`[SEED] Main admin: ${phone} (password taken from SEED_MAIN_ADMIN_PASSWORD, not logged)`);
  return admin;
}

async function seedDemo(provinces: any[], communes: any[]) {
  const agentsData = [
    { firstName: 'Aline', lastName: 'Ndayishimiye', phone: '+25779111001', agency: 'Bujumbura Homes' },
    { firstName: 'Eric', lastName: 'Nkurunziza', phone: '+25779111002', agency: 'Immo Centre' },
  ];

  const bjm = provinces.find((p) => p.code === 'BJM') ?? provinces[0];
  const bjmCommunes = communes.filter((c) => String(c.provinceId) === String(bjm._id));

  const agents: any[] = [];
  const agentUsers: any[] = [];
  for (const data of agentsData) {
    const passwordHash = await bcrypt.hash('AgentDemo123!', 12);
    const user = await User.create({
      firstName: data.firstName,
      lastName: data.lastName,
      phone: data.phone,
      email: `${data.firstName.toLowerCase()}@immo-demo.bi`,
      passwordHash,
      role: 'FIELD_AGENT',
      preferredLanguage: 'fr',
      preferredCurrency: 'BIF',
      status: 'ACTIVE',
    });
    const agentCode = await generateAgentCode('BJM');
    const agent = await Agent.create({
      userId: user._id,
      agentCode,
      agencyName: data.agency,
      provinceId: bjm._id,
      communeId: bjmCommunes[0]?._id,
      status: 'ACTIVE',
      topAgent: agents.length === 0,
      rating: 4.5,
      totalProperties: 1,
    });
    agents.push(agent);
    agentUsers.push(user);
  }

  const propertySeeds: any[] = [
    { title: 'Villa moderne avec jardin à Bujumbura', fr: 'Villa moderne avec jardin à Bujumbura', propertyType: 'VILLA', listingType: 'SALE', price: 285000000, surfaceArea: 320, bedrooms: 5, bathrooms: 3, provinceCode: 'BJM', communeIdx: 0, imgStart: 17, verified: true, featured: true },
    { title: 'Appartement meublé au centre-ville', fr: 'Appartement meublé au centre-ville', propertyType: 'APARTMENT', listingType: 'RENT', price: 1200000, surfaceArea: 110, bedrooms: 2, bathrooms: 2, provinceCode: 'BJM', communeIdx: 1, imgStart: 10, verified: true },
    { title: 'Terrain constructible proche du lac', fr: 'Terrain constructible proche du lac', propertyType: 'LAND', listingType: 'SALE', price: 95000000, surfaceArea: 800, bedrooms: 0, bathrooms: 0, provinceCode: 'BJM', communeIdx: 2, imgStart: 22, verified: true },
    { title: 'Villa de luxe avec piscine à Kiriri', fr: 'Villa de luxe avec piscine à Kiriri', propertyType: 'VILLA', listingType: 'SALE', price: 550000000, surfaceArea: 450, bedrooms: 6, bathrooms: 5, provinceCode: 'BJM', communeIdx: 3, imgStart: 17, verified: true },
    { title: 'Maison familiale à Rohero', fr: 'Maison familiale à Rohero', propertyType: 'HOUSE', listingType: 'SALE', price: 265000000, surfaceArea: 260, bedrooms: 4, bathrooms: 3, provinceCode: 'BJM', communeIdx: 4, imgStart: 0, verified: true },
    { title: 'Appartement duplex à Kigobe', fr: 'Appartement duplex à Kigobe', propertyType: 'APARTMENT', listingType: 'SALE', price: 180000000, surfaceArea: 160, bedrooms: 3, bathrooms: 2, provinceCode: 'BJM', communeIdx: 5, imgStart: 11, verified: true },
    { title: 'Maison avec véranda à Mutanga', fr: 'Maison avec véranda à Mutanga', propertyType: 'HOUSE', listingType: 'SALE', price: 310000000, surfaceArea: 300, bedrooms: 5, bathrooms: 3, provinceCode: 'BJM', communeIdx: 6, imgStart: 1 },
    { title: 'Petit studio meublé à Kanyosha', fr: 'Petit studio meublé à Kanyosha', propertyType: 'APARTMENT', listingType: 'RENT', price: 450000, surfaceArea: 45, bedrooms: 1, bathrooms: 1, provinceCode: 'BJM', communeIdx: 7, imgStart: 12 },
    { title: 'Bureaux à louer au centre-ville', fr: 'Bureaux à louer au centre-ville', propertyType: 'OFFICE', listingType: 'RENT', price: 2500000, surfaceArea: 180, bedrooms: 0, bathrooms: 2, provinceCode: 'BJM', communeIdx: 8, imgStart: 29 },
    { title: 'Boutique commerciale à Ngagara', fr: 'Boutique commerciale à Ngagara', propertyType: 'SHOP', listingType: 'RENT', price: 3500000, surfaceArea: 60, bedrooms: 0, bathrooms: 1, provinceCode: 'BJM', communeIdx: 9, imgStart: 27 },
    { title: 'Guest house avec vue sur le lac', fr: 'Guest house avec vue sur le lac', propertyType: 'GUEST_HOUSE', listingType: 'SALE', price: 420000000, surfaceArea: 380, bedrooms: 5, bathrooms: 4, provinceCode: 'BJM', communeIdx: 10, imgStart: 32 },
    { title: 'Petit hôtel en bordure de plage', fr: 'Petit hôtel en bordure de plage', propertyType: 'HOTEL', listingType: 'SALE', price: 1200000000, surfaceArea: 1200, bedrooms: 12, bathrooms: 10, provinceCode: 'BJM', communeIdx: 11, imgStart: 32, verified: true, promoted: true },
    { title: 'Magasin au marché central', fr: 'Magasin au marché central', propertyType: 'SHOP', listingType: 'SALE', price: 135000000, surfaceArea: 90, bedrooms: 0, bathrooms: 1, provinceCode: 'BJM', communeIdx: 12, imgStart: 26 },
    { title: 'Bureau spacieux avec terrasse', fr: 'Bureau spacieux avec terrasse', propertyType: 'OFFICE', listingType: 'SALE', price: 275000000, surfaceArea: 240, bedrooms: 0, bathrooms: 3, provinceCode: 'BJM', communeIdx: 13, imgStart: 28 },
    { title: 'Maison de ville à Gatoke', fr: 'Maison de ville à Gatoke', propertyType: 'HOUSE', listingType: 'SALE', price: 198000000, surfaceArea: 210, bedrooms: 3, bathrooms: 2, provinceCode: 'BJM', communeIdx: 14, imgStart: 2 },
    { title: 'Terrain à Ntahangwa', fr: 'Terrain à Ntahangwa', propertyType: 'LAND', listingType: 'SALE', price: 75000000, surfaceArea: 600, bedrooms: 0, bathrooms: 0, provinceCode: 'BJM', communeIdx: 15, imgStart: 22 },
    { title: 'Appartement avec parking à Kinindo', fr: 'Appartement avec parking à Kinindo', propertyType: 'APARTMENT', listingType: 'SALE', price: 150000000, surfaceArea: 140, bedrooms: 2, bathrooms: 2, provinceCode: 'BJM', communeIdx: 5, imgStart: 13, verified: true },
    { title: 'Studio meublé à Cibitoke', fr: 'Studio meublé à Cibitoke', propertyType: 'APARTMENT', listingType: 'RENT', price: 600000, surfaceArea: 50, bedrooms: 1, bathrooms: 1, provinceCode: 'BJM', communeIdx: 6, imgStart: 14, partial: true },
    { title: 'Maison moderne à Kanyosha', fr: 'Maison moderne à Kanyosha', propertyType: 'HOUSE', listingType: 'SALE', price: 225000000, surfaceArea: 230, bedrooms: 4, bathrooms: 2, provinceCode: 'BJM', communeIdx: 7, imgStart: 3 },
    { title: 'Duplex vue colline à Musaga', fr: 'Duplex vue colline à Musaga', propertyType: 'APARTMENT', listingType: 'SALE', price: 210000000, surfaceArea: 175, bedrooms: 3, bathrooms: 2, provinceCode: 'BJM', communeIdx: 8, imgStart: 15 },
    { title: 'Villa à Gisozi, Gitega', fr: 'Villa à Gisozi, Gitega', propertyType: 'VILLA', listingType: 'SALE', price: 190000000, surfaceArea: 300, bedrooms: 4, bathrooms: 3, provinceCode: 'GIT', communeIdx: 0, imgStart: 18 },
    { title: 'Maison de fonction à Gitega', fr: 'Maison de fonction à Gitega', propertyType: 'HOUSE', listingType: 'RENT', price: 750000, surfaceArea: 140, bedrooms: 3, bathrooms: 2, provinceCode: 'GIT', communeIdx: 1, imgStart: 4, verified: true },
    { title: 'Terrain agricole à Ngozi', fr: 'Terrain agricole à Ngozi', propertyType: 'LAND', listingType: 'SALE', price: 45000000, surfaceArea: 1500, bedrooms: 0, bathrooms: 0, provinceCode: 'NGO', communeIdx: 0, imgStart: 23 },
    { title: 'Ferme avec bâti à Muyinga', fr: 'Ferme avec bâti à Muyinga', propertyType: 'HOUSE', listingType: 'SALE', price: 135000000, surfaceArea: 1000, bedrooms: 4, bathrooms: 3, provinceCode: 'MUY', communeIdx: 0, imgStart: 5, verified: true },
    { title: 'Complexe commercial à Rumonge', fr: 'Complexe commercial à Rumonge', propertyType: 'COMMERCIAL', listingType: 'SALE', price: 340000000, surfaceArea: 400, bedrooms: 0, bathrooms: 2, provinceCode: 'RUM', communeIdx: 0, imgStart: 26, verified: true, featured: true },
    { title: 'Villa avec piscine à Rumonge', fr: 'Villa avec piscine à Rumonge', propertyType: 'VILLA', listingType: 'SALE', price: 465000000, surfaceArea: 380, bedrooms: 4, bathrooms: 4, provinceCode: 'RUM', communeIdx: 1, imgStart: 19, featured: true },
    { title: 'Appartements lake view à Ruvubu', fr: 'Appartements lake view à Ruvubu', propertyType: 'APARTMENT', listingType: 'RENT', price: 900000, surfaceArea: 95, bedrooms: 2, bathrooms: 1, provinceCode: 'RUV', communeIdx: 0, imgStart: 10, verified: true },
    { title: 'Terrain urbain à Makamba', fr: 'Terrain urbain à Makamba', propertyType: 'LAND', listingType: 'SALE', price: 60000000, surfaceArea: 550, bedrooms: 0, bathrooms: 0, provinceCode: 'MAK', communeIdx: 0, imgStart: 23 },
  ];

  const createdProperties: any[] = [];
  let resolvedIndex = 0;
  for (let i = 0; i < propertySeeds.length; i += 1) {
    const seed = propertySeeds[i];
    const agent = agents[i % agents.length];
    const agentUser = agentUsers[i % agentUsers.length];
    const province = provinces.find((p) => p.code === seed.provinceCode) ?? bjm;
    const provinceCommunes = communes.filter((c) => String(c.provinceId) === String(province._id));
    const commune = provinceCommunes[seed.communeIdx % Math.max(provinceCommunes.length, 1)] ?? provinceCommunes[0] ?? bjmCommunes[0];
    const propertyId = await generatePropertyId(province.code, (commune as any).code);

    const imgIndices = [seed.imgStart, seed.imgStart + 1, seed.imgStart + 2].map((n) => n % IMAGE_POOL.length);
    const urls = await Promise.all(imgIndices.map((n) => resolveImage(IMAGE_POOL[n], resolvedIndex++)));
    const media = urls.map((url, k) => ({
      fileKey: `seed/property-${i + 1}-${k + 1}.jpg`,
      url,
      isPrimary: k === 0,
      mediaType: 'IMAGE',
      sortOrder: k,
    }));

    const [baseLat, baseLon] = PROVINCE_COORDS[seed.provinceCode] ?? PROVINCE_COORDS.BJM;
    const jitter = i % 5;

    let verificationStatus = 'NOT_VERIFIED';
    let verificationLevel: string | undefined;
    if (seed.verified) {
      verificationStatus = 'VERIFIED';
      verificationLevel = 'FULLY_VERIFIED';
    } else if (seed.partial) {
      verificationStatus = 'PARTIAL';
      verificationLevel = 'PARTIAL_VERIFIED';
    }

    const daysAgo = i === 0 ? 0 : Math.min(i * 2, 40);

    const property = await Property.create({
      propertyId,
      ownerUserId: agentUser._id,
      landlordUserId: seed.listingType === 'RENT' ? agentUser._id : undefined,
      agentId: agent._id,
      createdBy: agentUser._id,
      title: seed.title,
      titleFr: seed.title,
      description: `${seed.title} — bien situé, proche des commodités.`,
      propertyType: seed.propertyType,
      listingType: seed.listingType,
      status: 'PUBLISHED',
      verificationStatus,
      verificationLevel,
      price: { amount: seed.price, currency: 'BIF' },
      isNegotiable: seed.listingType !== 'RENT',
      surfaceArea: seed.surfaceArea,
      bedrooms: seed.bedrooms,
      bathrooms: seed.bathrooms,
      provinceId: province._id,
      communeId: commune._id,
      latitude: baseLat + jitter * 0.006,
      longitude: baseLon + jitter * 0.006,
      locationPrecision: 'APPROXIMATE',
      media,
      badges: {
        featured: Boolean(seed.featured),
        isNew: daysAgo < 14,
        isPromoted: Boolean(seed.promoted),
      },
      publishedBy: agentUser._id,
      approvedBy: agentUser._id,
      publishedAt: new Date(Date.now() - daysAgo * 24 * 60 * 60 * 1000),
    });
    createdProperties.push(property);
  }

  const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000);
  const bookingDeadline = new Date(Date.now() + 18 * 60 * 60 * 1000);
  for (const property of createdProperties.slice(0, 2)) {
    await VisitSession.create({
      propertyId: property._id,
      date: tomorrow,
      startTime: '10:00',
      endTime: '11:00',
      capacity: 8,
      bookedCount: 0,
      bookingDeadline,
      status: 'SCHEDULED',
      createdBy: property.createdBy,
      timezone: 'Africa/Bujumbura',
    });
  }

  console.log(`[SEED] Agents: ${agents.length}, Properties: ${createdProperties.length}, Visit sessions: 2`);
  return { agents, properties: createdProperties };
}

async function seedExchangeRates() {
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);
  // Only the pairs CurrencyContext can actually render. ExchangeRate's
  // fromCurrency/toCurrency are constrained to CURRENCIES (BIF | USD), so
  // seeding a EUR row here fails validation and aborts the whole seed.
  const rates = [
    { fromCurrency: 'BIF', toCurrency: 'USD', rate: 1 / 2850, source: 'SEED' },
    { fromCurrency: 'USD', toCurrency: 'BIF', rate: 2850, source: 'SEED' },
  ];
  await ExchangeRate.insertMany(rates.map((r) => ({ ...r, rateDate: today })));
  console.log(`[SEED] Exchange rates: ${rates.length}`);
}

async function run(): Promise<void> {
  await connectDB();
  await dropDatabase();

  const roles = await seedRoles();
  const permissions = await seedPermissions();
  const { provinces, communes } = await seedGeo();
  const bjm = provinces.find((p) => p.code === 'BJM') ?? provinces[0];
  const bjmCommune = communes.find((c) => String(c.provinceId) === String(bjm._id)) ?? communes[0];

  await seedRolePermissions(roles, permissions, bjm._id, bjmCommune._id);
  await seedAdmin(roles);
  await seedDemo(provinces, communes);
  await seedExchangeRates();

  console.log('[SEED] Done.');
  await disconnectDB();
  process.exit(0);
}

run().catch(async (err) => {
  console.error('[SEED] Failed:', err);
  await disconnectDB().catch(() => undefined);
  process.exit(1);
});
