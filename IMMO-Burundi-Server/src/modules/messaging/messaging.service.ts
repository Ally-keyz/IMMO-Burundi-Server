import { Types } from 'mongoose';
import { AppError } from '../../middleware/errorHandler.js';
import { Conversation } from '../../models/conversation.model.js';
import { ConversationParticipant } from '../../models/conversationParticipant.model.js';
import { Message } from '../../models/message.model.js';
import '../../models/users.model.js';
import '../../models/property.model.js';
import { getIO } from '../../config/socket.js';
import { auditLog } from '../../helpers/auditLog.js';
import { notifyUsers } from '../../helpers/notify.js';

async function assertParticipant(conversation: any, userId: string): Promise<void> {
  const participants: any[] = conversation.participants ?? [];
  const isMember = participants.some((p) => String(p?._id ?? p) === userId);
  if (!isMember) throw new AppError(403, 'FORBIDDEN', 'You are not part of this conversation.');
}

export async function createOrGetConversation(userId: string, body: any) {
  const otherUserId = body.participantUserId;
  if (!Types.ObjectId.isValid(otherUserId)) {
    throw new AppError(400, 'INVALID_PARTICIPANT', 'A valid participantUserId is required.');
  }
  if (otherUserId === userId) {
    throw new AppError(400, 'INVALID_PARTICIPANT', 'You cannot start a conversation with yourself.');
  }

  const participants = [userId, otherUserId];
  const filter: Record<string, any> = { participants: { $all: participants } };
  if (body.propertyId) filter.propertyId = body.propertyId;

  let conversation = await Conversation.findOne(filter);
  if (!conversation) {
    conversation = await Conversation.create({
      participants,
      propertyId: body.propertyId,
    });
    await ConversationParticipant.insertMany([
      { conversationId: conversation._id, userId },
      { conversationId: conversation._id, userId: otherUserId },
    ]);
  }

  return conversation.populate('participants', 'firstName lastName phone');
}

export async function listConversations(userId: string) {
  const conversations = await Conversation.find({ participants: userId })
    .sort({ lastMessageAt: -1, updatedAt: -1 })
    .populate('participants', 'firstName lastName phone')
    .populate('propertyId', 'title propertyId media')
    .lean();

  const withLast = await Promise.all(
    conversations.map(async (conversation: any) => {
      const lastMessage = await Message.findOne({ conversationId: conversation._id, deletedAt: null })
        .sort({ createdAt: -1 })
        .lean();
      return { ...conversation, lastMessage };
    }),
  );

  return withLast;
}

export async function listMessages(conversationId: string, userId: string, query: any) {
  const conversation = await Conversation.findById(conversationId);
  if (!conversation) throw new AppError(404, 'CONVERSATION_NOT_FOUND', 'Conversation not found.');
  await assertParticipant(conversation, userId);

  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 30));
  const skip = (page - 1) * pageSize;

  const [items, total] = await Promise.all([
    Message.find({ conversationId, deletedAt: null })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .populate('senderId', 'firstName lastName')
      .lean(),
    Message.countDocuments({ conversationId, deletedAt: null }),
  ]);

  return {
    items: items.reverse(),
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}

export async function sendMessage(conversationId: string, userId: string, body: any) {
  const conversation = await Conversation.findById(conversationId);
  if (!conversation) throw new AppError(404, 'CONVERSATION_NOT_FOUND', 'Conversation not found.');
  await assertParticipant(conversation, userId);

  const message = await Message.create({
    conversationId,
    senderId: userId,
    message: body.message,
    attachmentId: body.attachmentId,
  });

  conversation.lastMessageAt = new Date();
  await conversation.save();

  try {
    const io = getIO();
    const payload = {
      conversationId,
      _id: String(message._id),
      senderId: userId,
      message: message.message,
      attachmentId: message.attachmentId,
      createdAt: (message as any).createdAt,
    };
    io.to(`conversation:${conversationId}`).emit('message:new', payload);
    for (const participant of (conversation as any).participants as any[]) {
      io.to(`user:${String(participant?._id ?? participant)}`).emit('message:new', payload);
    }
  } catch {
    /* socket layer unavailable — message is still persisted */
  }

  /* Persist a notification for every other participant so the bell updates even
     when the socket is down or the tab was closed. */
  const others = ((conversation as any).participants as any[])
    .map((p) => String(p?._id ?? p))
    .filter((id) => id !== String(userId));
  await notifyUsers(others, {
    type: 'NEW_MESSAGE',
    title: 'New message',
    message: String(body.message ?? '').slice(0, 140),
    data: { conversationId, messageId: String(message._id) },
  });

  await auditLog({
    actorUserId: userId,
    action: 'MESSAGE_SENT',
    resourceType: 'Conversation',
    resourceId: conversationId,
  });

  return message;
}
