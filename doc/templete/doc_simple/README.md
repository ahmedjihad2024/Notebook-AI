# Simple Documentation Strategy

This is the **simple**, single-file documentation strategy. Use it as the **default choice** for most features.

For features that genuinely warrant deeper docs (complex flows, many edge cases), see the full strategy in [`../doc_strategy/`](../doc_strategy/README.md).

---

## Templates in this folder

- **[template.md](./template.md)** — single-file feature doc: purpose, key classes, brief flow, gotchas, related links.

---

## When to pick this strategy

Pick this by **default**. Switch to the full strategy only if any of these are true:

- The feature has 3+ screens or a multi-step flow.
- Business logic is non-obvious (timers, retries, fallbacks).
- More than 3 data operations are involved.
- A new developer would need 30+ minutes to understand the flow from code alone.

---

## Rules

- Documentation captures the **why**, not the what. Code already shows the what.
- If the **Gotchas** section would be empty, the feature probably doesn't need a doc at all.
- API schemas live in Postman, designs live in Figma — don't duplicate them here.
- Update the `Last updated` line every time you touch the doc.
