# Documentation

Welcome. This folder is the source of truth for how this project is built and how to contribute.

---

## Where to start

1. **[ARCHITECTURE.md](../architecture/ARCHITECTURE.md)** — the layers (View / State / Data), how they talk to each other, and the core patterns.
2. **[CONTRIBUTING.md](./CONTRIBUTING.md)** — commit conventions, branch naming, code standards.
3. **[CI_CD.md](./CI_CD.md)** — GitHub Actions workflow, what it does, and how to set it up.
4. **[testing/testing_strategy.md](../testing/testing_strategy.md)** — unit and integration test guidelines.

---

## Documenting a feature

Two strategies are available. Pick whichever matches the feature's complexity.

| Strategy | Folder | When to use |
|---|---|---|
| **Simple** (default) | [`doc_simple/`](../templete/doc_simple/README.md) | Most features. One short `README.md` per feature. |
| **Full** | [`doc_strategy/`](../templete/doc_strategy/README.md) | Complex features only (multi-step flows, many edge cases). Four files per feature. |

When in doubt, start simple. Upgrade later if the feature grows.

---

## Layout

```
doc/
├── architecture/ARCHITECTURE.md   # high-level architecture
├── guides/
│   ├── README.md                  # you are here
│   ├── CONTRIBUTING.md            # workflow + code standards
│   └── CI_CD.md                   # CI/CD pipeline docs
├── testing/testing_strategy.md    # testing guidelines
├── templete/                      # documentation templates
│   ├── doc_simple/                # single-file template
│   └── doc_strategy/              # four-file template
└── features/                      # one folder per documented feature
```
