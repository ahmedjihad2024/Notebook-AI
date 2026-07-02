# Full Documentation Strategy

This is the **full**, four-file documentation strategy. Use it for features that genuinely need deep documentation: complex flows, many edge cases, or critical paths a new developer must understand thoroughly.

For most simple features, use the lean strategy in [`../doc_simple/`](../doc_simple/README.md) instead.

---

## Templates in this folder

- **[overview.md](./overview.md)** — purpose, responsibilities, system behavior, data flow, architecture summary.
- **[flow.md](./flow.md)** — user flow, system flow, special logic, edge cases, navigation.
- **[api.md](./api.md)** — endpoints with request / response / errors per endpoint.
- **[screens.md](./screens.md)** — screens, components, state management, actions, states.

---

## When to pick this strategy

Use the full template when **any** of these are true:

- The feature has 3+ screens or a multi-step flow.
- Business logic is non-obvious (timers, retries, fallbacks, special states).
- More than 3 data operations are involved.
- A new developer would need 30+ minutes to understand the flow from code alone.

If none of those apply, use the simple template — a single short file is enough.

---

## Rules

- Documentation captures the **why**, not the what. Code already shows the what.
- Update the `Last updated` line every time you touch the doc.
- A stale doc is worse than no doc — if you can't keep it current, downgrade to the simple strategy.
