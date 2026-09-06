# SmartBus backend

Spring Boot 3 / PostgreSQL API for the SmartBus app. Flyway owns the schema; clients never connect to PostgreSQL directly.

## Run

The simplest local startup is:

```bash
docker compose up --build
```

For a local Java process, set `DATABASE_URL`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`, and a `JWT_SECRET` of at least 32 bytes, then run `mvn spring-boot:run`. The application creates the configured bootstrap manager only when that username does not already exist. Override the development defaults with `BOOTSTRAP_MANAGER_USERNAME` and `BOOTSTRAP_MANAGER_PASSWORD` before deployment.

## API surface

- `POST /api/manager/login` — database-backed application-manager login.
- `GET|POST /api/manager/configs`, `GET /api/manager/metrics`, `GET /api/manager/billing/services`.
- `GET|POST|PUT|DELETE /api/admin/fleet/routes` and `/buses`; stops are at `/routes/{id}/stops`.
- `POST /api/incharge/attendance`, `GET /api/admin/attendance`.
- `POST /api/incharge/emergency` or `/api/manager/emergency`; list/resolve via `/api/admin/emergencies`.
- Emergency attendance escalation: `POST /api/incharge/emergency-reports` sends a scanned student list to Transport; `GET /api/admin/emergency-reports` lists it and `POST /api/admin/emergency-reports/{id}/send-to-hod` forwards it; HODs read forwarded reports at `GET /api/hod/emergency-reports` after `POST /api/hod/login`.
- HOD academic attendance: `GET|POST /api/hod/academic/sections` lists or creates specialization/section rosters for years 1–4. `PATCH /api/hod/academic/students/{id}/attendance?percentage=…` updates an individual student percentage.
- `POST /api/admin/students/{id}/login-qr?telegramChatId=…` issues a ten-minute, single-use token; `POST /api/auth/login/qr` consumes it.
- STOMP endpoint `/ws/tracking`, application destination `/app/updateLocation`, topic `/topic/busLocations`.

All protected HTTP endpoints require `Authorization: Bearer <token>`. Roles are enforced as `APP_MANAGER`, `ADMIN`, `INCHARGE`, and `STUDENT`. Configure browser origins with `CORS_ORIGINS` (a comma-separated list).
