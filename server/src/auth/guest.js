const crypto = require('crypto');

function signGuest(secret, { uid, name, exp }) {
  const body = Buffer.from(JSON.stringify({ uid, name, exp })).toString('base64url');
  const sig = crypto.createHmac('sha256', secret).update(body).digest('base64url');
  return `g1.${body}.${sig}`;
}

function verifyGuest(secret, token) {
  const match = /^g1\.([A-Za-z0-9_-]+)\.([A-Za-z0-9_-]+)$/.exec(token);
  if (!match) throw new Error('bad guest token');
  const expected = crypto.createHmac('sha256', secret).update(match[1]).digest('base64url');
  const a = Buffer.from(expected);
  const b = Buffer.from(match[2]);
  if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) throw new Error('bad guest token');
  const data = JSON.parse(Buffer.from(match[1], 'base64url').toString());
  if (!data || typeof data.uid !== 'string' || !/^[A-Za-z0-9_-]{8,40}$/.test(data.uid)) throw new Error('bad guest token');
  if (typeof data.name !== 'string' || data.name.length < 1 || data.name.length > 20) throw new Error('bad guest token');
  if (!Number.isInteger(data.exp) || data.exp < Date.now()) throw new Error('expired guest token');
  return { uid: data.uid, name: data.name, exp: data.exp };
}

function sanitizeGuestName(input) {
  const cleaned = String(input || '').replace(/[^\p{L}\p{N} _.-]/gu, '').trim().slice(0, 20);
  return cleaned || 'Guest';
}

module.exports = { signGuest, verifyGuest, sanitizeGuestName };
