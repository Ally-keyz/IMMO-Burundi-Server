import { AppError } from '../../middleware/errorHandler.js';
import { Notification } from '../../models/notification.model.js';

export async function createNotification(params: {
  userId: string;
  title: string;
  message: string;
  type: string;
  channel?: string;
  data?: unknown;
}) {
  return Notification.create({
    userId: params.userId,
    title: params.title,
    message: params.message,
    type: params.type,
    channel: params.channel ?? 'IN_APP',
    status: 'SENT',
    data: params.data,
  });
}

export async function listNotifications(userId: string, query: any) {
  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const skip = (page - 1) * pageSize;

  const filter: Record<string, any> = { userId };
  if (query.unread === 'true') filter.readAt = null;

  const [items, total] = await Promise.all([
    Notification.find(filter).sort({ createdAt: -1 }).skip(skip).limit(pageSize).lean(),
    Notification.countDocuments(filter),
  ]);

  return {
    /* The web client reads `read`, the document stores `readAt` — map it here. */
    items: items.map((n: any) => ({ ...n, read: Boolean(n.readAt) })),
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}

/** True unread count across every page — the header bell cannot rely on one page. */
export async function countUnread(userId: string) {
  const unread = await Notification.countDocuments({ userId, readAt: null });
  return { unread };
}

export async function markRead(id: string, userId: string) {
  const notification: any = await Notification.findById(id);
  if (!notification) throw new AppError(404, 'NOTIFICATION_NOT_FOUND', 'Notification not found.');
  if (String(notification.userId) !== userId) {
    throw new AppError(403, 'FORBIDDEN', 'You can only read your own notifications.');
  }
  notification.readAt = new Date();
  notification.status = 'READ';
  await notification.save();
  return notification;
}

export async function markAllRead(userId: string) {
  const result = await Notification.updateMany(
    { userId, readAt: null },
    { $set: { readAt: new Date(), status: 'READ' } },
  );
  return { updated: result.modifiedCount };
}
