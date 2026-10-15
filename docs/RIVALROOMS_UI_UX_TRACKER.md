# RivalRooms Implementation Tracker

Last updated: 2026-10-15 15:45 (Asia/Calcutta)

Previous detailed design and implementation notes are preserved in [RIVALROOMS_UI_UX_TRACKER_HISTORY.md](RIVALROOMS_UI_UX_TRACKER_HISTORY.md).

## Latest verified progress — 2026-10-15
- CI run `38718240499` passed on commit `61b1d6f7c62830c16d345ce043a65b99da7ceafc`: Flutter analyze, Flutter tests, and server tests all succeeded. Candy Match 3 and Fruit Cut syntax/test issues are resolved at that commit.
- Pool is implemented as a local pass-and-play table game in `mobile/lib/games/pool_game.dart`, with score/turn tracking, drag-to-aim shots, ball movement/collisions, pockets, restart and Back controls. Home-card routing and a widget test are included. CI run `38719377649` passed: Flutter analysis, Flutter tests, and server tests succeeded. Pool is code/CI-verified but still needs device playtesting.
- Candy Match 3 is code/CI-verified at commit `61b1d6f7c62830c16d345ce043a65b99da7ceafc`.
- Battleship is now implemented in `mobile/lib/games/battleship_game.dart`: randomized starting player, hidden-fleet handoff curtain between turns, generated non-overlapping fleets, hit/miss tracking, sunk-ship detection, restart/rematch and Back controls. Home-card routing and a widget test are included. CI run `38719682315` passed Flutter analysis, Flutter tests and server tests.
- Pool and Battleship are local pass-and-play implementations; neither has been device-playtested, and neither is online-synchronized. Online multiplayer remains a separate unfinished integration.

## Boundaries
- Write only to RivalRooms; keep Two-player-online read-only.
- Exclude Snake Classic and Penalty Shoot. Fruit Cut replaces Fruit Duel.
- Count a game only when its core loop works; preview cards do not count.
- Keep visible Back navigation and explicit confirmation before leaving an active online match.

## Local playable games — 11 code/CI-verified, not device-playtested
1. Memory Match
2. Basketball Hoops
3. Fruit Cut
4. Suika Pop
5. Hexa Ring Sort
6. Guess the Person (one clue and one answer per round)
7. Connect Four
8. Maths Duel
9. Candy Match 3
10. Pool
11. Battleship

This count is based on source and CI, not device playtesting. Hexa Ring Sort generated-level solvability still needs dedicated verification.

## Fruit Cut Arcade upgrade — validation pending
- Arcade source commit: `64eb5302f839b9ee496d56aad0b005df6e1e04c2` — added `mobile/lib/games/fruit_cut_arcade_game.dart`.
- Route integration commit: `e1c39f0b7c4ba3091c785cc05e9e6597004992d8` — Fruit Cut now opens the swipe-based arcade rather than the previous tap-fruit/30-second prototype.
- Follow-up fixes: `81521ab645c45f33716206a223d97fa3e8c27106`, `53c2d8e3905e25e49784eee08007ff696dc5e7da`, and `d761da8885dfc10afc75800ce4fb64c3ffb74908` — numeric type handling, lives display, and level-map modal closure.
- Widget tests: `f1a9579c5fcc7d8843764ffc89ce6b6e051b6372` — verifies the arena HUD, navigation, power-up controls, and level-map/difficulty controls.
- Test reliability follow-up: `6e37df163fd36a48efaeab361e832accb4eac323` — avoids pumpAndSettle while the game ticker is active.
- Features ported from the supplied HTML concept: pointer-swipe slicing arena, fruit waves and visual juice particles, bomb hazards, lives, score and slice target, difficulty scaling, 50 level slots/unlock progression, Freeze/Frenzy/Shield power-ups, goal progress bar, restart and Back controls.
- Progress is currently held in memory and resets on app relaunch; persistence is a follow-up. The game is local-only; online multiplayer synchronization is not implemented.
- Validation has not been run locally. GitHub Actions run `38713341061` was queued for the test reliability follow-up at last inspection; do not call this build-verified or count it as newly validated until Flutter analyze/tests pass.

## Candy Match 3 addition — validation pending
- Game source commit: `19eb4d159d209c6f1ce6c766b18cb76150112775` — added `mobile/lib/games/candy_match3_game.dart`.
- Home/library integration commit: `af7df07a9433686c3bd1e376eb47afe3434259fd` — changed `mobile/lib/main.dart` to add the game card and route.
- Callback syntax fix commit: `6539d3466f2a054c4f842f39a07737c365c77104` — corrected state update callbacks in `mobile/lib/games/candy_match3_game.dart`.
- Widget tests commit: `ca842fd9bcdeec67abbd82a278ff1648cf062e65` — added `mobile/test/candy_match3_game_test.dart` for the board HUD, Back/levels/restart controls, power-up controls, and level-map/difficulty UI.
- Follow-up test commit: `7290cb16e25913e41ef21b56d8a9fc3fe40b2ef1` — changed the level-map assertion to avoid assuming level 50 is visible without scrolling.
- Implemented locally in source: 7×7 match-3 grid, adjacent-swap validation, horizontal/vertical match detection, cascading gravity/refill, score/move/goal loop, Easy/Medium/Hard, 50 level slots with per-difficulty unlock progression, hammer, shuffle, color bomb, restart, visible Back, and result dialog. Level progress is currently in-memory only and does not persist across app launches.
- Validation actually run in this environment: repository/file inspection only. Flutter/Dart tests and analyzer have NOT been run here. GitHub Actions run `38712931841` was observed in progress for test commit `ca842fd9bcdeec67abbd82a278ff1648cf062e65`; it had not reached Flutter analysis/tests at last inspection. The viewport-safe follow-up test commit `7290cb16e25913e41ef21b56d8a9fc3fe40b2ef1` should trigger a newer run. Wait for CI on the latest main commit before counting this as a verified playable game. Candy Match 3 is now included in the code/CI-verified total after successful run `38718240499`.
- Known gameplay caveat to check in CI/review: power-ups consume a move; ensure no analyzer/test failures and verify generated board always has a valid move. No device or Android build run.

## Latest code change
- Latest game feature: Fruit Cut Arcade, commit `d761da8885dfc10afc75800ce4fb64c3ffb74908`.
- Previous UI logic change: Connect Four, commit `45a9788a1efccf38af20c548ae2cf0c6c91bbd49`
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
1. Validate Fruit Cut Arcade and Candy Match 3 with CI; fix compile/analyzer/widget-test failures and verify gameplay edge cases. Fix compile/analyzer/widget-test failures and verify the board generation, slicing collisions, and power-up edge cases.
2. Complete the Flutter Socket.IO connection and guest handshake; wire room creation/joining, readiness, server-owned turns/scores/timers, and safe Back/Android Back handling.
3. Finish CI for `45a9788a1efccf38af20c548ae2cf0c6c91bbd49`, fix failures, and record the final result.
4. Migrate remaining reference Flutter assets, source, and tests in small validated batches.
5. Verify Hexa Ring Sort solvability and add tests for more local games.
6. Verify Android release artifacts and deployment only when those steps actually run.

The 50-playable-game target for 2026-10-15 17:00 is not currently realistic. Prioritize verified functionality over inflating the count.
