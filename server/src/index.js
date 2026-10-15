const http = require('http');
const express = require('express');
const { Server } = require('socket.io');
const config = require('./config');
const { RoomManager } = require('./rooms/RoomManager');
const { attachSockets } = require('./sockets');
const { connectDb, getDbStatus } = require('./database');
const { privacyHtml } = require('./pages/privacy');

function createServer({ graceMs = config.graceMs } = {}) {
  const app = express();
  const corsOrigin = process.env.CORS_ORIGIN || '*';
  // Phones on the same Wi-Fi can recognise this server when they search for it.
  app.get('/health', (_req, res) => {
    const db = getDbStatus();
    const ok = db !== 'error';
    res.status(ok ? 200 : 503).json({ ok, app: 'rivalrooms', db });
  });
  app.get(['/privacy', '/privacy-policy'], (_req, res) => res.type('html').send(privacyHtml()));
  const httpServer = http.createServer(app);
  const io = new Server(httpServer, { cors: { origin: corsOrigin } });
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
