# Connect Four — Gameplay UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Make legal moves and turn ownership immediately legible.

```text
┌─────────────────────────────┐
│ ‹ Back   CONNECT FOUR   ⋯   │
│ Blue P1 — Your turn          │
│   ↓  ↓  ↓  ↓  ↓  ↓  ↓       │
│  [ ][ ][ ][ ][ ][ ][ ]       │
│  [ ][ ][ ][ ][ ][ ][ ]       │
│  [ ][ ][ ][ ][ ][ ][ ]       │
│  [ ][ ][ ][ ][ ][ ][ ]       │
│ Last move • result           │
└─────────────────────────────┘
```

- Board gets most of the width; preserve round cells and touchable columns.
- Show a subtle landing preview on touch-down/hover; use blue/red pieces plus distinct outlines/symbols.
- State whose turn it is and announce a win in a compact status line.
- Do not show Undo unless it already exists.
- Preserve board dimensions, legal moves, gravity, win detection, turn sequence, rematch and server sync.
- **Acceptance:** full columns show unavailable state; rapid taps cannot place multiple pieces; win highlight doesn't obscure board; narrow layout remains tappable.
