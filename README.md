# RivalRooms

RivalRooms is a mobile-first collection of local and online mini-games.

## Repository layout

- `mobile/` — Flutter app. Start with the Home screen and local Memory Match prototype.
- `server/` — Node.js + Express + Socket.IO multiplayer backend migration.
- `docs/design/` — screen/game design specifications.
- `docs/RIVALROOMS_UI_UX_TRACKER.md` — implementation and validation tracker.

## Run the Flutter starter

Install Flutter, then:

```sh
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

## Run the server

Install Node.js 20+:

```sh
cd server
npm ci
npm test
npm start
```

The server listens on port 3000 by default. Configure environment variables using `.env.example` and your hosting provider. Never commit production secrets.

## Current implementation status

The Flutter UI is an initial scaffold: Home / Play online / All games navigation, Settings, and a playable local Memory Match prototype are present. Other game tiles are previews. The server source has been partially migrated, but the Flutter client is not yet connected to it. Online room actions are placeholders until socket integration is completed.

**Not release-ready:** Flutter analysis/tests, server tests, Android build, two-device multiplayer validation, and deployment have not yet been verified. The previous `Two-player-online` repository is a read-only reference and must remain unchanged.
