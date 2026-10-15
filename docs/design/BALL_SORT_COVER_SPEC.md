# Ball Sort Cover — Gameplay UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Redundant encoding—color plus shape/state cues.

```text
┌─────────────────────────────┐
│ ‹ Back   BALL SORT     ⋯    │
│ Level 12 / 50   Hard         │
│    [ 🟠 ] [ 🔵 ] [ 🟢 ]      │
│    [ 🟢 ] [ 🟠 ] [ 🔵 ]      │
│    [    ] [    ] [    ]      │
│ Moves 18                     │
│ [ Undo ] [ Restart ]         │
└─────────────────────────────┘
```

- Use a responsive tube layout with clear tap separation; selected tube gets a strong outline.
- Pair color with pattern/number cues where practical for accessibility.
- Keep Undo/Restart only if already supported; invalid-move feedback stays local and concise.
- Preserve transfer rules, capacity, level data, win checks, move count, undo semantics and progression.
- **Acceptance:** tubes remain tappable on small screens; colors distinguishable; completion advances only to a valid next level; Back doesn't select a tube.
