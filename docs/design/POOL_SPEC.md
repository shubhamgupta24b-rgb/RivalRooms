# Pool — Gameplay UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Separate precision aiming from commitment to shoot.

```text
┌─────────────────────────────┐
│ ‹ Back       POOL       ⋯   │
│ Blue P1  3 balls    Red P2  │
│       ┌─────────────┐       │
│       │  POOL TABLE │       │
│       │ cue / balls │       │
│       └─────────────┘       │
│ Aim sensitivity ─────●      │
│ [ Reposition ]    [ SHOOT ] │
└─────────────────────────────┘
```

- Center the table with minimal chrome; keep aim gesture separate from Shoot.
- Show cue direction before commitment. Aim guides only if already supported.
- Keep player labels and turn visible; never overlay Back on the table's active hit area.
- Preserve physics, collisions, turn validation, shot strength, fouls, ball state, scoring and network authority; no physics changes in a UI pass.
- **Acceptance:** one-thumb aiming works; drags cannot activate Back; turn changes only on valid state; reconnect restores table state.
