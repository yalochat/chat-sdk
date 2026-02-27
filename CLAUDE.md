# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the **Yalo Chat SDK** — a Flutter package providing a complete chat UI and messaging integration for iOS, Android, and Web. The SDK exposes a `Chat` widget and `YaloChatClient` that consumer apps embed directly.

All SDK code lives under `flutter-sdk/`. Commands below should be run from that directory.

## Commands

```bash
# Install dependencies
flutter pub get

# Lint / static analysis
flutter analyze

# Run all tests with coverage
flutter test --coverage

# Run a single test file
flutter test test/path/to/foo_test.dart

# Regenerate code (JSON serialization, Drift DB, l10n)
dart run build_runner build --delete-conflicting-outputs

# Remove generated files from coverage report
lcov --remove coverage/lcov.info "lib/**/*.g.dart" -o coverage/lcov.info
```

## Architecture

The SDK follows **Clean Architecture** with three layers:

```
lib/
├── yalo_sdk.dart          # Public API (exports YaloChatClient, Chat, ChatTheme)
├── data/services/client/  # Public HTTP client
├── domain/models/         # Public domain models
├── ui/                    # Public Chat widget and ChatTheme
└── src/                   # All internal implementation (private)
    ├── config/dependencies.dart   # DI root — wires all providers and blocs
    ├── data/              # Repositories + services (DB, camera, audio, API)
    ├── domain/            # Internal models + use cases
    └── ui/                # BLoCs, Cubits, and internal widgets
```

**Data flow**: `Chat` widget → BLoCs (`MessagesBloc`, `AudioBloc`, `ImageBloc`) → Repositories → Services/`YaloChatClient`.

### Key patterns

- **BLoC** (`flutter_bloc`) for all UI state. Each feature has a dedicated Bloc or Cubit under `src/ui/chat/view_models/`.
- **Repository pattern**: abstract interfaces with remote + fake implementations. Fakes are used in tests.
- **Dependency injection**: `dependencies.dart` is the single wiring point. It exposes `repositoryProviders()` and `chatProviders()` for use in the `Chat` widget tree.
- **Result type**: `src/common/result.dart` — custom `Result<T>` used for error propagation from repositories and the client.
- **Drift ORM** for local message storage; schema and generated code live under `src/data/services/database/`.
- **Code generation**: JSON serialization (`json_serializable`), Drift tables, and l10n (`YaloSdkLocalizations`) are all generated — run `build_runner` after modifying annotated files or `.arb` files.

### Platform bridges

- `android/` — Kotlin native bridge
- `ios/` — Swift native bridge
- `web/` — Drift web worker configuration

### Localization

ARB files are in `lib/l10n/` (English: `app_en.arb`, Spanish: `app_es.arb`). The generated class is `YaloSdkLocalizations`. After editing `.arb` files, run `flutter gen-l10n` or `build_runner`.

## CI/CD

The GitHub Actions workflow (`.github/workflows/ci_cd.yml`) runs on pushes to `main`, version tags (`v*.*.*`), and PRs. Pipeline: gitleaks secret scan → `flutter analyze` → `flutter test --coverage` → upload to Codecov.
