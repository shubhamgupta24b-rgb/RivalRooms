# RivalRooms UI/UX and Implementation Tracker
Last updated: 2026-10-15 (11:30 IST)

## Repository boundary
- All implementation writes stay in RivalRooms.
- Two-player-online is a read-only reference and has not been modified.
- Keep the design clean, gameplay-first, natural-colour, accessible, and non-gambling-like. Player 1/2 need numeric and colour cues. Exclude Snake Classic and Penalty Shoot; replace Fruit Duel with Fruit Cut.

## Validation status
- Latest verified CI before Connect Four: run `38689838620`, commit `5f2f98b2ca8307aa2d8b3ff417ced6371ae56cf9`. Flutter pub get, analyze, test, Node npm ci and npm test all passed.
- No Android release build, device test, or deployment has been verified.
- Six local playable prototypes/cores are present: Memory Match, Fruit Cut, Basketball Hoops (tap-to-shoot prototype), Guess the Person (single-question round), Suika Pop (fruit merge), and Connect Four (new, CI pending). This is not a claim of online multiplayer parity.
- Other listed games remain previews/placeholders. Flutter room creation/joining is not connected to Socket.IO. Full reference app/assets/tests have not been migrated.

## Game/screen coverage
| Item | Implementation | Validation |
|---|---|---|
| Home/library/Settings | Home, Play online, All games; Privacy Policy stays in Settings | CI passed before Connect Four |
| Memory Match | Local pair matching, moves, restart, completion | CI passed before Connect Four |
| Fruit Cut | Timed local tap-to-slice scoring | CI passed before Connect Four |
| Basketball Hoops | Timed local tap-to-shoot; not physics/server parity | CI passed before Connect Four |
| Guess the Person | One clue, four choices, feedback, Next person starts a new single-question round | CI passed before Connect Four |
| Suika Pop | Native Flutter merge game, 11 tiers, aim/drop, score, overflow, three power-ups, restart | CI passed before Connect Four; no dedicated behavior tests |
| Connect Four | 7×6 board, gravity drops, alternating turns, four-direction win detection, draw, winning cells, restart, Back; blue/red players marked 1/2 | New CI pending |
| Battleship/Pool/Maths Duel | Preview screens; not counted as playable | Not run |
| Online rooms | Explanatory UI only; no Flutter Socket.IO flow | Not run |
| Back/exit confirmation | Visible Back exists on current game screens; active-online-match confirmation and Android system Back policy incomplete | Not run |

## Latest implementation — Connect Four
- Rules: `mobile/lib/games/connect_four_logic.dart`.
- Screen: `mobile/lib/games/connect_four_game.dart`.
- Route: `mobile/lib/main.dart`.
- Rules tests: `mobile/test/connect_four_logic_test.dart`.
- Commits: rules `c0406e8a2e2bad9060440629bc9e88cd2f2724ef`; screen/route/tests `27b4a4dff544d51f5196f4537524b2f9565a4b53`.
- Tests cover legal gravity drops, alternating turns, invalid/full columns, horizontal/vertical/diagonal wins, lockout after win, and reset.
- Validation for Connect Four: not run yet. The green CI above ran on the parent before Connect Four; do not count this game as verified until its own CI passes.

## Existing design specs
`docs/design/HOME_SCREEN_SPEC.md`, `IN_GAME_EXIT_NAVIGATION_SPEC.md`, `BASKETBALL_HOOPS_SPEC.md`, `FRUIT_CUT_SPEC.md`, `MEMORY_GAME_SPEC.md`, `MATHS_DUEL_SPEC.md`, `GUESS_PERSON_SPEC.md`, `POOL_SPEC.md`, `CONNECT_FOUR_SPEC.md`, `BATTLESHIP_SPEC.md`, `MINES_SWAPPER_SPEC.md`, `BALL_SORT_COVER_SPEC.md`, `MULTIPLAYER_LOBBY_SPEC.md`.

## Blockers and next work
1. Run Flutter analyze/tests and Node tests for Connect Four; fix failures before merge.
2. Migrate existing Flutter source, game logic, assets, and tests from the read-only reference in dependency-aware batches.
3. Wire Flutter to the authoritative Socket.IO server; preserve room state, turns, scores, timers, reconnect behavior, and safe active-match exit.
4. Replace placeholders with tested core loops. Fifty playable games by 17:00 IST is not realistic from the current migrated state; report verified counts honestly.
5. Verify Android release build and deployment only after running those checks.
