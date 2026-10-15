# RivalRooms Flutter app

This directory contains the initial Flutter UI implementation.

## Run

```sh
cd mobile
flutter pub get
flutter run
```

## Current scope

- Home screen with Online, Same room, and All games entry points.
- Settings entry; Privacy Policy is kept inside Settings.
- A playable local Memory Match prototype with pair matching, move count, restart, and completion dialog.
- Consistent Back navigation from game screens.
- The other listed games currently have preview placeholders.

## Not connected yet

Online room creation/joining, authoritative server game state, socket synchronization, and the remaining game implementations have not yet been migrated. Do not treat this scaffold as a deployable multiplayer release.
