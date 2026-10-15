# Multiplayer Room Lobby — UI Spec

**Status:** design specification only; implementation and tests not started.

**Principle:** Visibility of system status and clear action hierarchy.

```text
┌─────────────────────────────┐
│ ‹ Back      GAME ROOM   ⋯   │
│ Room: A7K2     [Copy code]   │
│ Blue Player 1   ● Connected  │
│ Red Player 2    ○ Waiting    │
│ Mode: Online                │
│ [ Invite / Copy code ]      │
│ [ Ready ]                   │
│ Start when requirements met │
└─────────────────────────────┘
```

- Show real player slots, roles, connection and readiness states.
- Make Copy code and Ready prominent; Start only when server requirements are met.
- On socket loss, show a clear retry/error state; never leave a stale Connected indicator.
- Host departure follows the actual host-transfer/room-close behavior.
- Preserve room codes, matchmaking, identity, ready rules, host permissions, lifecycle and server validation.
- **Acceptance:** no fake connection state; reconnect refreshes authoritative room state; Start cannot bypass server checks; exit confirmation only when relevant.
