import { Schema, model } from 'mongoose';
import { ENQUIRY_STATUSES } from '@immo/shared-types';

export const enquirySchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    senderUserId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    recipientUserId: { type: Schema.Types.ObjectId, ref: 'User', index: true },
    agentId: { type: Schema.Types.ObjectId, ref: 'Agent', index: true },
    message: { type: String, required: true },
    subject: { type: String, index: true },
    status: { type: String, enum: [...ENQUIRY_STATUSES], default: 'NEW', index: true },
    closedAt: { type: Date },
  },
  { timestamps: true },
);

export const Enquiry = model('Enquiry', enquirySchema);
export default Enquiry;
