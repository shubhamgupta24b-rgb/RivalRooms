# Fruit Cut — Gameplay UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Direct manipulation with localized feedback.

```text
┌─────────────────────────────┐
│ ‹ Back    FRUIT CUT    ⋯    │
│ Blue P1  08     00:31  Red P2│
│                             │
│       🍉        🍊          │
│            🍓               │
│       fruit play field      │
│  combo / last-result cue    │
└─────────────────────────────┘
```

- Persistent compact score/phase/timer header; play field gets most of the height.
- Use recognizable fruit art and restrained natural colors; no neon reward effects.
- Keep swipe trails brief; distinguish valid slash from miss near the gesture.
- Preserve fruit ID/lane slash payload, spawn logic, score, phase, end time and server authority.
- Stale fruit IDs remain invalid; local animation never grants points by itself.
- **Acceptance:** gestures stay responsive on narrow screens; swipe layer cannot intercept Back; reconnect restores authoritative state.
