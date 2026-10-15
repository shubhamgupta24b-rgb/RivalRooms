const test = require('node:test');
const assert = require('node:assert');
const { io } = require('socket.io-client');
const { createServer } = require('../src/index');

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const ack = (socket, event, payload = {}) => new Promise((resolve) => socket.emit(event, payload, resolve));
const connect = (port, uid, name = uid) => new Promise((resolve, reject) => {
  const socket = io(`http://127.0.0.1:${port}`, { auth: { token: `dev:${uid}:${name}` }, transports: ['websocket'], reconnection: false });
  socket.once('connect', () => resolve(socket));
  socket.once('connect_error', reject);
});

async function listen(port = 0) {
  const srv = createServer({ graceMs: 1500 });
  await new Promise((resolve) => srv.httpServer.listen(port, '127.0.0.1', resolve));
  return srv;
}

test('unauthorized and malformed socket requests are rejected', { timeout: 20000 }, async (t) => {
  const srv = await listen();
  const { port } = srv.httpServer.address();
  t.after(() => { srv.io.close(); srv.httpServer.close(); });
  const bad = io(`http://127.0.0.1:${port}`, { auth: { token: 'not-a-token' }, transports: ['websocket'], reconnection: false });
  const err = await new Promise((resolve) => bad.once('connect_error', resolve));
  assert.match(err.message, /UNAUTHORIZED/);
  bad.close();

  const host = await connect(port, 'host1', 'Host');
  t.after(() => host.close());
  const unknown = await ack(host, 'create_room', { gameType: 'not_a_game', maxPlayers: 2 });
  assert.strictEqual(unknown.ok, false);
  assert.strictEqual(unknown.error, 'INVALID_PAYLOAD');
  const created = await ack(host, 'create_room', { gameType: 'memory', maxPlayers: 2, memoryCardCount: 8 });
  assert.strictEqual(created.ok, true);
  const early = await ack(host, 'start_game', {});
  assert.strictEqual(early.error, 'NOT_ENOUGH_PLAYERS');
  const badCode = await ack(host, 'join_room', { code: 'nope' });
  assert.strictEqual(badCode.error, 'INVALID_PAYLOAD');

  const guest = await connect(port, 'guest1', 'Guest');
  const extra = await connect(port, 'extra1', 'Extra');
  t.after(() => { guest.close(); extra.close(); });
  const joined = await ack(guest, 'join_room', { code: created.room.code.toLowerCase() });
  assert.strictEqual(joined.ok, true);
  assert.strictEqual(joined.room.players.length, 2);
  const full = await ack(extra, 'join_room', { code: created.room.code });
  assert.strictEqual(full.error, 'ROOM_FULL');
  const notReady = await ack(host, 'start_game', {});
  assert.strictEqual(notReady.error, 'PLAYERS_NOT_READY');
  assert.strictEqual((await ack(guest, 'start_game', {})).error, 'NOT_HOST');
});

test('memory moves are authoritative for both clients', { timeout: 20000 }, async (t) => {
  const srv = await listen();
  const { port } = srv.httpServer.address();
  const host = await connect(port, 'host1', 'Host');
  const guest = await connect(port, 'guest1', 'Guest');
  t.after(() => { host.close(); guest.close(); srv.io.close(); srv.httpServer.close(); });
  let hostState = null;
  let guestState = null;
  let finished = null;
  const seen = new Map();
  const note = (state) => {
    for (const card of state.cards) {
      if (!card.value || card.matched) continue;
      const ids = seen.get(card.value) || [];
      if (!ids.includes(card.id)) ids.push(card.id);
      seen.set(card.value, ids);
    }
  };
  host.on('game_state', (state) => { hostState = state; note(state); });
  guest.on('game_state', (state) => { guestState = state; });
  guest.on('game_finished', (result) => { finished = result; });

  const created = await ack(host, 'create_room', { gameType: 'memory', maxPlayers: 2, memoryCardCount: 8 });
  const hostSawJoin = new Promise((resolve) => host.once('room_state', resolve));
  const joined = await ack(guest, 'join_room', { code: created.room.code });
  const both = await hostSawJoin;
  assert.strictEqual(joined.room.players.length, 2);
  assert.strictEqual(both.players.length, 2);
  await ack(guest, 'player_ready', {});
  const started = await ack(host, 'start_game', {});
  assert.strictEqual(started.ok, true);
  await until(() => hostState && guestState);
  assert.ok(hostState.cards.every((card) => card.value === null));
  assert.strictEqual(guestState.you.userId, 'guest1');
  assert.notStrictEqual(hostState.you.userId, guestState.you.userId);

  const wrongTurn = await ack(guest, 'game_action', { type: 'memory:flip', seq: 1, payload: { id: 0 } });
  assert.strictEqual(wrongTurn.error, 'BAD_PHASE');
  assert.strictEqual(hostState.selected.length, 0);
  const first = await ack(host, 'game_action', { type: 'memory:flip', seq: 1, payload: { id: 0 } });
  assert.strictEqual(first.ok, true);
  await until(() => hostState.selected.length === 1);
  const duplicate = await ack(host, 'game_action', { type: 'memory:flip', seq: 1, payload: { id: 1 } });
  assert.strictEqual(duplicate.error, 'DUPLICATE_ACTION');
  assert.deepStrictEqual(hostState.selected, [0]);
  const cheat = await ack(host, 'game_action', { type: 'relay:finish', seq: 2, payload: { scores: [9, 0] } });
  assert.strictEqual(cheat.error, 'INVALID_ACTION');
  assert.strictEqual(hostState.scores.host1, 0);

  const seq = { host1: 3, guest1: 2 };
  let guard = 0;
  while (hostState.phase !== 'finished' && guard++ < 30) {
    await until(() => hostState.phase === 'turn' || hostState.phase === 'finished');
    if (hostState.phase === 'finished') break;
    const actor = hostState.turn === 'host1' ? host : guest;
    const uid = hostState.turn;
    if (hostState.selected.length === 1) {
      const open = hostState.selected[0];
      const openValue = hostState.cards.find((card) => card.id === open).value;
      const known = (seen.get(openValue) || []).filter((id) => id !== open);
      const other = hostState.cards.filter((card) => !card.matched && card.id !== open);
      const secondId = known[0] ?? other[0].id;
      assert.strictEqual((await ack(actor, 'game_action', { type: 'memory:flip', seq: seq[uid]++, payload: { id: secondId } })).ok, true);
      continue;
    }
    const unmatched = hostState.cards.filter((card) => !card.matched);
    let pair = null;
    for (const ids of seen.values()) {
      const live = ids.filter((id) => unmatched.some((card) => card.id === id));
      if (live.length >= 2) { pair = live.slice(0, 2); break; }
    }
    if (pair) {
      assert.strictEqual((await ack(actor, 'game_action', { type: 'memory:flip', seq: seq[uid]++, payload: { id: pair[0] } })).ok, true);
      assert.strictEqual((await ack(actor, 'game_action', { type: 'memory:flip', seq: seq[uid]++, payload: { id: pair[1] } })).ok, true);
      continue;
    }
    const knownIds = new Set([...seen.values()].flat());
    const unknown = unmatched.filter((card) => !knownIds.has(card.id));
    const firstId = unknown[0].id;
    assert.strictEqual((await ack(actor, 'game_action', { type: 'memory:flip', seq: seq[uid]++, payload: { id: firstId } })).ok, true);
    await until(() => hostState.cards.find((card) => card.id === firstId).value);
    const value = hostState.cards.find((card) => card.id === firstId).value;
    const known = (seen.get(value) || []).filter((id) => id !== firstId && unmatched.some((card) => card.id === id));
    const secondId = known[0] ?? unknown.find((card) => card.id !== firstId).id;
    assert.strictEqual((await ack(actor, 'game_action', { type: 'memory:flip', seq: seq[uid]++, payload: { id: secondId } })).ok, true);
  }
  await until(() => finished);
  assert.strictEqual(hostState.phase, 'finished');
  assert.deepStrictEqual(hostState.scores, guestState.scores);
  assert.ok(finished.winners.length >= 1);
  const after = await ack(host, 'game_action', { type: 'memory:flip', seq: 90, payload: { id: 0 } });
  assert.strictEqual(after.error, 'BAD_PHASE');
});

test('disconnect restores the room and leave removes the player', { timeout: 20000 }, async (t) => {
  const srv = await listen();
  const { port } = srv.httpServer.address();
  const host = await connect(port, 'host1', 'Host');
  const guest = await connect(port, 'guest1', 'Guest');
  t.after(() => { host.close(); guest.close(); srv.io.close(); srv.httpServer.close(); });
  const created = await ack(host, 'create_room', { gameType: 'memory', maxPlayers: 2, memoryCardCount: 8 });
  await ack(guest, 'join_room', { code: created.room.code });
  const dropped = new Promise((resolve) => host.once('player_disconnected', resolve));
  guest.disconnect();
  const event = await dropped;
  assert.strictEqual(event.userId, 'guest1');
  const again = await connect(port, 'guest1', 'Guest');
  t.after(() => again.close());
  const resumed = await ack(again, 'resume_session', {});
  assert.strictEqual(resumed.room.code, created.room.code);
  assert.strictEqual(resumed.room.players.find((p) => p.userId === 'guest1').connected, true);
  const left = new Promise((resolve) => host.once('room_state', resolve));
  assert.strictEqual((await ack(again, 'leave_room', {})).ok, true);
  const room = await left;
  assert.strictEqual(room.players.length, 1);
  assert.strictEqual((await ack(again, 'resume_session', {})).room, null);
});

test('quick play keeps the same game and rate limits a burst', { timeout: 20000 }, async (t) => {
  const srv = await listen();
  const { port } = srv.httpServer.address();
  const [a, b, c] = await Promise.all([connect(port, 'a1', 'A'), connect(port, 'b1', 'B'), connect(port, 'c1', 'C')]);
  t.after(() => { a.close(); b.close(); c.close(); srv.io.close(); srv.httpServer.close(); });
  const first = await ack(a, 'quick_play', { gameType: 'memory' });
  const second = await ack(b, 'quick_play', { gameType: 'memory' });
  assert.strictEqual(second.room.code, first.room.code);
  assert.strictEqual(second.room.gameType, 'memory');
  const other = await ack(c, 'quick_play', { gameType: 'connect_four' });
  assert.notStrictEqual(other.room.code, first.room.code);
  assert.strictEqual((await ack(c, 'quick_play', { gameType: 'nope' })).error, 'ALREADY_IN_ROOM');
  const fresh = await connect(port, 'd1', 'D');
  t.after(() => fresh.close());
  assert.strictEqual((await ack(fresh, 'quick_play', { gameType: 'nope' })).error, 'INVALID_PAYLOAD');

  const replies = await Promise.all(Array.from({ length: 80 }, () => ack(fresh, 'online_counts', {})));
  assert.ok(replies.some((reply) => reply.ok));
  assert.ok(replies.some((reply) => reply.error === 'RATE_LIMITED'));
});

async function until(pred, ms = 5000) {
  const start = Date.now();
  while (Date.now() - start < ms) {
    if (pred()) return;
    await sleep(20);
  }
  throw new Error('timed out waiting for game state');
}
