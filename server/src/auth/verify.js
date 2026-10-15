const config = require('../config');
const { verifyGuest } = require('./guest');
let admin;

function initFirebase() {
  admin = require('firebase-admin');
  if (admin.apps.length) return;
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    const parsed = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    admin.initializeApp({ credential: admin.credential.cert(parsed) });
    return;
  }
  admin.initializeApp();
}

async function verifyToken(token) {
  if (typeof token !== 'string' || !token) throw new Error('no token');
  if (config.authMode === 'dev') {
    const m = /^dev:([A-Za-z0-9_-]{1,40})(?::(.{1,20}))?$/.exec(token);
    if (!m) throw new Error('bad dev token');
    return { uid: m[1], name: m[2] || `Guest-${m[1].slice(0, 4)}`, picture: null };
  }
  if (config.authMode === 'guest') {
    const secret = config.guestSecret();
    if (!secret) throw new Error('guest auth unconfigured');
    const user = verifyGuest(secret, token);
    return { uid: user.uid, name: user.name, picture: null };
  }
  if (!config.firebaseConfigured()) throw new Error('firebase auth unconfigured');
  initFirebase();
  const d = await admin.auth().verifyIdToken(token);
  return { uid: d.uid, name: d.name || `Guest-${d.uid.slice(0, 4)}`, picture: d.picture || null };
}
module.exports = { verifyToken };
