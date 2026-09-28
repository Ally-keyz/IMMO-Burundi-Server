import { Schema, model } from 'mongoose';

export const messageSchema = new Schema(
  {
    conversationId: { type: Schema.Types.ObjectId, ref: 'Conversation', required: true, index: true },
    senderId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    message: { type: String, required: true },
    /** Automated notice (e.g. payment received) rather than something a person typed. */
    isSystem: { type: Boolean, default: false },
    attachmentId: { type: String },
    readAt: { type: Date },
    deletedAt: { type: Date },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

messageSchema.index({ conversationId: 1, createdAt: -1 });

export const Message = model('Message', messageSchema);
export default Message;
