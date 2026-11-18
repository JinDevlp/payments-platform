# ADR 0001: Separate services, a database per service, events over Kafka

- Status: Proposed
- Date: 2026-11-18

## Context
The project should show a realistic microservice setup: independent deploys, data owned by one service, and asynchronous integration. It is also small, run by one person, and on a budget.

## Options
1. **One service (modular monolith).** Simplest to run and the right call for many teams, but it doesn't exercise Kafka, the outbox, or independent deploys.
2. **Separate services with a shared database.** Easy joins, but the services get coupled through the schema, which defeats the point.
3. **Separate services, each with its own database, integrated through events.** More moving parts, and the ledger is only eventually consistent with payments.

## Decision
Option 3. `payment-api` owns `payments`, and `ledger-service` owns `ledger`. Payment events travel through a transactional outbox to Kafka. For local development both databases live on one Postgres container.

## Consequences
- Events need a stable schema, with versioning when it changes.
- Consumers must be idempotent, because Kafka delivers at least once.
- The ledger and settlement can lag behind payments, so a reconciliation check is worth adding later.
- For a small team, a single service is often the better choice. This project takes the other side of the trade-off on purpose, to exercise service boundaries and asynchronous integration.
