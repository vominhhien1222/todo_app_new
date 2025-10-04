// Node 18+
import admin from 'firebase-admin';
import { readFileSync } from 'fs';

const serviceAccount = JSON.parse(readFileSync('./serviceAccount.json', 'utf8'));

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

// Cách dùng: node scripts/setRole.mjs <UID> <role1,role2,...>
// Ví dụ: node scripts/setRole.mjs 8H2...abc admin
//        node scripts/setRole.mjs 8H2...abc super_admin
//        node scripts/setRole.mjs 8H2...abc admin,moderator
const [, , uidArg, rolesArg] = process.argv;

if (!uidArg) {
    console.error('❌ Thiếu UID. Ví dụ: node scripts/setRole.mjs <UID> admin');
    process.exit(1);
}

const roles = rolesArg ? rolesArg.split(',').map(r => r.trim()) : ['admin'];

async function setRole(uid, roles) {
    const user = await admin.auth().getUser(uid);
    const oldClaims = user.customClaims || {};
    const newClaims = { ...oldClaims, roles };
    await admin.auth().setCustomUserClaims(uid, newClaims);

    // ✅ Thêm dòng này để biết thành công
    console.log(`✅ Updated claims for ${uid}:`, newClaims);
}

setRole(uidArg, roles).then(() => process.exit(0));

