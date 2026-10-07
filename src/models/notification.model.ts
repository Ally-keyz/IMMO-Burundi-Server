import { Schema, model } from 'mongoose';
import {
  NOTIFICATION_CHANNELS,
  NOTIFICATION_STATUSES,
  NOTIFICATION_TYPES,
} from '@immo/shared-types';

export const notificationSchema = new Schema(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true },
    message: { type: String, required: true },
    type: { type: String, enum: [...NOTIFICATION_TYPES], required: true },
    channel: { type: String, enum: [...NOTIFICATION_CHANNELS], default: 'IN_APP' },
    status: { type: String, enum: [...NOTIFICATION_STATUSES], default: 'PENDING', index: true },
    data: { type: Schema.Types.Mixed },
    readAt: { type: Date },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

notificationSchema.index({ userId: 1, createdAt: -1 });

export const Notification = model('Notification', notificationSchema);
export default Notification;
