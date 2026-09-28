import { Schema, model } from 'mongoose';

export const conversationSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', index: true },
    participants: [{ type: Schema.Types.ObjectId, ref: 'User' }],
    lastMessageAt: { type: Date },
  },
  { timestamps: true },
);

conversationSchema.index({ participants: 1 });

export const Conversation = model('Conversation', conversationSchema);
export default Conversation;
