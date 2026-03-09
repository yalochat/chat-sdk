# :app — Yalo Chat SDK Demo App

This module is the **integration test harness** for the `:sdk` library module.

> **Not production code.** This app exists solely to verify that the SDK imports correctly, compiles, and runs on a real device or emulator.

## Purpose

- Catch SDK integration issues early (import errors, manifest merges, Hilt setup)
- Provide a running target to validate each milestone as it is completed
- Manual smoke-test surface: install, launch, observe, confirm no crashes

## What it is NOT

- A production app
- A reference implementation for SDK consumers
- A showcase of real chat functionality (until Phase 2 milestones are complete)

## Running

```bash
./gradlew :app:assembleDebug
# or install directly on a connected device/emulator:
./gradlew :app:installDebug
```
