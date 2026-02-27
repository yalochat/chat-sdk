# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Get dependencies
flutter pub get

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/file_test.dart

# Run tests with coverage
./tool/coverage_report.sh

# Run the example app
cd example && flutter run

# Generate code (json_serializable, drift, l10n)
dart run build_runner build --delete-conflicting-outputs

# Watch and regenerate code on change
dart run build_runner watch --delete-conflicting-outputs

# Lint
flutter analyze
```

The `YALO_SDK_CHAT_URL` environment variable must be passed at build time via `--dart-define=YALO_SDK_CHAT_URL=<url>`.

## Architecture

This is a Flutter SDK package (`chat_flutter_sdk`) that provides a complete chat UI for Yalo's messaging platform. The public API surface is minimal — only three exports in `lib/yalo_sdk.dart`: `YaloChatClient`, `Chat`, and `ChatTheme`.

### Layer structure

```
lib/
  yalo_sdk.dart            # Public API exports
  data/services/client/    # YaloChatClient (HTTP client, public)
  ui/theme/                # ChatTheme, colors, constants (public)
  ui/chat/widgets/chat.dart # Chat widget (public)
  src/                     # All internal implementation
    config/dependencies.dart  # DI wiring (repositoryProviders + chatProviders)
    common/                   # Result<T>, Page<T>, formatting utilities
    data/
      services/
        database/           # Drift DB (chat_message.drift schema + DatabaseService)
        audio/              # AudioService (record package)
        camera/             # CameraService (image_picker package)
        yalo_message/       # YaloMessageService (stub, TBD)
      repositories/
        chat_message/       # Local persistence via Drift
        yalo_message/       # Remote: polling Yalo API; Fake: in-memory stub
        image/              # Local file storage
        audio/              # Local file storage
    domain/models/          # ChatMessage, YaloMessage, Product, ChatEvent
    ui/
      chat/view_models/     # BLoC layer: MessagesBloc, AudioBloc, ImageBloc
      chat/widgets/         # ChatAppBar, ChatInput, MessageList (internal)
      theme/view_models/    # ChatThemeCubit
```

### Data flow

1. `Chat` widget (public) is initialized with a `YaloChatClient` and `ChatTheme`.
2. `dependencies.dart` wires all providers: `DatabaseService` (Drift singleton) → repositories → BLoCs.
3. `MessagesBloc` is the central BLoC. It subscribes to two streams from `YaloMessageRepository`:
   - `messages()` — incoming assistant messages (currently via HTTP polling every 1s)
   - `events()` — typing indicators (`TypingStart`/`TypingStop`)
4. Outgoing messages go through `MessagesBloc` → `ChatMessageRepository` (local DB) + `YaloMessageRepository.sendMessage()` (HTTP POST to `/inbound_messages`).
5. Message history is paginated from Drift via cursor-based pagination (descending by `id`).

### Key patterns

- **`Result<T>`** (`lib/src/common/result.dart`): Sealed class (`Ok<T>` / `Error<T>`) used as return type for all repository and service methods. Use pattern matching (`switch (result) { case Ok(): ... case Error(): ... }`).
- **Code generation**: Drift uses `.drift` files + `build_runner`. JSON models use `json_serializable` (`.g.dart` files). L10n uses `flutter gen-l10n` (generated into `lib/l10n/`). Never edit `.g.dart` files manually.
- **`DatabaseService`** is a singleton — `close()` resets the instance so it can be recreated.
- **`YaloMessageRepositoryRemote`** polls every 1 second with a 5-second lookback window. It deduplicates messages using an in-memory LRU cache keyed on `wiId`.
- **`YaloMessageRepositoryFake`** exists for tests and development without a real backend.
- **`ChatTheme`** can be constructed from a Material `ThemeData` via `ChatTheme.fromThemeData(themeData, optionalBaseTheme)`.

### Testing

Tests mirror the `lib/src/` structure under `test/`. BLoC tests use `bloc_test`. Repository tests use `mocktail` for mocking services. The `dart_test.yaml` tags integration tests with a 30s timeout.
