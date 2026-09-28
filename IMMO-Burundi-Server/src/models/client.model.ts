import { Schema, model } from 'mongoose';

export const clientSchema = new Schema(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    address: { type: String },
  },
  { timestamps: true },
);

export const Client = model('Client', clientSchema);
export default Client;
