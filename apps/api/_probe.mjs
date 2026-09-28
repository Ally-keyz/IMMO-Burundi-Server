import './src/models/role.model.js';
import './src/models/users.model.js';
import './src/models/rolePermission.model.js';
import './src/models/permission.model.js';
import { mongoose } from 'mongoose';

await mongoose.connect('mongodb://127.0.0.1:27017/immo-burundi');
const admin = await mongoose.model('User').findOne({ phone: '+25779000000' }).lean();
const role = await mongoose.model('Role').findById(admin.roleId).lean();
console.log('role found:', role?.name);
const count = await mongoose.model('RolePermission').countDocuments({ roleId: role?._id });
console.log('grant count for role:', count);
const grants = await mongoose.model('RolePermission').find({ roleId: role?._id }).limit(2).populate('permissionId').lean();
console.log('sample grant:', JSON.stringify(grants, null, 1));
await mongoose.disconnect();