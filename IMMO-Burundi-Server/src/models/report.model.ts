import { Schema, model } from 'mongoose';
import { REPORT_REASONS, REPORT_STATUSES } from '@immo/shared-types';

export const reportSchema = new Schema(
  {
    reporterId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    resourceType: { type: String, required: true, index: true },
    resourceId: { type: Schema.Types.ObjectId, required: true, index: true },
    reason: { type: String, enum: [...REPORT_REASONS], required: true },
    description: { type: String },
    status: { type: String, enum: [...REPORT_STATUSES], default: 'PENDING', index: true },
    assignedTo: { type: Schema.Types.ObjectId, ref: 'User' },
    resolution: { type: String },
    resolvedAt: { type: Date },
  },
  { timestamps: true },
);

reportSchema.index({ resourceType: 1, resourceId: 1, createdAt: -1 });

export const Report = model('Report', reportSchema);
export default Report;
