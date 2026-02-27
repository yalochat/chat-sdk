# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the **Yalo Chat SDK — TypeScript edition**: a Web Components library that ports the Flutter chat SDK to the browser. It exposes a single `<yalo-chat>` custom element and produces a standalone ESM bundle at `dist/yalo-chat.js`.

## Commands

All commands run from `typescript-sdk/`. Yarn 4 is bundled — never rely on a globally installed Yarn.

```bash
# Install dependencies
node .yarn/releases/yarn-4.9.2.cjs install

# Build both packages + produce dist/yalo-chat.js
node .yarn/releases/yarn-4.9.2.cjs workspaces foreach -A --topological-dev run build && node scripts/bundle.js

# Bundle only (after packages are already built)
node scripts/bundle.js

# Run all tests
node .yarn/releases/yarn-4.9.2.cjs workspaces foreach -A run test

# Run tests for a single package
node .yarn/releases/yarn-4.9.2.cjs workspace @yalo/chat-sdk-core run test
node .yarn/releases/yarn-4.9.2.cjs workspace @yalo/chat-sdk run test

# Serve the demo
npx serve .   # then open http://localhost:3000/index.html
```

## Architecture

Two packages in a Yarn workspace monorepo:

```
packages/
├── core/              @yalo/chat-sdk-core   — pure logic, no DOM
└── web-components/    @yalo/chat-sdk        — Lit 3 components
scripts/bundle.js                            — esbuild → dist/yalo-chat.js
```

### `@yalo/chat-sdk-core`

Mirrors Flutter's Clean Architecture layers:

| Layer | Path | Flutter equivalent |
|-------|------|--------------------|
| Domain models | `src/domain/` | `lib/src/domain/models/` |
| Repositories (interfaces + impls) | `src/data/repositories/` | `lib/src/data/repositories/` |
| Services | `src/data/services/` | `lib/src/data/services/` |
| HTTP client | `src/data/client/yalo-chat-client.ts` | `YaloChatClient` |
| Stores (state) | `src/store/` | BLoC view models |
| Use cases | `src/use-cases/` | `lib/src/domain/use_cases/` |

**`Result<T>`** (`src/common/result.ts`) — `{ ok: true; value: T } | { ok: false; error: Error }` — returned by every repository and service method.

**Stores** extend `EventTarget` and dispatch `CustomEvent('change', { detail: state })` on every state mutation. This replaces Flutter's BLoC `Stream`. There are three stores: `ChatStore`, `AudioStore`, `ImageStore`.

**`ChatStore`** is the central piece: it wires the `ChatMessageRepository` (IndexedDB via `IdbService`), the `YaloMessageRepository` (HTTP polling every 1 s with a 5 s lookback window, LRU dedup on `wiId`), and the `ImageRepository`. Call `store.initialize()` to load the first page and start polling.

**`YaloMessageRepositoryFake`** is the in-memory stub used in all tests — it exposes `simulateMessage()` and `simulateEvent()`.

### `@yalo/chat-sdk` (web-components)

All UI is built with **Lit 3** `LitElement`. Components receive stores as properties (not via context) and subscribe/unsubscribe in `connectedCallback` / `disconnectedCallback`.

**`<yalo-chat>`** (`src/components/yalo-chat.ts`) is the root component. It constructs all services, repositories, and stores internally on `connectedCallback`, then renders `<yalo-chat-app-bar>`, `<yalo-message-list>`, and `<yalo-chat-input>`.

**Theme** is a plain `ChatTheme` interface (`src/theme/chat-theme.ts`). `applyTheme()` writes CSS custom properties (prefixed `--yalo-*`) directly onto the host element's `style`. Components consume them via `var(--yalo-*)` in their shadow CSS.

### Bundle

`scripts/bundle.js` runs esbuild with an `onResolve` plugin that redirects `@yalo/chat-sdk-core` → `packages/core/src/index.ts` so both packages are inlined into the single `dist/yalo-chat.js` (ESM, minified, ~89 KB).

## TypeScript Guidelines

From the team skill (`/.claude/skills/typescript_pattern_and_guidelines/SKILL.md`):

- **No `any`** — use `unknown` with type narrowing.
- **No magic strings** — use `enum`.
- **Replace `if/else` chains** with map-dispatch (`Record<Enum, fn>`) or tuple arrays + `Array#find` / `Array#reduce`.
- **Replace repeated comparisons** with `Array#includes`.

## Known Pitfalls

- **`.js` extensions in imports** — source files use `.js` suffixes (ESM convention). Jest can't resolve them; every `jest.config.js` must include `moduleNameMapper: { '^(\\.{1,2}/.*)\\.js$': '$1' }`.
- **`Uint8Array` → `Blob`** — TypeScript strict mode requires `new Blob([data.buffer as ArrayBuffer], ...)`.
- **Build order matters** — `web-components` depends on compiled output from `core`. Always use `--topological-dev` for builds. `tsc -b` (project references) is used in web-components; `tsc -p` in core.
- **ICU plural patterns** — `formatUnit` in `src/common/format.ts` uses `(\w+)\s*\{([^}]*)\}/g` to extract plural choices. Don't use a single outer-brace regex — it breaks on nested `{}`.
