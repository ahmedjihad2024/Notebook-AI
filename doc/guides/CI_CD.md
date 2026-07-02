# CI / CD Guide

This document describes the GitHub Actions workflow in `.github/workflows/`, what it does, when it runs, and how to prepare for it.

Workflows live in `.github/workflows/` and are executed by GitHub-hosted runners. They are triggered by `git push` events on specific branches.

---

## Overview

| File | Trigger | Runner | Purpose |
|---|---|---|---|
| `ci.yml` | push on `master` | `ubuntu-latest` | Code-gen + format check + tests + coverage |

---

## `ci.yml` — tests on push to `master`

### What it does

Runs on every push to `master`. The single `ci` job performs, in order:

1. Checkout the repo with full history (`fetch-depth: 0`).
2. Install Java 17 (Temurin).
3. Install Flutter `3.41.6` with the action cache enabled.
4. `flutter pub get`.
5. `dart run build_runner build --delete-conflicting-outputs` — regenerates Isar and other generated files.
6. `dart format --output=none --set-exit-if-changed .` — fails if any file is unformatted (currently `continue-on-error: true` so it only warns).

### What you need to run it

- `GITHUB_TOKEN` — provided automatically by GitHub Actions. No setup.
- `permissions: contents: write` is already declared at the workflow level.
- Make sure **Settings -> Actions -> General -> Workflow permissions** is set to **Read and write permissions**.

### Adding new tests

Place files under `test/` following the structure documented in [`doc/testing/testing_strategy.md`](../testing/testing_strategy.md):

```
test/
├── unit/
│   ├── data/
│   │   └── providers/
│   └── ...
├── integration/
└── helpers/
```

Anything matching `test/**/*_test.dart` is picked up automatically by `flutter test`. No workflow change is needed when you add a new test file.
