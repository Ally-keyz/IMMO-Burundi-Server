import { Schema, model } from 'mongoose';

export const favoriteSchema = new Schema(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

favoriteSchema.index({ userId: 1, propertyId: 1 }, { unique: true });

export const Favorite = model('Favorite', favoriteSchema);
export default Favorite;
