const http = require('http');
const crypto = require('crypto');
const express = require('express');
const { Server } = require('socket.io');
const config = require('./config');
const { RoomManager } = require('./rooms/RoomManager');
const { attachSockets } = require('./sockets');
const { connectDb, getDbStatus } = require('./database');
const { privacyHtml } = require('./pages/privacy');
const { signGuest, sanitizeGuestName } = require('./auth/guest');

const guestHits = new Map();
function guestAllowed(ip) {
  const now = Date.now();
  const bucket = guestHits.get(ip) || { n: 0, reset: now + 10 * 60 * 1000 };
  if (now > bucket.reset) { bucket.n = 0; bucket.reset = now + 10 * 60 * 1000; }
  bucket.n += 1;
  guestHits.set(ip, bucket);
  return bucket.n <= 30;
}

function createServer({ graceMs = config.graceMs } = {}) {
  const app = express();
  app.set('trust proxy', 1);
  app.use(express.json({ limit: '1kb' }));
  const corsOrigin = process.env.CORS_ORIGIN || '*';
  // Phones on the same Wi-Fi can recognise this server when they search for it.
  app.get('/health', (_req, res) => {
    const db = getDbStatus();
    const auth = config.authStatus();
    const ok = db !== 'error' && auth !== 'unconfigured' && auth !== 'blocked';
    res.status(ok ? 200 : 503).json({ ok, app: 'rivalrooms', db, auth });
  });
  app.post('/auth/guest', (req, res) => {
    if (config.authMode !== 'guest') return res.status(404).json({ ok: false, error: 'GUEST_AUTH_DISABLED' });
    const secret = config.guestSecret();
    if (!secret) return res.status(503).json({ ok: false, error: 'GUEST_AUTH_UNCONFIGURED' });
    if (!guestAllowed(req.ip || 'local')) return res.status(429).json({ ok: false, error: 'RATE_LIMITED' });
    const name = sanitizeGuestName(req.body && req.body.name);
    const uid = crypto.randomBytes(12).toString('base64url').replace(/[^A-Za-z0-9_-]/g, '').slice(0, 20);
    const exp = Date.now() + 7 * 24 * 60 * 60 * 1000;
    const token = signGuest(secret, { uid, name, exp });
    res.json({ ok: true, token, userId: uid, username: name, exp });
  });
  app.get(['/privacy', '/privacy-policy'], (_req, res) => res.type('html').send(privacyHtml()));
  const httpServer = http.createServer(app);
  const io = new Server(httpServer, { cors: { origin: corsOrigin }, maxHttpBufferSize: 1e6 });
  const rooms = new RoomManager({ graceMs });
  attachSockets(io, rooms);
  const ticker = setInterval(() => rooms.tick(Date.now()), 250);
  ticker.unref();
  httpServer.on('close', () => clearInterval(ticker));
  return { httpServer, io, rooms };
}
module.exports = { createServer };

if (require.main === module) {
  const host = process.env.HOST || '0.0.0.0';
  connectDb().catch(e => console.error('[db] failed', e.message)).finally(() => {
    const { httpServer, io } = createServer();
    httpServer.listen(config.port, host, () => {
      console.log(`server listening on ${host}:${config.port} (auth=${config.authMode})`);
      const lan = Object.values(require('os').networkInterfaces()).flat()
        .filter(a => a && a.family === 'IPv4' && !a.internal).map(a => `${a.address}:${config.port}`);
      if (lan.length) console.log(`phones on the same Wi-Fi: enter ${lan.join(' or ')} under Home > Server`);
    });
    const shutdown = (signal) => {
      console.log(`[server] ${signal} received, shutting down`);
      io.close();
      httpServer.close(() => process.exit(0));
      setTimeout(() => process.exit(1), 8000).unref();
    };
    process.once('SIGTERM', () => shutdown('SIGTERM'));
    process.once('SIGINT', () => shutdown('SIGINT'));
  });
}
