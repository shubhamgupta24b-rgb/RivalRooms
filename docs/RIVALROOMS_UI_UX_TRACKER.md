# RivalRooms UI/UX and Implementation Tracker
Last updated: 2026-10-15 (11:30 IST)

## Repository boundary
- All implementation writes stay in RivalRooms. Two-player-online is read-only and unchanged.
- Keep UI gameplay-first, uncluttered, natural-colour, accessible, and non-gambling-like. Player 1/2 need colour and numeric cues. Exclude Snake Classic and Penalty Shoot; replace Fruit Duel with Fruit Cut.

## Validation status
- Last fully verified CI before Connect Four: run `38689838620`, commit `5f2f98b2ca8307aa2d8b3ff417ced6371ae56cf9`. Flutter pub get, analyze, test, Node npm ci, and npm test all passed.
- CI for screen commit `6505918f622dd4f7b37d7ae36c689ab752d021c7` was observed in progress. The integrated route/tests commit `520d8f771c475d4580ec9a4d3e088ab5cb808caf` has not yet been validated.
- No Android release build, device test, or deployment has been verified.
- Six local playable prototypes/cores exist: Memory Match, Fruit Cut, Basketball Hoops (tap-to-shoot prototype), Guess the Person (single-question), Suika Pop (fruit merge), and Connect Four (validation pending). This does not imply online multiplayer parity.
- Other listed games remain preview/placeholders. Flutter room creation/joining is not connected to Socket.IO; the full reference app/assets/test suite has not been migrated.

## Game/screen coverage
| Item | Implementation | Validation |
|---|---|---|
| Home/library/Settings | Home, Play online, All games; Privacy Policy stays in Settings | CI passed before Connect Four |
| Memory Match | Local pairs, moves, restart, completion | CI passed before Connect Four |
| Fruit Cut | Timed local tap-to-slice scoring | CI passed before Connect Four |
| Basketball Hoops | Timed tap-to-shoot prototype; not physics/server parity | CI passed before Connect Four |
| Guess the Person | One clue, four choices, feedback, Next person starts one fresh question | CI passed before Connect Four |
| Suika Pop | Native Flutter merge game, 11 tiers, aim/drop, score, overflow, three power-ups | CI passed before Connect Four; no dedicated behavior tests |
| Connect Four | 7×6 board, gravity drops, alternating turns, four-direction win detection, draw, winning-cell state, restart, Back; blue/red players marked 1/2 | New integration CI pending |
| Battleship/Pool/Maths Duel | Preview screens, not counted as playable | Not run |
| Online rooms | Explanatory UI only; no Flutter Socket.IO flow | Not run |
| Back/exit confirmation | Visible Back on current games; active online-match confirmation and Android Back policy incomplete | Not run |

## Latest implementation — Connect Four
- Rules: `mobile/lib/games/connect_four_logic.dart` (commit `c0406e8a2e2bad9060440629bc9e88cd2f2724ef`).
- Screen: `mobile/lib/games/connect_four_game.dart` (commit `6505918f622dd4f7b37d7ae36c689ab752d021c7`).
- Route: `mobile/lib/main.dart`; tests: `mobile/test/connect_four_logic_test.dart` (commit `520d8f771c475d4580ec9a4d3e088ab5cb808caf`).
- Tests cover drops, turn alternation, invalid/full columns, horizontal/vertical/diagonal wins, lockout after win, and reset.
- Connect Four-specific validation has not completed. Do not count it as verified until Flutter analyze and tests pass on the integrated commit.

## Existing design specs
`docs/design/HOME_SCREEN_SPEC.md`, `IN_GAME_EXIT_NAVIGATION_SPEC.md`, `BASKETBALL_HOOPS_SPEC.md`, `FRUIT_CUT_SPEC.md`, `MEMORY_GAME_SPEC.md`, `MATHS_DUEL_SPEC.md`, `GUESS_PERSON_SPEC.md`, `POOL_SPEC.md`, `CONNECT_FOUR_SPEC.md`, `BATTLESHIP_SPEC.md`, `MINES_SWAPPER_SPEC.md`, `BALL_SORT_COVER_SPEC.md`, `MULTIPLAYER_LOBBY_SPEC.md`.

## Blockers and next work
1. Get integrated Connect Four CI green; fix analyzer/test errors before merge.
2. Migrate existing Flutter source, game logic, assets, and tests from the read-only reference in dependency-aware batches.
3. Wire Flutter to the authoritative Socket.IO server, preserving room state, turns, scores, timers, reconnects, and safe active-match exit.
4. Replace placeholders with tested core loops. Fifty playable games by 17:00 IST is not realistic from the current migrated state; report verified counts honestly.
5. Verify Android release build and deployment only after those checks actually run.
