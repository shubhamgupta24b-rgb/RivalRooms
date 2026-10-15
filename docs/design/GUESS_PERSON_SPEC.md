# Guess the Person — Gameplay UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Progressive hints without visual clutter.

```text
┌─────────────────────────────┐
│ ‹ Back  GUESS PERSON   ⋯    │
│ Blue P1  02     00:40  Red P2│
│       [person portrait]     │
│ Hint 1: Known for…           │
│ [ Reveal next hint ]         │
│ [ Enter guess…          ]   │
│        [ SUBMIT ]            │
└─────────────────────────────┘
```

- One portrait/clue panel, compact hint history and a clear answer field.
- Keep hint history readable without forcing the play area to scroll.
- “Reveal next hint” is secondary to submitting; show any hint cost only if current rules already have one.
- Preserve person/deck data, hint order, guesses, turn rules, score, timer and server validation; don't invent penalties.
- **Acceptance:** keyboard doesn't cover Submit; long clues wrap; incorrect guesses advance only under existing rules; Back is safe during live play.
