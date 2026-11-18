# payment-api

Weeks 1–2. Spring Boot 4.1, Java 25, Postgres (`payments` database).

**Next step:** generate the skeleton here (see "Create the skeleton" below), then delete this line.

## API (draft — change it as you build)

| Method and path | Purpose | Success | Errors |
| --- | --- | --- | --- |
| `POST /payments` | Create a payment `{merchantId, subtotalMinor, taxMinor, currency}` | 201 + `Location` | 400 validation, 422 key reused with a different body |
| `GET /payments/{id}` | Look up a payment and its refunds | 200 | 404 |
| `GET /payments?merchantId=…&page=…` | List a merchant's payments (paged) | 200 | 400 |
| `POST /payments/{id}/refunds` | Refund all or part `{amountMinor}` | 201 | 404, 409 more than the refundable remainder, 422 key reuse |

All `POST`s require an `Idempotency-Key` header. Errors are `ProblemDetail` (RFC 9457).

Payment status: `CAPTURED → PARTIALLY_REFUNDED → REFUNDED`.

## Rules to test first

- The same `Idempotency-Key` with the same body returns the original response and doesn't create a second row, even when two requests arrive at once.
- The refunds on a payment can never add up to more than its total, even with concurrent refund requests (use optimistic locking with `@Version`, or a row lock).
- Partial refunds prorate tax with the cumulative rounding method in [ADR 0002](../docs/adr/0002-money-and-prorated-refunds.md). After a full refund, the tax refunded equals the tax charged exactly.

## Create the skeleton

Spring Initializr, from this folder:

```bash
curl -s https://start.spring.io/starter.tgz \
  -d type=maven-project -d language=java -d javaVersion=25 -d bootVersion=4.1.0 \
  -d groupId=dev.jinchoi -d artifactId=payment-api -d packageName=dev.jinchoi.payments \
  -d dependencies=web,validation,data-jpa,postgresql,flyway,actuator,testcontainers \
  | tar -xzf -
```

If Initializr rejects `bootVersion`, open https://start.spring.io in a browser and choose the newest 4.1.x release it offers.
