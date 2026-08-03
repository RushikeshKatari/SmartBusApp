# SmartBus authentication service

Flutter and Telegram call this service only; neither accesses Supabase/PostgreSQL directly. Configure `DATABASE_URL`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`, and a 256-bit `JWT_SECRET`, then run `./mvnw spring-boot:run`.

The schema enforces one active session per student and indexes unused QR tokens. QR payloads must contain only a random UUID token. Before issuing a new QR, call `invalidateUnused(studentId)` and save the new token atomically. Replace the JWT/session TODO in `QrAuthService` with the project JWT signer and session repository before deployment.
