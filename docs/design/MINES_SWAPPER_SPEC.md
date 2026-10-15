# MinesSwapper — Gameplay UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Make level progress and difficulty legible before play.

```text
┌─────────────────────────────┐
│ ‹ Back  MINESSWAPPER   ⋯    │
│ Level 04 / 50    Medium      │
│ Progress  ━━━━━━━────        │
│       [ puzzle grid ]       │
│ Moves 12      Time 01:08     │
│ [ Hint ]        [ Check ]    │
└─────────────────────────────┘
```

- Show level, difficulty, moves and timer in one compact strip.
- Use stable grid geometry and distinguish covered, flagged, revealed and selected cells.
- On success, show a brief result and explicit Next Level; don't auto-advance before feedback is read.
- Show Easy/Medium/Hard or Hint only if those features really exist.
- Preserve mine layout, swap rules, win/loss, unlocks, moves, scaling, timer and saved progress.
- **Acceptance:** difficulty known before start; next level actually loads; failure doesn't award completion; Back confirms if progress would be lost.
