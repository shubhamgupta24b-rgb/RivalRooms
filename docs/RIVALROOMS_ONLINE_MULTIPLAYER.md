# RivalRooms online multiplayer

Last checked: 2026-10-15.

## What is actually online

Memory Match is the online game. Two independent clients can create or join a room, ready up, and finish a match. The server deals the cards, hides unmatched values, rejects the wrong turn, rejects a repeated sequence number, and decides the result.

That was verified with:

- Two Socket.IO clients in `server/tests/online_memory_flow.test.js`, including a finished 8-card match.
- Two Flutter `OnlineSession` clients in `mobile/test/online_memory_client_test.dart`, speaking to a local `node src/index.js`.
- Guest sign-in in `server/tests/guest_auth.test.js`: production guest mode stays unhealthy until `GUEST_TOKEN_SECRET` is set, dev tokens are rejected, and two issued guest tokens can join one room.

It was not verified on two physical phones. Quick Play, private rooms, rematch, and leaving a room are covered by the socket tests. A phone install still needs the server address typed on Play online.

Every other home-screen game stays local. The app does not switch a failed online connection into a local match.

## Event flow

The Flutter client uses `socket_io_client` with the server's existing events. Each request waits for an acknowledgement, `{ ok: true, ... }` or `{ ok: false, error, message }`, and gives up after 8 seconds.

| Player action | Client call | Server handler |
| --- | --- | --- |
| Connect | Socket.IO handshake `auth.token` | `verifyToken` |
| Open Play online | `POST /auth/guest` when guest auth is enabled | `index.js` |
| Create room | `create_room` `{ gameType: "memory", maxPlayers, memoryCardCount }` | `RoomManager.createRoom` |
| Join | `join_room` `{ code }` | `RoomManager.joinRoom` |
| Quick Play | `quick_play` `{ gameType: "memory" }` | `RoomManager.quickPlay` |
| Ready | `player_ready` / `player_unready` | `RoomManager.setReady` |
| Start | `start_game` | `RoomManager.startGame`, then `round_started` and `game_state` |
| Flip a card | `game_action` `{ type: "memory:flip", seq, payload: { id } }` | `memory.onAction` |
| Rematch | `next_game` `{ gameType: "memory" }` | `RoomManager.nextGame` |
| Back to lobby | `return_to_lobby` | `RoomManager.returnToLobby` |
| Leave | `leave_room` | `RoomManager.leave` |
| App reconnects | `resume_session` | `RoomManager.reconnect` |

Pushes: `room_state`, `game_state`, `game_finished`, `player_disconnected`, `player_reconnected`, `error` (`SESSION_REPLACED`, `GAME_ABORTED`).

Each Flutter socket uses its own manager (`forceNew`, multiplex off). Reconnect uses bounded backoff, up to 6 attempts. A replaced session stops that socket. Listeners are removed when the Play online page is disposed.

## Authentication

Three modes, selected with `AUTH_MODE`:

| Mode | Who it is for | Identity |
| --- | --- | --- |
| `dev` | Local tests and a debug build against a dev server | Token `dev:<id>:<name>`. Refused when `NODE_ENV=production` unless `ALLOW_DEV_AUTH=true`. Do not use that switch on a public server. |
| `guest` | The free single-server deploy | `POST /auth/guest` with a display name. The server generates the player id and returns an HMAC token (`g1...`) signed with `GUEST_TOKEN_SECRET`. The client cannot choose another player's id. Tokens expire after 7 days. |
| `firebase` | When a Firebase project exists | `firebase-admin` verifies a Firebase ID token. Set `FIREBASE_SERVICE_ACCOUNT_JSON` or `GOOGLE_APPLICATION_CREDENTIALS`. The Flutter app does not yet run Firebase sign-in, so this mode rejects every current build. |

`/health` is 503 with `auth: "unconfigured"` when guest mode has no secret, or Firebase mode has no credentials. A database is not required. `db: "disabled"` is healthy.

## Local development

Server:

```bash
cd server
npm ci
npm test
npm start
```

Default port is 3000. `AUTH_MODE` defaults to `dev`. Copy `server/.env.example`. Do not put a real secret in it.

App, from `mobile`:

```bash
flutter run --dart-define=SERVER_URL=http://127.0.0.1:3000
```

On a phone, use the computer's LAN address, for example `http://10.0.2.2:3000` for the Android emulator or `http://192.168.x.x:3000` for a device on the same Wi-Fi. Debug builds allow cleartext HTTP and, if `/auth/guest` is absent, fall back to a dev token. Release builds do not. A release build needs `https://` and `AUTH_MODE=guest`.

The address can also be typed on the Play online tab. It is saved on the device. There is no hardcoded production URL.

Smoke, against a server that is already running:

```bash
cd server
npm run smoke -- http://127.0.0.1:3000
```

Smoke uses dev tokens when health reports `auth: "dev"`, and `/auth/guest` when it reports `auth: "guest"`.

## Render

Not deployed from this environment. The blueprint in `render.yaml` matches the code:

- Repository: `shubhamgupta24b-rgb/RivalRooms`
- Runtime: Node, not Docker
- Root directory: `server`
- Build: `npm ci`
- Start: `npm start`
- Health check: `/health`
- Plan: free
- `NODE_ENV=production`
- `AUTH_MODE=guest`

Dashboard steps:

1. Render → New → Blueprint, and select this repository. Or New Web Service with the settings above.
2. Set `GUEST_TOKEN_SECRET` to a random string of at least 16 characters. Render asks because the blueprint marks it `sync: false`.
3. Set `PRIVACY_CONTACT` to a real contact address. It is shown on `/privacy`.
4. Deploy. Open `https://<service>.onrender.com/health`. It is ready only when `ok` is true and `auth` is `guest`.
5. In the app's Play online field, enter that `https://` origin. No path.

`PORT` is set by Render. The process listens on `process.env.PORT` and `0.0.0.0`. Do not set `PORT` or `HOST` yourself. Do not set `ALLOW_DEV_AUTH`.

Optional, all empty by default: `MONGO_URI`, `CORS_ORIGIN` (default `*`), `RECONNECT_GRACE_MS` (default 60000), `FIREBASE_PROJECT_ID`, `GOOGLE_APPLICATION_CREDENTIALS`, `FIREBASE_SERVICE_ACCOUNT_JSON`.

Free-tier consequences, from Render's current free web-service terms: the service can sleep, the first request after sleep can take about a minute, and monthly hours are capped. Rooms live in memory. A restart or a cold start deletes active matches. `/health` does not pretend those rooms survived. There is no Redis and no paid load balancer.

## Rooms

`MemoryRoomStore` keeps rooms in the Node process. A player may reconnect within `RECONNECT_GRACE_MS` (60 seconds) and `resume_session` returns the same room. After the grace period the seat is removed. Two connections for the same player replace the old socket (`SESSION_REPLACED`). Private rooms are not listed for Quick Play. Quick Play from this app always asks for Memory Match, so it will not drop someone into a relay game.

The host starts only when the player count fits the game and every player is ready and connected. Memory allows 2 to 4 players and card counts 8, 12, 16, 20, 24, 28, 32.

## Games

| Game | Flutter client | Server | Online status | Test status |
| --- | --- | --- | --- | --- |
| Memory Match | Local game, plus Play online | Authoritative `memory` | Online for Play online. Library card stays local. | Two socket clients and two Flutter sessions finished a match. |
| Maths Duel | Local pass-and-play | Relay id `math_duel` only. The host can publish state and scores. | Not online | Local rules tested. Not wired to sockets. |
| Connect Four | Local | Relay id `connect_four` | Not online | Local rules tested, including a draw. |
| Hexa Ring Sort | Local | None | Not online | 150 generated levels replay. |
| Fruit Cut | Local arcade | `fruit_duel` is a different game | Not online | Local widget test. |
| Basketball Hoops | Local tap timer | Relay id, not the Flutter tap game | Not online | Local only. |
| Suika Pop | Local | None | Not online | Not an online game. |
| Guess the Person | One local clue and one answer | Separate timed game, excluded from rooms | Not online | Local behaviour kept. |
| Battleship, Pool, Carrom, Bike Racing | Local | Relay ids where those names exist. Pool is not `eight_ball`. | Not online | Local widget tests. |
| Candy Match 3, Chicken Jump | Local | None | Not online | Local widget tests. |
| Raja Mantri Chor Sipahi | Local four-player pass-and-play | Authoritative server module, not connected to this client | Not online | Server socket test and local widget test are separate. |

Relay modules are intentionally unused by the Flutter client. A relay host can submit scores. That does not meet the authoritative-game rule.

## Tests run on 2026-10-15

- `npm test` in `server`: 98 passed, 0 failed.
- `flutter analyze` in `mobile`: no issues.
- `flutter test` in `mobile`: 39 passed, including the online session, the Play online failure state, and two Flutter sessions finishing Memory Match.
- `npm run smoke -- http://127.0.0.1:3010`: `SMOKE OK` in 628ms against this working tree.
- `npm run smoke` is the script above. It needs a running server.

## Later scaling

Do not add Redis just to say the service scales. One process is the source of truth. A Socket.IO Redis adapter would not share `MemoryRoomStore` or the in-memory seat map. A second instance would need all of the following, and none of it is implemented:

1. Shared room and session storage.
2. Atomic membership and action processing.
3. One owner per active room.
4. Cross-instance event delivery.
5. Reconnect and owner-failure recovery.
6. Idempotent actions. Memory already ignores a sequence number that is not newer, but that map is process-local.
7. Health checks that can tell a room owner from an idle process.

Until that exists, run one web service.

## APK

Debug builds are produced by `.github/workflows/android-apk.yml` and uploaded as `rivalrooms-debug-apk`. The file inside the artifact is `mobile/build/app/outputs/flutter-apk/app-debug.apk`. A local debug build writes the same path and is gitignored. Release builds in this repo are signed with the debug keystore. That is not a Play Store build.
