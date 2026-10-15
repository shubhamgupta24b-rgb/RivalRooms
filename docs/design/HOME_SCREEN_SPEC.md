# Home / Game-Selection Screen — Design Spec v1

**Status:** specification only. The RivalRooms repository has no Flutter source yet, so this is not an implementation or test result.

## Goal
A single scrollable Home page that helps players choose how to play immediately. Avoid a multi-tab dashboard, marketing copy, and decorative clutter.

## Low-fidelity layout preview

```text
┌──────────────────────────────────────────┐
│ RivalRooms                     Records ⚙ │
│                                          │
│ ┌──────────────────┐ ┌─────────────────┐ │
│ │ 🌐 Online        │ │ Single Player   │ │
│ │ Quick match      │ │ Play on your own│ │
│ └──────────────────┘ └─────────────────┘ │
│ ┌──────────────────┐ ┌─────────────────┐ │
│ │ 👥 Multiplayer   │ │ Offline / Local │ │
│ │ Create or join   │ │ Same phone/Wi-Fi│ │
│ └──────────────────┘ └─────────────────┘ │
│                                          │
│ [Continue — only if a valid recent game] │
│                                          │
│ Games to play                            │
│ ┌─────────────────┐ ┌──────────────────┐ │
│ │ [Basketball     │ │ [Fruit Cut       │ │
│ │  gameplay crop] │ │  gameplay crop]  │ │
│ │ Basketball Hoops│ │ Fruit Cut        │ │
│ └─────────────────┘ └──────────────────┘ │
└──────────────────────────────────────────┘
```

This is a hierarchy/wireframe, not final pixel artwork. Actual game imagery replaces the bracketed crops; the mode cards should fit above the preview row on a typical phone.

## Layout

### Compact top bar
- Left: RivalRooms wordmark.
- Right: Records and Settings icons.
- No Privacy Policy link on Home; place it inside Settings.
- Never show a connected badge unless it reflects the actual socket state.

### Four play paths
On a typical 390 × 844 dp phone, show these in a 2 × 2 grid before the preview section. Each card has one clear icon, title, and at most one helper line.

| Card | Helper line | Intended route |
|---|---|---|
| **Online** | Quick match anywhere | Existing online flow and real Quick Play/room navigation. |
| **Single Player** | Play on your own | Existing game hub; list solo-capable games only when their rules support solo play. Never simulate an opponent. |
| **Multiplayer** | Create or join a room | Existing Create Room and Join Room paths with their current validation. |
| **Offline / Local** | Same phone or local Wi-Fi | Existing same-device games and actual same-Wi-Fi/hotspot host-or-join flow. Explain that local play does not need internet when applicable. |

These are entry points, not promises that every game supports every mode. Show a mode/game combination only when it is implemented.

### Optional Continue strip
- Show only when a valid recent game ID exists.
- Use the real saved game ID and route; hide the strip if there is no valid recent game.
- Keep it compact: gameplay thumbnail, title, Continue action. Never fabricate a match or score.

### Game previews
- Use actual gameplay crops/screens rather than generic decorative illustrations.
- First previews: **Basketball Hoops** and **Fruit Cut**.
- Show the title, a player-count/mode label only when confirmed, and a clear tap target.
- Keep previews quieter than the four main play paths. Avoid dense stats and reward-focused clutter.
- On short screens, the four play paths remain the first major content block.

## Visual direction
- Clean, polished game-product UI: neutral charcoal/ink canvas, warm light text/surfaces, restrained warm accent.
- Avoid generic blue/purple gradients, glassy neon panels, excessive glow, and heavy shadows.
- In game/lobby UI, **blue identifies Player 1** and **red identifies Player 2**. Pair color with labels/icons/position; never rely on color alone. Home mode cards do not imply player identity.
- Let game art keep its own palette: Basketball should read as a court; Fruit Cut should use recognizable fruit/gameplay art.
- Spacing rhythm: 8 / 16 / 24 dp. Card radius around 16–20 dp.

## Interaction and accessibility
- Interactive cards/buttons: minimum 48 × 48 dp hit target and about 8 dp separation where practical.
- Respect safe areas, narrow widths, and increased text size; no clipped labels.
- Visible pressed state (subtle tonal/scale change, roughly 120–180 ms). Respect reduced-motion preferences.
- Make the card tappable while keeping its label and helper line grouped.
- Loading, connection failure, empty recent-game and unavailable-mode states must be truthful and actionable. Never show success before the underlying operation succeeds.

## Navigation and preservation constraints
- After source migration, reuse existing authentication, socket, room, LAN and game-catalogue managers.
- Preserve room rejoin/resync, create/join/quick-play, local game launch, saved recent-game behavior, scores, timers and server synchronization.
- Simplify presentation without silently removing existing paths. If a requested mode has no working route, record the gap rather than creating a fake route.
- Privacy Policy is reachable from Settings only.

## Implementation acceptance checklist
- [ ] At 360 dp width, all four mode cards fit without horizontal overflow.
- [ ] At 390 × 844 dp, header and four mode cards appear before game previews.
- [ ] Four play paths route to real, distinct flows.
- [ ] Create Room, Join Room, Quick Play, same-device play and LAN host/join remain available wherever supported.
- [ ] A disconnected or sleeping backend is never presented as connected.
- [ ] Continue appears only for a valid saved game.
- [ ] Privacy Policy is absent from Home and available in Settings.
- [ ] Screen-reader labels, text scaling, hit targets and press states are checked.
- [ ] Record Flutter test/analyze/build results only after running them.

## Principle applied
**Progressive disclosure + clear mode hierarchy:** four concise play paths first, game discovery second, utility actions in the top bar, and legal/privacy content inside Settings.
