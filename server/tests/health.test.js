const test = require('node:test');
const assert = require('node:assert');
const { createServer } = require('../src/index');
const { getDbStatus } = require('../src/database');

test('health reports a ready server when the database is not required', async (t) => {
  const srv = createServer();
  await new Promise((resolve) => srv.httpServer.listen(0, '127.0.0.1', resolve));
  t.after(() => new Promise((resolve) => srv.httpServer.close(resolve)));
  const { port } = srv.httpServer.address();
  const response = await fetch(`http://127.0.0.1:${port}/health`);
  const body = await response.json();
  assert.strictEqual(response.status, 200);
  assert.strictEqual(body.ok, true);
  assert.strictEqual(body.app, 'rivalrooms');
  assert.strictEqual(body.db, getDbStatus());
  assert.notStrictEqual(body.db, 'error');
  assert.strictEqual(body.auth, 'dev');
});
