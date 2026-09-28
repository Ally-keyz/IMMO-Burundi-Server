import { Schema, model } from 'mongoose';

export const conversationParticipantSchema = new Schema(
  {
    conversationId: { type: Schema.Types.ObjectId, ref: 'Conversation', required: true, index: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    joinedAt: { type: Date, default: Date.now },
  },
  { timestamps: false },
);

conversationParticipantSchema.index({ conversationId: 1, userId: 1 }, { unique: true });

export const ConversationParticipant = model('ConversationParticipant', conversationParticipantSchema);
export default ConversationParticipant;
