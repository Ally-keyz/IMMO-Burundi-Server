import { getIO } from '../config/socket.js';
import { createNotification } from '../modules/notifications/notifications.service.js';
import { User } from '../models/users.model.js';
import { Agent } from '../models/agent.model.js';

export interface NotifyPayload {
  type: string;
  title: string;
  message: string;
  data?: Record<string, unknown>;
  /** Optional channel override; defaults to IN_APP. */
  channel?: string;
}

/**
 * Persists a notification and pushes it over the socket to the user's room.
 *
 * Never throws: a failed notification must not roll back the business action
 * that triggered it, so delivery problems are logged and swallowed.
 */
export async function notifyUser(userId: string | null | undefined, payload: NotifyPayload): Promise<void> {
  if (!userId) return;
  try {
    const created: any = await createNotification({
      userId: String(userId),
      title: payload.title,
      message: payload.message,
      type: payload.type,
      channel: payload.channel,
      data: payload.data,
    });

    const doc = created.toObject ? created.toObject() : created;
    const item = {
      _id: String(doc._id),
      type: doc.type,
      title: doc.title,
      message: doc.message,
      /* Kept in the push so a live-arriving notification can deep-link too. */
      data: doc.data ?? null,
      read: false,
      createdAt: doc.createdAt instanceof Date ? doc.createdAt.toISOString() : doc.createdAt,
    };
    getIO()?.to(`user:${String(userId)}`).emit('notification:new', { notification: item });
  } catch (err) {
    console.warn('[NOTIFY] failed:', (err as Error)?.message);
  }
}

/** Fan-out to many recipients; falsy ids are dropped and duplicates collapsed. */
export async function notifyUsers(userIds: Array<string | null | undefined>, payload: NotifyPayload): Promise<void> {
  const unique = [...new Set(userIds.filter(Boolean).map(String))];
  await Promise.all(unique.map((id) => notifyUser(id, payload)));
}

/** Notifies every active MAIN_ADMIN — used for moderation queues. */
export async function notifyAdmins(payload: NotifyPayload): Promise<void> {
  try {
    const admins = await User.find({ role: 'MAIN_ADMIN', status: 'ACTIVE' }).select('_id').lean();
    await notifyUsers(
      admins.map((a: any) => String(a._id)),
      payload,
    );
  } catch (err) {
    console.warn('[NOTIFY] admins failed:', (err as Error)?.message);
  }
}

/**
 * Resolves the userId behind a property's agent so actions on a listing can
 * reach the agent even though `Property.agentId` points at the Agent document.
 */
export async function agentUserIdForProperty(property: any): Promise<string | null> {
  try {
    const agent = await Agent.findById(property?.agentId?._id ?? property?.agentId).select('userId').lean();
    const userId = agent?.userId;
    return userId ? String(userId) : null;
  } catch {
    return null;
  }
}
