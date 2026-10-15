# Battleship — Gameplay UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Separate setup, targeting and result states.

```text
┌─────────────────────────────┐
│ ‹ Back     BATTLESHIP   ⋯   │
│ Blue P1     Targeting    Red P2│
│       [ opponent grid ]     │
│       A B C D E F           │
│     1 · · × · · ·           │
│     2 · · · · ? ·           │
│ Selected: coordinate C2     │
│          [ FIRE ]           │
└─────────────────────────────┘
```

- Visually distinguish own fleet setup and target grid; never expose hidden opponent ships/weapons.
- Show selected coordinate before committing; hit/miss uses icon and text as well as color.
- If a chance-based weapon reveal option exists already, reflect its real state without changing its rules.
- Preserve placement validation, hidden information, weapon options, hit/miss, turns, score, timer and server authority.
- **Acceptance:** target coordinates unambiguous; no double-fire during processing; hidden state stays hidden; exit follows current room lifecycle.
