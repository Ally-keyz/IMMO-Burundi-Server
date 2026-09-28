import { Schema, model } from 'mongoose';
import { NOTIFICATION_CHANNELS } from '@immo/shared-types';

export const notificationPreferenceSchema = new Schema(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    eventType: { type: String, required: true },
    channels: [{ type: String, enum: [...NOTIFICATION_CHANNELS] }],
    enabled: { type: Boolean, default: true },
  },
  { timestamps: true },
);

notificationPreferenceSchema.index({ userId: 1, eventType: 1 }, { unique: true });

export const NotificationPreference = model('NotificationPreference', notificationPreferenceSchema);
export default NotificationPreference;
