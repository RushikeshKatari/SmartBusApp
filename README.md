# SmartBus

College bus transportation management system built with Flutter.

## Overview

SmartBus provides four distinct portals for managing college bus operations:

- **Student Portal** — View assigned bus, live tracking, QR boarding pass, route info, notifications
- **Bus In-charge Portal** — QR attendance scanning, route recording, GPS broadcasting, emergency reporting
- **Admin Portal** — Fleet management, student/in-charge CRUD, attendance oversight, route approvals, analytics
- **App Manager Portal** — System metrics, service billing, API configuration, database management

## Tech Stack

- **Client:** Flutter / Dart, Provider state management
- **Android entry point:** Java
- **Backend:** Spring Boot 3 / Java 21, Spring Security, JWT, JPA, Flyway
- **Database:** PostgreSQL
- **Live location transport:** Spring WebSocket/STOMP endpoint (client connection is not yet integrated)

## Getting Started

Start the local PostgreSQL database and API from the repository root:

```bash
docker compose -f backend/docker-compose.yml up --build
```

The API listens on `http://localhost:8080`. In another terminal, run the Flutter web client against it:

```bash
flutter pub get
flutter run -d chrome --web-port 3000 \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=DEMO_MODE=false
```

For an Android emulator, use `http://10.0.2.2:8080` as `API_BASE_URL`. Debug builds allow HTTP for local development; production builds should use HTTPS. `DEMO_MODE=true` enables local demo credentials only when the API cannot be reached. A server-side credential rejection is never bypassed by demo login.

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

### Hyderabad Emergency Recovery Prototype
- Seeds 20 representative corridors between Hyderabad neighborhoods and KLH Aziz Nagar Campus, with 6 stops per corridor and sample bus occupancy/capacity.
- Runs breakdown pickup assignments in the Java backend, using active bus status, spare capacity, pickup-group demand and route proximity.
- Reports covered/unassigned students and rescue bus/driver details. Java requests road distance and duration from configurable `OSRM_BASE_URL`; if it is unavailable, estimates are labeled as straight-line.
- Displays OpenStreetMap tiles with route and stop overlays and visible attribution. No Google Maps API key is needed.

**Prototype limits:** route stops are representative locality coordinates, not surveyed boarding points or road-verified traces. Passenger demand is distributed evenly over remaining pickup groups. This is a scenario simulator and should not be used for live dispatch until stop locations, bus GPS, passenger counts and the operational flows are validated. See [`research/proposed_contribution.md`](research/proposed_contribution.md) for the research question and evaluation plan.

### Backend integration status

Login and account creation/reset/password change, HOD emergency-report actions, in-charge emergency-report submission, and Java breakdown assignment use the Spring Boot API. Newly created student accounts use their roll number as username; in-charge and Faculty/HOD accounts use email. The admin account screens reveal a generated temporary password once, and users can change it from their profile. Other portal data and mutations remain partly sample-backed; live GPS/WebSocket tracking, admin fleet CRUD, QR login/attendance, and a complete production data lifecycle still need backend integration and operational validation.

### Hyderabad Demo Corridors

1. Aziz Nagar–Chilkur
2. Moinabad–Himayat Sagar
3. Shankarpally–Gandipet
4. Kokapet–Narsingi
5. Gachibowli–Nanakramguda
6. Kondapur–Gachibowli
7. Miyapur–Hafeezpet
8. Lingampally–Tellapur
9. Manikonda–Puppalaguda
10. Mehdipatnam–Narsingi
11. Jubilee Hills–Manikonda
12. Banjara Hills–Tolichowki
13. Ameerpet–Shaikpet
14. Secunderabad–Mehdipatnam
15. Uppal–Ameerpet–Campus
16. LB Nagar–Mehdipatnam
17. Kukatpally–Gachibowli
18. Shamshabad–Rajendranagar
19. Tellapur–Gandipet
20. Patancheru–Lingampally

For a local end-to-end simulation, start the PostgreSQL/API stack with Docker Compose first so Flyway applies migration `V12`, then start Flutter with `API_BASE_URL=http://localhost:8080` (or `http://10.0.2.2:8080` on an Android emulator). The map uses [OpenStreetMap](https://www.openstreetmap.org/copyright) tiles, while Java routing calls the configurable OSRM-compatible service. Public tile and router services have usage limits; set `OSRM_BASE_URL` to a hosted or self-managed endpoint for sustained use.

### App Manager
- System health monitoring with timeframe selection
- Third-party service billing breakdown
- API key and database configuration management

## License

MIT
