# In-Game Back / Exit Navigation — UI Specification

**Status:** specification only; Flutter implementation has not started in this repository.

## Goal
Every playable game must provide an obvious, consistent way to leave the current game and return to the correct previous screen without accidentally losing a live online match.

## Screen preview

```text
┌─────────────────────────────────────┐
│  ‹ Back       GAME TITLE   [⋯]      │
│                                     │
│  Player 1 (blue)       Player 2 (red)│
│  Score / round / timer              │
│                                     │
│            GAMEPLAY                 │
│                                     │
│          Primary controls           │
└─────────────────────────────────────┘
```

## Interaction rules
- Place a back arrow in the top-left safe area on every game screen, with a minimum 48 × 48 dp hit target.
- Give it an accessible label such as “Back to game room” or “Exit game”; do not use an unlabeled icon alone.
- On a non-live single-player/local game, tapping Back opens a compact confirmation if progress would be lost: **Resume** and **Exit game**.
- In an active online match, Back must not silently abandon the match. Show a confirmation sheet that clearly states the consequence and offers **Stay in game** and **Leave match**. If the existing game supports pause/rejoin, reflect the real behavior; never promise rejoin unless it is implemented.
- If a player chooses Leave match, use the existing navigation/room-leave flow and wait for its real result. Do not fake a successful disconnect or change server state only in the UI.
- If the game is already finished, Back returns to the existing result/lobby flow without asking an unnecessary second confirmation.
- Android system Back and the visible Back button must follow the same rules.
- Avoid placing the Back control over a critical gameplay/tap area. Keep score and timer visible and unchanged.
- Preserve existing scoring, game phase, timer, input actions, room state, socket synchronization, and LAN behavior. This is a navigation/UI change only.
- Do not add Privacy Policy or unrelated settings links to the in-game header.

## Accessibility and visual behavior
- Use a consistent arrow icon, text semantics, strong contrast, and a visible pressed state.
- Use the app's existing neutral visual system. Blue remains Player 1 and red remains Player 2; the Back control itself should be neutral.
- Confirmation sheet should be short, non-gambling-like, and use clear verbs rather than alarmist copy.

## Acceptance checks
1. Back is visible and reachable on every game screen.
2. Back during active online play requires an explicit leave decision.
3. Stay in game dismisses the sheet without changing gameplay state.
4. Leave uses the existing room/navigation lifecycle and reports failures honestly.
5. Finished games return to the established result/lobby route.
6. Android system Back behaves consistently with the visible control.
7. Scores, timers, turn order, and online synchronization remain intact.
8. Validate on a narrow phone layout and with large text.

## Implementation note
Once Flutter source is migrated into RivalRooms, implement a shared exit/navigation component or common helper where possible, but inspect each game's route and online lifecycle first. Do not blindly pop routes or introduce a global confirmation that breaks game-specific flows.
