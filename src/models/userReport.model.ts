import { Schema, model } from 'mongoose';

export const USER_REPORT_STATUSES = ['PENDING', 'UNDER_REVIEW', 'RESOLVED'] as const;

export const userReportSchema = new Schema(
  {
    reporterId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    reportedUserId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    reason: { type: String, required: true },
    description: { type: String },
    status: { type: String, enum: [...USER_REPORT_STATUSES], default: 'PENDING', index: true },
    resolution: { type: String },
  },
  { timestamps: true },
);

export const UserReport = model('UserReport', userReportSchema);
export default UserReport;
