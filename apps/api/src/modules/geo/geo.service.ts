import { AppError } from '../../middleware/errorHandler.js';
import { Province } from '../../models/province.model.js';
import { Commune } from '../../models/commune.model.js';
import { Zone } from '../../models/zone.model.js';
import { ExchangeRate } from '../../models/exchangeRate.model.js';

export async function listProvinces() {
  return Province.find({ status: 'ACTIVE' }).sort({ name: 1 }).lean();
}

export async function listCommunes(provinceId: string) {
  const province = await Province.findById(provinceId).lean();
  if (!province) throw new AppError(404, 'PROVINCE_NOT_FOUND', 'Province not found.');
  return Commune.find({ provinceId, status: 'ACTIVE' }).sort({ name: 1 }).lean();
}

export async function listZones(communeId: string) {
  const commune = await Commune.findById(communeId).lean();
  if (!commune) throw new AppError(404, 'COMMUNE_NOT_FOUND', 'Commune not found.');
  return Zone.find({ communeId, status: 'ACTIVE' }).sort({ name: 1 }).lean();
}

export async function listExchangeRates() {
  return ExchangeRate.aggregate([
    { $sort: { fromCurrency: 1, toCurrency: 1, rateDate: -1 } },
    {
      $group: {
        _id: { fromCurrency: '$fromCurrency', toCurrency: '$toCurrency' },
        rate: { $first: '$rate' },
        rateDate: { $first: '$rateDate' },
        source: { $first: '$source' },
      },
    },
    {
      $project: {
        _id: 0,
        fromCurrency: '$_id.fromCurrency',
        toCurrency: '$_id.toCurrency',
        rate: 1,
        rateDate: 1,
        source: 1,
      },
    },
  ]);
}
