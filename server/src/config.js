const cfg = {
  port: +process.env.PORT || 3000,
  authMode: process.env.AUTH_MODE || 'dev',
  mongoUri: process.env.MONGO_URI || '',
  graceMs: +process.env.RECONNECT_GRACE_MS || 60000,
  nodeEnv: process.env.NODE_ENV || 'development',
};
// Dev auth lets anyone claim any identity. Only allow in production for temporary test deployments.
if (cfg.nodeEnv === 'production' && cfg.authMode === 'dev' && process.env.ALLOW_DEV_AUTH !== 'true') {
  throw new Error('AUTH_MODE=dev is not allowed in production (set ALLOW_DEV_AUTH=true for temporary test deploys only)');
}

function guestSecret() {
  const secret = process.env.GUEST_TOKEN_SECRET || '';
  return secret.length >= 16 ? secret : '';
}

function firebaseConfigured() {
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    try { JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON); return true; } catch { return false; }
  }
  return !!process.env.GOOGLE_APPLICATION_CREDENTIALS;
}

function authStatus() {
  if (cfg.authMode === 'dev') {
    if (cfg.nodeEnv === 'production' && process.env.ALLOW_DEV_AUTH !== 'true') return 'blocked';
    return 'dev';
  }
  if (cfg.authMode === 'guest') return guestSecret() ? 'guest' : 'unconfigured';
  if (cfg.authMode === 'firebase') return firebaseConfigured() ? 'firebase' : 'unconfigured';
  return 'unconfigured';
}

module.exports = Object.assign(cfg, { guestSecret, firebaseConfigured, authStatus });
