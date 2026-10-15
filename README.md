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

See [docs/RIVALROOMS_UI_UX_TRACKER.md](docs/RIVALROOMS_UI_UX_TRACKER.md) for the verified inventory and [docs/RIVALROOMS_ONLINE_MULTIPLAYER.md](docs/RIVALROOMS_ONLINE_MULTIPLAYER.md) for rooms. Play online is Memory Match through Socket.IO. The other home-screen games stay on the device.

The previous `Two-player-online` repository is a read-only reference and must remain unchanged.
