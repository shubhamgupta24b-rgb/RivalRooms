# Basketball Hoops — Gameplay UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Clear primary action with anticipatory feedback.

```text
┌─────────────────────────────┐
│ ‹ Back   BASKETBALL   ⋯     │
│ Blue P1  12     09:42  Red P2│
│ ─────── round progress ───── │
│       [COURT / HOOP]        │
│             🏀              │
│         [ SHOOT ]           │
│   Shot timing / result cue  │
└─────────────────────────────┘
```

- Keep Back in the safe-area top-left; score and timer share a stable status row.
- Blue Player 1 and red Player 2 also have text labels/icons.
- Give the court most of the screen; put Shoot in the lower thumb zone.
- Show brief press/result feedback near the ball, not a blocking modal.
- Disable repeat input only when the authoritative phase/cooldown disallows a shot.
- Preserve existing shoot payload, target, cooldown, phase, end time, scores and server updates. Never award score from local animation alone.
- **Acceptance:** fits 360 dp width; 48 dp minimum action target; no duplicate rapid shots; reconnect does not reset authoritative state; shared exit policy applies.
