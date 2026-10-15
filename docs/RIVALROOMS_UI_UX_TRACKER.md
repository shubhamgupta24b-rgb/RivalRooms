# RivalRooms UI/UX Iteration Tracker

Last updated: 2026-10-15

## Repository boundary
- Design and implementation writes go only to [RivalRooms](https://github.com/shubhamgupta24b-rgb/RivalRooms).
- The previous `Two-player-online` repository is a read-only reference for existing flows and game logic; do not modify it.
- Current state at the start of this iteration: RivalRooms repository was empty. No Flutter source, tests, or Render configuration are present here yet.
- This commit adds planning/specification only. It does not claim the app has been migrated, built, tested, or deployed.

## Research status
- [x] Apple Human Interface Guidelines — designing for games: fast entry to play, readable text, responsive layouts, accessible controls, do not rely on color alone.
- [x] Apple Human Interface Guidelines — game controls: direct manipulation when appropriate, thumb-reachable controls, visible press feedback, avoid unnecessary controls over the play area.
- [x] Material Design accessibility: target at least 48 × 48 dp with about 8 dp spacing.
- [x] Google Playables design best practices: responsive sizing, legible contrast, clear button states, concise onboarding and clear pause/end states.

References:
- https://developer.apple.com/design/human-interface-guidelines/designing-for-games/
- https://developer.apple.com/design/human-interface-guidelines/game-controls
- https://m1.material.io/usability/accessibility.html
- https://developers.google.com/youtube/gaming/playables/certification/best_practices_design

## Iteration rule
Every iteration must:
1. Select one specific UI/UX principle.
2. Apply it to a screen/game not already covered.
3. record a concrete specification or implementation artifact.
4. Track changed files and actual validation separately; never mark a build/test/deployment as successful without running it.

## Screen/game coverage

| Item | Design/spec | Implementation | Validation | Notes |
|---|---|---|---|---|
| Home / game-selection screen | Spec written in `docs/design/HOME_SCREEN_SPEC.md` | Not started | Not run | Four explicit entry modes; compact game previews; Privacy Policy stays in Settings |
| Basketball Hoops | `docs/design/BASKETBALL_HOOPS_SPEC.md` | Not started | Not run | Primary Shoot action; preserve timing, score, phase and server updates |
| Fruit Cut | `docs/design/FRUIT_CUT_SPEC.md` | Not started | Not run | Swipe-first layout; preserve fruit ID/lane, score, phase and server updates |
| Settings | Not started | Not started | Not run | Privacy Policy lives here, not on Home |
| In-game Back / Exit navigation | Spec written in `docs/design/IN_GAME_EXIT_NAVIGATION_SPEC.md` | Not started | Not run | Visible 48 dp back control; confirm leaving active online matches; system Back matches visible Back; preserve room/game state |
| Memory | `docs/design/MEMORY_GAME_SPEC.md` | Not started | Not run | Stable card grid; preserve pair/turn state |
| Maths Duel | `docs/design/MATHS_DUEL_SPEC.md` | Not started | Not run | One-question focus; preserve answer validation and timer |
| Guess the Person | `docs/design/GUESS_PERSON_SPEC.md` | Not started | Not run | Progressive hints; preserve hint order and scoring |
| Pool | `docs/design/POOL_SPEC.md` | Not started | Not run | Separate aiming from shooting; preserve physics |
| Connect Four | `docs/design/CONNECT_FOUR_SPEC.md` | Not started | Not run | Legal-move preview; preserve win detection and turns |
| Battleship | `docs/design/BATTLESHIP_SPEC.md` | Not started | Not run | Separate targeting states; preserve hidden information |
| MinesSwapper | `docs/design/MINES_SWAPPER_SPEC.md` | Not started | Not run | Clear level/difficulty; preserve progression |
| Ball Sort Cover | `docs/design/BALL_SORT_COVER_SPEC.md` | Not started | Not run | Redundant color/state cues; preserve puzzle rules |
| Multiplayer Room Lobby | `docs/design/MULTIPLAYER_LOBBY_SPEC.md` | Not started | Not run | Real connection/readiness states only |
| Game-selection/detail screens beyond the above | Not started | Not started | Not run | Add each screen/game to this table before working on it to prevent repeats |

## Previous iteration
- **Principle:** progressive disclosure and clear mode hierarchy. Put the four main play paths first; keep account/settings/records secondary; keep Privacy Policy inside Settings.
- **Applied to:** Home / game-selection screen.
- **Artifact:** `docs/design/HOME_SCREEN_SPEC.md`.
- **Code changes:** specification only; Flutter source is not present in this repository.
- **Tests/build/deployment:** not run.

## Previous iteration — In-game Back / Exit
- **Principle:** prevent errors through clear, reversible navigation and informed confirmation.
- **Applied to:** shared in-game header and exit confirmation flow.
- **Artifact:** `docs/design/IN_GAME_EXIT_NAVIGATION_SPEC.md`.
- **Design change:** every game gets a clear top-left Back control; active online matches require explicit confirmation before leaving; Android system Back follows the same policy.
- **Code changes:** specification only; no Flutter source is present to implement it yet.
- **Tests/build/deployment:** not run.

## Current iteration — First 10-game design batch
- **Principle:** one strong gameplay hierarchy per game; controls and status are visible without clutter.
- **Applied to:** Basketball Hoops, Fruit Cut, Memory, Maths Duel, Guess the Person, Pool, Connect Four, Battleship, MinesSwapper, and Ball Sort Cover. Added a supporting Multiplayer Room Lobby spec as a shared-flow screen.
- **Artifacts:** individual specs under `docs/design/` listed in the coverage table above.
- **Design constraints:** consistent top-left Back affordance; explicit leave confirmation for active online matches; blue/red identities with redundant cues; preserve gameplay mechanics, scores, timers, navigation and online synchronization.
- **Code changes:** design specifications only. Flutter source has not been migrated into this repository, so implementation is not started.
- **Tests/build/deployment:** not run.

## Next work
1. Migrate the required Flutter app and server source into this repository without modifying the old repository.
2. Reconcile these specifications with actual game rules and navigation before implementation.
3. Implement Home and shared Back / Exit behavior.
4. Implement and validate Basketball Hoops, then Fruit Cut, while recording each completed item.
5. Inspect Render only after the backend/configuration exists; never claim a deployment or build without validation.
