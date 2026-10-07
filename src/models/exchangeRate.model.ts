import { Schema, model } from 'mongoose';
import { CURRENCIES } from '@immo/shared-types';

export const exchangeRateSchema = new Schema(
  {
    fromCurrency: { type: String, enum: [...CURRENCIES], required: true },
    toCurrency: { type: String, enum: [...CURRENCIES], required: true },
    rate: { type: Number, required: true, min: 0 },
    source: { type: String },
    rateDate: { type: Date, required: true },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

exchangeRateSchema.index({ fromCurrency: 1, toCurrency: 1, rateDate: -1 });

export const ExchangeRate = model('ExchangeRate', exchangeRateSchema);
export default ExchangeRate;
