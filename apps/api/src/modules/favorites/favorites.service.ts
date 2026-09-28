import { Types } from 'mongoose';
import { AppError } from '../../middleware/errorHandler.js';
import { Favorite } from '../../models/favorite.model.js';
import { Property } from '../../models/property.model.js';
import '../../models/agent.model.js';
import { toPropertySummaryDTO } from '../../helpers/dtoShapers.js';

const POPULATE = [
  { path: 'provinceId', select: 'name code' },
  { path: 'communeId', select: 'name code' },
  { path: 'zoneId', select: 'name code' },
  { path: 'agentId', populate: { path: 'userId', select: 'firstName lastName' } },
];

export async function listFavorites(userId: string, query: any) {
  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const skip = (page - 1) * pageSize;

  const [favorites, total] = await Promise.all([
    Favorite.find({ userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .populate({ path: 'propertyId', populate: POPULATE }),
    Favorite.countDocuments({ userId }),
  ]);

  const items = favorites
    .map((favorite: any) => favorite.propertyId)
    .filter((property: any) => property && !property.deletedAt)
    .map((property: any) => toPropertySummaryDTO(property));

  return {
    items,
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}

export async function addFavorite(userId: string, propertyId: string) {
  const filter = Types.ObjectId.isValid(propertyId)
    ? { $or: [{ _id: propertyId }, { propertyId }] }
    : { propertyId };
  const property = await Property.findOne(filter).lean();
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');
  if (property.deletedAt) throw new AppError(400, 'PROPERTY_DELETED', 'Property is deleted.');

  const exists = await Favorite.findOne({
    userId,
    propertyId: (property as any)._id,
  }).lean();
  if (exists) {
    return { favorite: true, alreadyExists: true, propertyId: String((property as any)._id) };
  }

  await Favorite.create({ userId, propertyId: (property as any)._id });
  await Property.updateOne({ _id: (property as any)._id }, { $inc: { 'stats.favorites': 1 } });
  return { favorite: true, alreadyExists: false, propertyId: String((property as any)._id) };
}

export async function removeFavorite(userId: string, propertyId: string) {
  const filter = Types.ObjectId.isValid(propertyId)
    ? { $or: [{ _id: propertyId }, { propertyId }] }
    : { propertyId };
  const property = await Property.findOne(filter).lean();
  if (!property) throw new AppError(404, 'PROPERTY_NOT_FOUND', 'Property not found.');

  const result = await Favorite.deleteOne({ userId, propertyId: (property as any)._id });
  if (result.deletedCount > 0) {
    await Property.updateOne({ _id: (property as any)._id }, { $inc: { 'stats.favorites': -1 } });
  }
  return { removed: result.deletedCount > 0 };
}
