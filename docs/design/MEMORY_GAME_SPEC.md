# Memory — Gameplay UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Stable geometry reduces cognitive load.

```text
┌─────────────────────────────┐
│ ‹ Back     MEMORY      ⋯    │
│ Blue P1  4 pairs  00:48 Red P2│
│ [ ? ][ ? ][ ? ][ ? ]        │
│ [ ? ][ ? ][ ? ][ ? ]        │
│ [ ? ][ ? ][ ? ][ ? ]        │
│ [ ? ][ ? ][ ? ][ ? ]        │
│ Turn: Blue       Matches: 2 │
└─────────────────────────────┘
```

- Responsive grid with fixed card aspect ratio and predictable gaps; positions never jump mid-round.
- Selected/matched states use icon/outline/label, not color alone.
- Flip animation is brief and never delays authoritative turn handling.
- Show pair count, turn and score in a compact strip.
- Preserve card identity, pair matching, turn ownership, score, timer and server state. Support card-count options only if server state genuinely supports them.
- **Acceptance:** supported card counts fit without clipping; resolving cards cannot create extra turns; revealed/matched states have accessible labels; safe online exit.
