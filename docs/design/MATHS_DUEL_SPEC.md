# Maths Duel — Gameplay UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Progressive disclosure for timed questions.

```text
┌─────────────────────────────┐
│ ‹ Back    MATHS DUEL    ⋯   │
│ Blue 3       00:18       Red 2│
│ Question 07 / 15             │
│          18 × 4 = ?          │
│ [ 68 ] [ 72 ]                │
│ [ 74 ] [ 78 ]                │
│ Feedback: Correct / Try next│
└─────────────────────────────┘
```

- One large high-contrast question; answer choices in a 2×2 grid.
- Timer remains visible but secondary; use concise feedback, no full-screen flash.
- Block duplicate submission while an answer is being accepted.
- Preserve question generation, answer validation, scoring, round progression, timer authority and online results. Never decide the winner locally.
- **Acceptance:** choices at least 48 dp high; large text supported; reconnect preserves timer/answer state; shared exit rules.
