import { Schema, model } from 'mongoose';

export const SUSPICIOUS_ACTIVITY_STATUSES = ['OPEN', 'INVESTIGATED', 'RESOLVED'] as const;

export const suspiciousActivityReportSchema = new Schema(
  {
    resourceType: { type: String, required: true, index: true },
    resourceId: { type: Schema.Types.ObjectId, index: true },
    triggerType: { type: String, required: true, index: true },
    description: { type: String },
    status: {
      type: String,
      enum: [...SUSPICIOUS_ACTIVITY_STATUSES],
      default: 'OPEN',
      index: true,
    },
    assignedTo: { type: Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true },
);

export const SuspiciousActivityReport = model(
  'SuspiciousActivityReport',
  suspiciousActivityReportSchema,
);
export default SuspiciousActivityReport;
