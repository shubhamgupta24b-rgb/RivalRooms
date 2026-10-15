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
| Basketball Hoops | Not started | Not started | Not run | Preserve shot action, score, round phase, timer and server synchronization |
| Fruit Cut | Not started | Not started | Not run | Preserve slash action, fruit ID/lane, score/phase/timer and server synchronization |
| Settings | Not started | Not started | Not run | Privacy Policy lives here, not on Home |
| Game-selection/detail screens beyond the above | Not started | Not started | Not run | Add each screen/game to this table before working on it to prevent repeats |

## This iteration
- **Principle:** progressive disclosure and clear mode hierarchy. Put the four main play paths first; keep account/settings/records secondary; keep Privacy Policy inside Settings.
- **Applied to:** Home / game-selection screen.
- **Artifact:** `docs/design/HOME_SCREEN_SPEC.md`.
- **Code changes:** none; this repository still needs the Flutter project source.
- **Tests/build/deployment:** not run; no application source is present in this repository.

## Next work
1. Bring the necessary Flutter app and server source into this repository without modifying the old repository.
2. Reconcile the Home spec with the real navigation and catalogue; preserve existing behavior and never display a fake connected/match state.
3. Implement and validate Home.
4. Design Basketball Hoops next, then Fruit Cut, recording each separately here.
5. Only after source and environment configuration are present, run Flutter tests/build and inspect Render deployment health.
