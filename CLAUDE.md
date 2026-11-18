# payments-platform

A small payments platform built as separate services: **payment-api** (payments, refunds, idempotency), **ledger-service** (double-entry ledger and daily settlement from Kafka events), a small React **web** page, and a stretch **notifier** in Kotlin.

## Working in this repo
- Propose design decisions and record them as ADRs in `docs/adr/`. The maintainer makes the final call.
- Never commit or push; the maintainer does.
- Don't add dependencies or infrastructure without asking.

## Commands
Each service is its own Maven project with its own wrapper. Run commands from the service folder.
- Infrastructure: `docker compose up -d` (Postgres now; Kafka from week 3), and `docker compose down -v` to reset the data
- Build and all tests: `cd payment-api && ./mvnw verify`
- One test: `./mvnw test -Dtest=RefundServiceTest#partialRefundProratesTax`
- Run: `./mvnw spring-boot:run` (needs `docker compose up -d` first)
- Integration tests use Testcontainers and need Docker running.

## Stack
- Java 25, Spring Boot 4.1, Maven, PostgreSQL 17, Flyway, Spring Data JPA
- Kafka (week 3), React + Vite + TypeScript (week 4), kind (weeks 5–6), Terraform + AWS ECS Fargate + RDS (weeks 7–8), Prometheus + Grafana, k6
- Each service owns its own database (`payments`, `ledger`). Services never read each other's tables; they share data only through events and APIs.

## Conventions
- Package by feature: `dev.jinchoi.payments.<feature>` (e.g. `payment`, `refund`, `idempotency`).
- Constructor injection; no Lombok. DTOs are records; controllers never return entities.
- **Money is stored as `long` minor units (cents) plus an ISO currency code.** Never use `double`. Rounding rules live in one place; see `docs/adr/0002-money-and-prorated-refunds.md`.
- Time is stored as `Instant` (UTC). Settlement days are computed in the merchant's `ZoneId`. Inject `Clock` instead of calling `now()`, so daylight-saving behavior can be tested.
- Errors: one `@RestControllerAdvice` per service returning `ProblemDetail`.
- Every write endpoint requires an `Idempotency-Key` header. Same key and same body returns the original response; same key with a different body returns 422.
- Schema changes go through Flyway only, with `ddl-auto=validate`. Never edit an applied migration.
- Tests use `@MockitoBean` (not `@MockBean`), slice tests where possible, and Testcontainers Postgres/Kafka. Never use H2.

## Gotchas
- Publish events through the **transactional outbox** (written in the same DB transaction as the payment). Never call Kafka directly inside a request transaction.
- Consumers must be idempotent: Kafka delivers at least once, so the ledger has to skip duplicate event IDs.
- AWS sessions always end with `terraform destroy`. RDS and load balancers bill by the hour.

## Done means
- `./mvnw verify` passes for each changed service, and the output has been shown.
- Risky paths are tested (retries/duplicates, partial refunds and rounding, DST), not just the happy path.
- README, ADRs and docs are updated when a design decision changes.
