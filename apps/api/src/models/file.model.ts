import { Schema, model } from 'mongoose';
import { FILE_VISIBILITIES } from '@immo/shared-types';

export const fileSchema = new Schema(
  {
    uuid: { type: String, required: true, unique: true },
    originalName: { type: String, required: true },
    mimeType: { type: String, required: true },
    size: { type: Number, required: true },
    storageKey: { type: String, required: true },
    visibility: { type: String, enum: [...FILE_VISIBILITIES], default: 'PRIVATE' },
    checksum: { type: String },
    uploadedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    deletedAt: { type: Date },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

export const FileModel = model('File', fileSchema);
export default FileModel;
