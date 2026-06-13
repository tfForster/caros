# Car Infotainment App

Flutter desktop app (Windows/Linux) styled as a vehicle infotainment system. Author: Benno Klan. Early-stage prototype.

## Run the app

```
flutter run -d windows
```

## Project structure

```
lib/
  main.dart              # Entry point, window setup (1200x610px), BotToast init
  config/app.dart        # App-wide constants (title, etc.)
  controller/server.dart # HTTP client for backend (localhost:8000), token auth, XOR encryption
  pages/                 # One file per screen
  widgets/               # Reusable widgets
  ui/                    # Dialogs and notifications
```

## Pages

| File | Screen | Status |
|------|--------|--------|
| `pages/apps.dart` | Grid launcher (home) | Done |
| `pages/srtpage.dart` | Drive mode selector (Track/Sport/Custom/Default) + vehicle metrics | Done |
| `pages/media.dart` | Radio/audio (AM/FM/Streaming/Source) | Done |
| `pages/climate.dart` | HVAC controls | Done |
| `pages/controls.dart` | Seat controls (heated, vented, heated wheel) | Done |
| `pages/phone.dart` | Phone integration | Placeholder |
| `pages/nav.dart` | Navigation/GPS | Placeholder |
| `pages/settings.dart` | Settings | Placeholder |
| `pages/travel_link.dart` | Travel/trip planning | Placeholder |

## Key widgets

- `widgets/bottom_navigation.dart` — persistent nav bar across all pages (7 buttons)
- `widgets/drive_mode_buttons.dart` — mode selector with 4 options
- `widgets/main_content.dart` — vehicle metrics display for SRT page
- `ui/togglebutton.dart` — on/off toggle (grey/red)
- `ui/alert.dart`, `ui/dialog.dart`, `ui/notify.dart` — dialogs and toasts

## Design

- Background: black, accent: `Colors.red[900]`, text: white/grey
- Window size: 1200x610px fixed
- Material Design, dark theme

## State management

Simple `setState` — no Provider/Riverpod/BLoC. Each page manages its own state locally.

## Dependencies

| Package | Purpose |
|---------|---------|
| `window_manager` | Set window title/size on Windows/Linux |
| `http` | HTTP calls to backend |
| `bot_toast` | Non-blocking toast notifications |
| `cupertino_icons` | iOS-style icons |

## Backend

- Base URL: `localhost:8000`
- Bearer token auth — `server.connect()` fetches the token
- XOR encryption on credentials
- Scaffolded but not actively used in pages yet
