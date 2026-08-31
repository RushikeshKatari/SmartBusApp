# SmartBus

College bus transportation management system built with Flutter.

## Overview

SmartBus provides four distinct portals for managing college bus operations:

- **Student Portal** — View assigned bus, live tracking, QR boarding pass, route info, notifications
- **Bus In-charge Portal** — QR attendance scanning, route recording, GPS broadcasting, emergency reporting
- **Admin Portal** — Fleet management, student/in-charge CRUD, attendance oversight, route approvals, analytics
- **App Manager Portal** — System metrics, service billing, API configuration, database management

## Tech Stack

- **Framework:** Flutter 3.44+ (Web, iOS, Android)
- **State Management:** Provider (ChangeNotifier)
- **UI:** Material Design 3

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome --web-port 3000

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android
```

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── models/                    # Data models
├── providers/                 # State management (SmartBusProvider)
├── screens/
│   ├── admin/                 # Admin portal screens
│   ├── incharge/              # Bus in-charge portal screens
│   ├── manager/               # App manager portal screens
│   └── *.dart                 # Student portal screens
├── services/                  # API services
├── theme/                     # App theme and colors
└── widgets/                   # Reusable UI components
```

## Features

### Student
- Bus pass with QR code
- Live bus tracking (map placeholder)
- Smart arrival alarm
- Route and stop information
- Push notifications

### Bus In-charge
- QR-based student attendance scanning
- Manual attendance entry
- Live GPS location broadcasting
- Route recording with stop markers
- Emergency breakdown reporting

### Admin
- Dashboard with analytics charts
- Student, in-charge, bus, and staff management
- Route approval workflow
- Real-time attendance monitoring
- Emergency alert dashboard
- Report generation
- Dark/Light theme switching

### App Manager
- System health monitoring with timeframe selection
- Third-party service billing breakdown
- API key and database configuration management

## License

MIT
