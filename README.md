# CarOS — Vehicle Infotainment System

A Flutter-based car infotainment UI built as a portfolio project. Runs natively on Windows and as a web app.

**Live Demo:** [caros.benno-klan.com](https://caros.benno-klan.com)

---

## Features

- **Navigation** — Interactive map (OpenStreetMap + CartoDB Dark Matter), real road routing via OSRM API, tap-to-navigate with road snapping, pulsing location marker
- **Media** — Radio (AM/FM), USB playback with file picker, Bluetooth audio view
- **Phone** — Call simulation with dial pad, incoming call demo, call timer
- **Drive Mode** — Track / Sport / Custom / Default selector with vehicle metrics
- **Climate** — HVAC controls
- **Seat Controls** — Heated/vented seats, heated steering wheel

## Tech Stack

- Flutter (Windows + Web)
- flutter_map + latlong2
- OpenStreetMap / CartoDB tiles
- OSRM routing API
- Docker + nginx (deployment)

## Run locally

```bash
flutter pub get
flutter run -d windows
```

## Deploy (Docker)

```bash
docker compose up --build -d
```

Builds Flutter web release and serves via nginx on port 80.

## Project Structure

```
lib/
  main.dart              # Entry point, window setup
  config/app.dart        # App-wide constants & design tokens
  controller/server.dart # HTTP client (localhost:8000)
  pages/                 # One file per screen
  widgets/               # Reusable widgets
  ui/                    # Dialogs and notifications
```

## Notes

Some features are demo simulations — real deployment in a vehicle would use:
- **Phone:** Bluetooth HFP via BlueZ (Linux)
- **Audio:** Bluetooth A2DP + AVRCP via BlueZ (Linux)
- **GPS:** System location API

---

Author: Benno Klan
