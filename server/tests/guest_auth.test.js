process.env.NODE_ENV = 'production';
process.env.AUTH_MODE = 'guest';
delete process.env.GUEST_TOKEN_SECRET;
delete process.env.ALLOW_DEV_AUTH;

const test = require('node:test');
const assert = require('node:assert');
const { io } = require('socket.io-client');
const { signGuest, verifyGuest } = require('../src/auth/guest');
const { createServer } = require('../src/index');

const SECRET = 'test-guest-secret-16';

test('guest tokens reject tampering and expiry', () => {
  const token = signGuest(SECRET, { uid: 'player1234', name: 'Ada', exp: Date.now() + 10000 });
  assert.strictEqual(verifyGuest(SECRET, token).uid, 'player1234');
  assert.throws(() => verifyGuest('another-secret-16', token));
  assert.throws(() => verifyGuest(SECRET, `${token}x`));
  const expired = signGuest(SECRET, { uid: 'player1234', name: 'Ada', exp: Date.now() - 1000 });
  assert.throws(() => verifyGuest(SECRET, expired), /expired/);
  assert.throws(() => verifyGuest(SECRET, 'dev:player1234:Ada'));
});

test('production guest auth fails closed until the secret is set, then two clients can join', async (t) => {
  const srv = createServer();
  await new Promise((resolve) => srv.httpServer.listen(0, '127.0.0.1', resolve));
  const { port } = srv.httpServer.address();
  t.after(() => { srv.io.close(); srv.httpServer.close(); });
  const base = `http://127.0.0.1:${port}`;

  const closed = await fetch(`${base}/health`);
  const closedBody = await closed.json();
  assert.strictEqual(closed.status, 503);
  assert.strictEqual(closedBody.ok, false);
  assert.strictEqual(closedBody.auth, 'unconfigured');
  const blocked = await fetch(`${base}/auth/guest`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: '{"name":"Ada"}' });
  assert.strictEqual(blocked.status, 503);

  process.env.GUEST_TOKEN_SECRET = SECRET;
  const open = await fetch(`${base}/health`);
  const openBody = await open.json();
  assert.strictEqual(open.status, 200);
  assert.strictEqual(openBody.auth, 'guest');

  const issue = async (name) => {
    const response = await fetch(`${base}/auth/guest`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ name }) });
    const body = await response.json();
    assert.strictEqual(response.status, 200);
    assert.strictEqual(body.ok, true);
    assert.notStrictEqual(body.userId, name);
    return body;
  };
  const host = await issue('Ada');
  const guest = await issue('Grace');
  assert.notStrictEqual(host.userId, guest.userId);

  const connect = (token) => new Promise((resolve, reject) => {
    const socket = io(base, { auth: { token }, transports: ['websocket'], reconnection: false });
    socket.once('connect', () => resolve(socket));
    socket.once('connect_error', reject);
  });
  const rejected = io(base, { auth: { token: `dev:${host.userId}:Ada` }, transports: ['websocket'], reconnection: false });
  const rejection = new Promise((resolve) => rejected.once('connect_error', resolve));
  const err = await rejection;
  assert.match(err.message, /UNAUTHORIZED/);
  rejected.close();

  const [a, b] = await Promise.all([connect(host.token), connect(guest.token)]);
  t.after(() => { a.close(); b.close(); });
  const ack = (socket, event, payload) => new Promise((resolve) => socket.emit(event, payload, resolve));
  const created = await ack(a, 'create_room', { gameType: 'memory', maxPlayers: 2, memoryCardCount: 8 });
  assert.strictEqual(created.ok, true);
  const joined = await ack(b, 'join_room', { code: created.room.code });
  assert.strictEqual(joined.ok, true);
  assert.deepStrictEqual(joined.room.players.map((p) => p.userId).sort(), [host.userId, guest.userId].sort());
});
