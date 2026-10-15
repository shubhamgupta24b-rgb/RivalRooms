# RivalRooms Implementation Tracker

Last updated: 2026-10-15 (Asia/Calcutta)

Previous detailed design and implementation notes are preserved in [RIVALROOMS_UI_UX_TRACKER_HISTORY.md](RIVALROOMS_UI_UX_TRACKER_HISTORY.md).

## Boundaries
- Write only to RivalRooms; keep Two-player-online read-only.
- Exclude Snake Classic and Penalty Shoot. Fruit Cut replaces Fruit Duel.
- Count a game only when its core loop works; preview cards do not count.
- Keep visible Back navigation and explicit confirmation before leaving an active online match.

## Local playable games — 8 identified
1. Memory Match
2. Basketball Hoops
3. Fruit Cut
4. Suika Pop
5. Hexa Ring Sort
6. Guess the Person (one clue and one answer per round)
7. Connect Four
8. Maths Duel

Battleship and Pool are preview cards and are excluded. This count is based on source and CI, not device playtesting. Hexa Ring Sort generated-level solvability still needs dedicated verification.

## Latest code change
- Commit: `45a9788a1efccf38af20c548ae2cf0c6c91bbd49`
- Files: `mobile/lib/games/connect_four_game.dart`, `mobile/test/connect_four_logic_test.dart`.
- Connect Four now shows clear turn/win/draw status, numbered blue/red player discs, disc counts, winning-disc highlights, accessible column labels, restart, and a finished-round action.
- Added rule tests for gravity, alternating turns, invalid/full columns, horizontal/vertical/diagonal wins, win lockout, and reset.

## Validation
- GitHub Actions run `38696916745` was triggered for the code commit above.
- Node job: `npm ci` and `npm test` passed.
- Flutter job: setup was still running at last inspection; `flutter pub get`, `flutter analyze`, and `flutter test` had not started. Do not claim these passed until the run finishes.
- Flutter and Dart executables are not installed locally. No Android release build, device test, or deployment was run.

## Online and migration status
- The Node server, room manager, Socket.IO handlers, game registry, package metadata, tests, and deployment configuration exist in `server/`; production deployment is not verified.
- Flutter create/join/quick-play UI, live game-state rendering/actions, and active-match exit confirmation are not connected yet.
- The client/server guest handshake was not committed in this iteration. No online synchronization is claimed.
- Full source, asset, and test migration from the reference repository remains incomplete. The server's legacy Fruit Duel handler is not a Fruit Cut client.

## Blockers and next work
1. Complete the Flutter Socket.IO connection and guest handshake; wire room creation/joining, readiness, server-owned turns/scores/timers, and safe Back/Android Back handling.
2. Finish CI for `45a9788a1efccf38af20c548ae2cf0c6c91bbd49`, fix failures, and record the final result.
3. Migrate remaining reference Flutter assets, source, and tests in small validated batches.
4. Verify Hexa Ring Sort solvability and add tests for more local games.
5. Verify Android release artifacts and deployment only when those steps actually run.

The 50-playable-game target for 2026-10-15 17:00 is not currently realistic. Prioritize verified functionality over inflating the count.
