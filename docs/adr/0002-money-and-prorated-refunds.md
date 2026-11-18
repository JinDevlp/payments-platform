# ADR 0002: Money in minor units; tax on partial refunds rounded on the running total

- Status: Proposed
- Date: 2026-11-18

## Context
Payments carry a subtotal and a tax. A partial refund has to give back a proportional share of the tax. If each refund's tax is rounded on its own, the rounding errors add up: after several partial refunds that add up to the full amount, the tax refunded can be off by a few cents from the tax charged.

## Options
1. **`BigDecimal` amounts.** Exact, but scale has to be handled everywhere, and JSON or the database can drop the scale.
2. **`long` minor units (cents) plus a currency code.** Simple, fast, and exact for addition. Division needs one explicit rounding rule.
3. **Round each refund's tax on its own.** Easy, but the errors drift.
4. **Round on the running total.** Compute the tax refunded *so far* from the amount refunded so far, and make this refund's tax the difference.

## Decision
Use option 2 for storage and option 4 for refunds.

```
taxRefundedAfter = roundHalfEven(totalRefundedAfter * tax / total)
thisRefundTax    = taxRefundedAfter - taxRefundedBefore
```

Do the math in `BigDecimal` and store the results as `long`.

## Consequences
- Once refunds reach the full total, the tax refunded equals the tax charged exactly, whatever the number of refunds.
- Each refund's tax can differ by a cent from naive rounding. That's expected; document it in the API.
- Tests to write: three equal refunds of a total that doesn't divide evenly, one cent at a time, and concurrent refunds.
- Tips (if added) follow the same rule as their own component.
