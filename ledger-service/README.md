# ledger-service

Weeks 3–4. It consumes payment events from Kafka and writes double-entry ledger rows to the `ledger` database. It also builds a daily settlement total per merchant, using each merchant's time zone.

## Rules to test first

- If the same event is delivered twice, it's recorded once. Store processed event IDs with a unique constraint, in the same transaction as the ledger rows.
- Every event's debits equal its credits.
- A message that can't be processed goes to the dead-letter topic after a fixed number of retries. It never blocks the partition forever.
- On a daylight-saving change day, the settlement covers 23 or 25 local hours and runs exactly once. Test it with an injected `Clock` and `America/Chicago`.

Start with the free Spring and Kafka course on Confluent Developer.
