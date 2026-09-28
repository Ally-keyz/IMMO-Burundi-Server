import { Schema, model } from 'mongoose';

export const systemSettingSchema = new Schema(
  {
    key: { type: String, required: true, unique: true },
    value: { type: Schema.Types.Mixed },
    updatedBy: { type: Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true },
);

export const SystemSetting = model('SystemSetting', systemSettingSchema);
export default SystemSetting;
