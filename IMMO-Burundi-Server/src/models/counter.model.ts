import { Schema, model } from 'mongoose';

/** Atomic sequence counters used by the business-code generators. */
export const counterSchema = new Schema(
  {
    key: { type: String, required: true, unique: true },
    seq: { type: Number, default: 0 },
  },
  { timestamps: true },
);

export const Counter = model('Counter', counterSchema);
export default Counter;
