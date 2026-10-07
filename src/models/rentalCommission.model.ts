import { Schema, model } from 'mongoose';
import { COMPLETION_STATUSES, CURRENCIES } from '@immo/shared-types';

export const rentalCommissionSchema = new Schema(
  {
    propertyId: { type: Schema.Types.ObjectId, ref: 'Property', required: true, index: true },
    rentalApplicationId: { type: Schema.Types.ObjectId, ref: 'RentalApplication', index: true },
    agentId: { type: Schema.Types.ObjectId, ref: 'Agent', index: true },
    landlordId: { type: Schema.Types.ObjectId, ref: 'User' },
    tenantId: { type: Schema.Types.ObjectId, ref: 'User' },
    commissionCode: { type: String, required: true, unique: true },
    rentAmount: { type: Number, required: true, min: 0 },
    commissionRate: { type: Number, required: true },
    commissionAmount: { type: Number, required: true, min: 0 },
    currency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
    dueDate: { type: Date },
    paidAt: { type: Date },
    status: { type: String, enum: [...COMPLETION_STATUSES], default: 'PENDING', index: true },
  },
  { timestamps: true },
);

export const RentalCommission = model('RentalCommission', rentalCommissionSchema);
export default RentalCommission;
