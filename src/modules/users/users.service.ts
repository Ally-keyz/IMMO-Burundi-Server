import { AppError } from '../../middleware/errorHandler.js';
import bcrypt from 'bcrypt';
import { User } from '../../models/users.model.js';
import { Property } from '../../models/property.model.js';
import { PropertyView } from '../../models/propertyView.model.js';
import { toPropertySummaryDTO } from '../../helpers/dtoShapers.js';
import { parsePagination, paginationMeta } from '../../helpers/http.js';
import { toUserPublicDTO } from '../auth/auth.service.js';

const EDITABLE_FIELDS = [
  'firstName',
  'lastName',
  'email',
  'phone',
  'photoUrl',
  'preferredLanguage',
  'preferredCurrency',
] as const;

const RECENT_VIEW_POPULATE = [
  { path: 'provinceId', select: 'name code' },
  { path: 'communeId', select: 'name code' },
  { path: 'zoneId', select: 'name code' },
  { path: 'agentId', populate: { path: 'userId', select: 'firstName lastName' } },
];

export async function listUsers(query: any) {
  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const skip = (page - 1) * pageSize;

  const filter: Record<string, unknown> = {};
  if (query.status) filter.status = query.status;
  if (query.role) filter.role = query.role;
  if (query.q) {
    const rx = new RegExp(String(query.q).replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
    filter.$or = [{ firstName: rx }, { lastName: rx }, { phone: rx }, { email: rx }];
  }

  const [items, total] = await Promise.all([
    User.find(filter).sort({ createdAt: -1 }).skip(skip).limit(pageSize),
    User.countDocuments(filter),
  ]);

  return {
    items: items.map(toUserPublicDTO),
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}

export async function getUser(id: string) {
  const user = await User.findById(id);
  if (!user) throw new AppError(404, 'USER_NOT_FOUND', 'User not found.');
  return toUserPublicDTO(user);
}

export async function updateUser(id: string, body: any, opts: { isAdmin: boolean }) {
  const user = await User.findById(id);
  if (!user) throw new AppError(404, 'USER_NOT_FOUND', 'User not found.');

  for (const field of EDITABLE_FIELDS) {
    if (body[field] !== undefined) (user as any)[field] = body[field];
  }

  if (body.password) {
    if (!opts.isAdmin) {
      if (!body.currentPassword) {
        throw new AppError(400, 'CURRENT_PASSWORD_REQUIRED', 'Current password is required to change your password.');
      }
      const match = await bcrypt.compare(String(body.currentPassword), user.passwordHash);
      if (!match) throw new AppError(400, 'WRONG_PASSWORD', 'Current password is incorrect.');
    }
    (user as any).passwordHash = await bcrypt.hash(String(body.password), 12);
  }

  if (opts.isAdmin) {
    if (body.status !== undefined) (user as any).status = body.status;
    if (body.role !== undefined) (user as any).role = body.role;
  }

  await user.save();
  return toUserPublicDTO(user);
}

export async function getRecentViews(userId: string, query: any) {
  const views = await PropertyView.find({ userId })
    .sort({ viewedAt: -1 })
    .limit(200)
    .select('propertyId viewedAt')
    .lean();

  const seen = new Set<string>();
  const propertyIds: string[] = [];
  for (const view of views) {
    const id = String(view.propertyId);
    if (!seen.has(id)) {
      seen.add(id);
      propertyIds.push(id);
    }
  }

  const { page, pageSize } = parsePagination(query);
  const start = (page - 1) * pageSize;
  const pageIds = propertyIds.slice(start, start + pageSize);

  const properties = pageIds.length
    ? await Property.find({ _id: { $in: pageIds }, deletedAt: null }).populate(RECENT_VIEW_POPULATE as any)
    : [];
  const byId = new Map(properties.map((p: any) => [String(p._id), p]));
  const items = pageIds
    .map((id) => byId.get(id))
    .filter((p): p is NonNullable<typeof p> => Boolean(p))
    .map((p) => toPropertySummaryDTO(p));

  return { items, meta: paginationMeta(page, pageSize, propertyIds.length) };
}
