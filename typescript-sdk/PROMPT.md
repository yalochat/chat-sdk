# Prompt: TypeScript SDK — Web Components Port of Flutter Chat SDK

## Context

There is a Flutter SDK at `flutter-sdk/` that provides a full-featured chat UI (text, images, audio, product carousels) for mobile apps. Port it to `typescript-sdk/` as a **Web Components library** (framework-agnostic, works in any HTML page or JS framework), using **Yarn 4 workspaces + Jest + tsc + esbuild**.

The Yarn 4 binary is available at `.yarn/releases/yarn-4.9.2.cjs`. Use it for all commands. Do not use `yarn workspaces run` — Yarn 4 uses `yarn workspaces foreach -A`.

---

## Technology Mapping

| Flutter | TypeScript |
|---------|-----------|
| BLoC (events/state) | `EventTarget`-based Stores |
| Drift / SQLite | `idb` (IndexedDB) |
| Flutter widgets | Lit 3.x `LitElement` Web Components |
| Provider / BlocProvider | Store passed as property |
| CustomPainter | `<canvas>` 2D API |
| `record` package | `MediaRecorder` + `AnalyserNode` (Web Audio API) |
| `image_picker` | `<input type="file">` + File API |
| `http` package | Fetch API (native) |
| `ecache` LRU | `Map`-based LRU (500 cap) |

---

## Monorepo Structure

```
typescript-sdk/
├── package.json                  # Yarn workspace root
├── tsconfig.base.json            # Shared TS config
├── jest.config.base.js           # Shared Jest config
├── .yarnrc.yml                   # nodeLinker + yarnPath
├── .tool-versions                # nodejs 20.19.6
├── scripts/
│   └── bundle.js                 # esbuild — produces dist/yalo-chat.js
├── dist/
│   └── yalo-chat.js              # Single ESM bundle (output)
├── index.html                    # Demo page
└── packages/
    ├── core/                     # @yalo/chat-sdk-core — no DOM deps
    │   ├── package.json
    │   ├── tsconfig.json         # composite: true
    │   ├── jest.config.js
    │   └── src/
    │       ├── index.ts
    │       ├── common/
    │       │   ├── result.ts
    │       │   ├── page.ts
    │       │   ├── format.ts
    │       │   └── exceptions.ts
    │       ├── domain/
    │       │   ├── chat-message.ts
    │       │   ├── product.ts
    │       │   ├── audio-data.ts
    │       │   ├── image-data.ts
    │       │   ├── chat-event.ts
    │       │   └── yalo-message.ts
    │       ├── use-cases/
    │       │   └── audio-processing.ts
    │       ├── data/
    │       │   ├── client/
    │       │   │   └── yalo-chat-client.ts
    │       │   ├── services/
    │       │   │   ├── database/idb-service.ts
    │       │   │   ├── audio/audio-service.ts
    │       │   │   ├── audio/audio-service-web.ts
    │       │   │   ├── camera/camera-service.ts
    │       │   │   └── camera/camera-service-web.ts
    │       │   └── repositories/
    │       │       ├── chat-message/chat-message-repository.ts
    │       │       ├── chat-message/chat-message-repository-idb.ts
    │       │       ├── yalo-message/yalo-message-repository.ts
    │       │       ├── yalo-message/yalo-message-repository-remote.ts
    │       │       ├── yalo-message/yalo-message-repository-fake.ts
    │       │       ├── image/image-repository.ts
    │       │       ├── image/image-repository-web.ts
    │       │       ├── audio/audio-repository.ts
    │       │       └── audio/audio-repository-web.ts
    │       └── store/
    │           ├── chat-store.ts
    │           ├── audio-store.ts
    │           └── image-store.ts
    └── web-components/           # @yalo/chat-sdk — Lit components
        ├── package.json
        ├── tsconfig.json         # references: [../core]
        ├── jest.config.js
        └── src/
            ├── index.ts
            ├── theme/
            │   ├── chat-theme.ts
            │   ├── colors.ts
            │   └── constants.ts
            └── components/
                ├── yalo-chat.ts
                ├── chat-app-bar.ts
                ├── message-list.ts
                ├── chat-input/
                │   ├── chat-input.ts
                │   ├── action-button.ts
                │   ├── attachment-button.ts
                │   ├── quick-reply.ts
                │   ├── image-preview.ts
                │   ├── waveform-recorder.ts
                │   └── picker-button.ts
                └── messages/
                    ├── message.ts
                    ├── user-message.ts
                    ├── assistant-message.ts
                    ├── user-voice-message.ts
                    ├── user-image-message.ts
                    ├── assistant-product-message.ts
                    ├── product-horizontal-card.ts
                    ├── product-vertical-card.ts
                    ├── product-message-price.ts
                    ├── numeric-text-field.ts
                    ├── expand-button.ts
                    └── image-placeholder.ts
```

---

## Key Configuration Files

### `.tool-versions`
```
nodejs 20.19.6
```

### `.yarnrc.yml`
```yaml
nodeLinker: node-modules
yarnPath: .yarn/releases/yarn-4.9.2.cjs
```

### Root `package.json`
```json
{
  "name": "yalo-chat-typescript-sdk",
  "private": true,
  "workspaces": ["packages/*"],
  "scripts": {
    "build": "yarn workspaces foreach -A --topological-dev run build && node scripts/bundle.js",
    "bundle": "node scripts/bundle.js",
    "test": "yarn workspaces foreach -A run test",
    "test:watch": "yarn workspaces foreach -A run test --watch",
    "clean": "yarn workspaces foreach -A run clean && rm -rf dist"
  },
  "devDependencies": {
    "esbuild": "^0.24.0"
  },
  "packageManager": "yarn@4.9.2"
}
```

### `tsconfig.base.json`
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ES2020",
    "moduleResolution": "bundler",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "strict": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "experimentalDecorators": true,
    "useDefineForClassFields": false
  }
}
```

### `jest.config.base.js`
```js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  transform: { '^.+\\.tsx?$': ['ts-jest', { useESM: false }] },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json'],
  testMatch: ['**/__tests__/**/*.test.ts', '**/*.test.ts'],
  collectCoverageFrom: ['src/**/*.ts', '!src/**/*.d.ts'],
};
```

### `packages/core/package.json`
```json
{
  "name": "@yalo/chat-sdk-core",
  "version": "0.0.1",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc -p tsconfig.json",
    "test": "jest",
    "clean": "rm -rf dist"
  },
  "dependencies": { "idb": "^8.0.0" },
  "devDependencies": {
    "typescript": "^5.4.0",
    "@types/jest": "^29.0.0",
    "jest": "^29.0.0",
    "jest-environment-jsdom": "^29.0.0",
    "ts-jest": "^29.0.0"
  }
}
```

### `packages/core/tsconfig.json`
```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist", "rootDir": "src",
    "module": "CommonJS", "moduleResolution": "node",
    "composite": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

### `packages/core/jest.config.js`
```js
const base = require('../../jest.config.base.js');
module.exports = {
  ...base,
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  moduleNameMapper: { '^(\\.{1,2}/.*)\\.js$': '$1' },
};
```

### `packages/web-components/package.json`
```json
{
  "name": "@yalo/chat-sdk",
  "version": "0.0.1",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc -b tsconfig.json",
    "test": "jest",
    "clean": "rm -rf dist"
  },
  "dependencies": {
    "@yalo/chat-sdk-core": "workspace:*",
    "lit": "^3.1.0",
    "@lit/context": "^1.1.0",
    "marked": "^12.0.0"
  },
  "devDependencies": {
    "typescript": "^5.4.0",
    "@types/jest": "^29.0.0",
    "jest": "^29.0.0",
    "jest-environment-jsdom": "^29.0.0",
    "ts-jest": "^29.0.0"
  }
}
```

### `packages/web-components/tsconfig.json`
```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist", "rootDir": "src",
    "module": "CommonJS", "moduleResolution": "node"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"],
  "references": [{ "path": "../core" }]
}
```

### `packages/web-components/jest.config.js`
```js
const base = require('../../jest.config.base.js');
module.exports = {
  ...base,
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/src'],
  moduleNameMapper: {
    '^@yalo/chat-sdk-core$': '<rootDir>/../core/src/index.ts',
    '^@yalo/chat-sdk-core/(.*)$': '<rootDir>/../core/src/$1',
    '^(\\.{1,2}/.*)\\.js$': '$1',
  },
};
```

### `scripts/bundle.js` (root)
```js
const { build } = require('esbuild');
const { join } = require('path');

const root = join(__dirname, '..');
const core = join(root, 'packages/core/src/index.ts');
const webComponents = join(root, 'packages/web-components/src/index.ts');

build({
  entryPoints: [webComponents],
  bundle: true,
  format: 'esm',
  outfile: join(root, 'dist/yalo-chat.js'),
  minify: true,
  sourcemap: true,
  target: ['es2020', 'chrome90', 'firefox90', 'safari14'],
  tsconfig: join(root, 'packages/web-components/tsconfig.json'),
  plugins: [{
    name: 'workspace-core',
    setup(build) {
      build.onResolve({ filter: /^@yalo\/chat-sdk-core$/ }, () => ({ path: core }));
    },
  }],
}).then(() => {
  const size = (require('fs').statSync(join(root, 'dist/yalo-chat.js')).size / 1024).toFixed(1);
  console.log(`Bundle written to dist/yalo-chat.js (${size} KB)`);
}).catch((err) => { console.error(err); process.exit(1); });
```

---

## Core Patterns

### `result.ts`
```ts
export type Result<T> = { ok: true; value: T } | { ok: false; error: Error };
export const ok = <T>(value: T): Result<T> => ({ ok: true, value });
export const err = (error: Error): Result<never> => ({ ok: false, error });
```

### `page.ts`
```ts
export interface PageInfo {
  total?: number; totalPages?: number; page?: number;
  cursor?: number; nextCursor?: number; prevCursor?: number;
  pageSize: number;
}
export interface Page<T> { data: T[]; pageInfo: PageInfo; }
export type PageDirection = 'initial' | 'next' | 'prev';
export const DEFAULT_PAGE_SIZE = 30;
```

### Store Pattern (replaces BLoC)
```ts
export class ChatStore extends EventTarget {
  private _state: ChatState;

  constructor(private deps: ChatDependencies) {
    super();
    this._state = initialChatState();
  }

  get state(): Readonly<ChatState> { return this._state; }

  private setState(patch: Partial<ChatState>): void {
    this._state = { ...this._state, ...patch };
    this.dispatchEvent(new CustomEvent('change', { detail: this._state }));
  }
}
```

### Lit Component ↔ Store Connection
```ts
@customElement('yalo-message-list')
export class YaloMessageList extends LitElement {
  @property({ attribute: false }) store!: ChatStore;
  private _state: ChatState = initialChatState();
  private _handler = (e: Event) => {
    this._state = (e as CustomEvent<ChatState>).detail;
    this.requestUpdate();
  };
  connectedCallback() { super.connectedCallback(); this.store.addEventListener('change', this._handler); }
  disconnectedCallback() { super.disconnectedCallback(); this.store.removeEventListener('change', this._handler); }
}
```

### ICU Plural formatting (`format.ts`)
The naive regex approach breaks on nested braces. Use this instead:
```ts
export function formatUnit(amount: number, pattern: string, locale?: string): string {
  const rounded = Math.round(amount);
  const l = locale ?? (typeof navigator !== 'undefined' ? navigator.language : 'en');
  const rule = new Intl.PluralRules(l).select(rounded);
  const choices: Record<string, string> = {};
  const re = /(\w+)\s*\{([^}]*)\}/g;
  let m: RegExpExecArray | null;
  while ((m = re.exec(pattern)) !== null) {
    if (m[1] !== 'amount') choices[m[1]] = m[2];
  }
  const text = choices[rule] ?? choices['other'];
  if (!text) return pattern.replace(/\{amount\}/g, String(rounded));
  return text.trim().replace(/\{amount\}/g, String(rounded));
}
```

### `Uint8Array` → `Blob` (TypeScript strict mode)
```ts
// Wrong — TS complains about ArrayBufferLike vs ArrayBuffer
new Blob([data], { type: mimeType });

// Correct
new Blob([data.buffer as ArrayBuffer], { type: mimeType });
```

---

## IndexedDB Schema (mirrors Drift chat_message table)

```ts
interface ChatMessageRecord {
  id?: number;           // auto-increment PK
  wiId?: string;         // unique index
  role: string;
  content: string;
  type: string;
  status: string;
  fileName?: string;
  amplitudes?: string;   // JSON number[]
  duration?: number;
  products?: string;     // JSON Product[]
  quickReplies?: string; // JSON string[]
  timestamp: number;     // ms since epoch
}
// Indexes: 'by-timestamp', 'by-wiId' (unique)
// Pagination: openCursor with IDBKeyRange.upperBound(cursor, true), direction 'prev'
```

---

## Polling (mirrors Flutter's YaloMessageRepositoryRemote)
- Poll every **1 000 ms**
- Lookback window: **5 seconds** (`since = now_sec - 5`)
- Deduplicate via **LRU cache** (500 cap) keyed on `wiId`
- Emit `typingStart` on `sendMessage`, `typingStop` when responses arrive or on error

---

## Theme via CSS Custom Properties
```ts
export function applyTheme(theme: ChatTheme, element: HTMLElement): void {
  element.style.setProperty('--yalo-bg-color', theme.backgroundColor);
  element.style.setProperty('--yalo-send-btn-color', theme.sendButtonColor);
  // ... all other tokens
}
```

---

## Build & Test Commands
```bash
# Install (Yarn 4 binary is in .yarn/releases/)
node .yarn/releases/yarn-4.9.2.cjs install

# Build both packages + produce dist/yalo-chat.js
node .yarn/releases/yarn-4.9.2.cjs workspaces foreach -A --topological-dev run build && node scripts/bundle.js

# Bundle only (after packages are built)
node scripts/bundle.js

# Run all tests (35 tests, 8 suites)
node .yarn/releases/yarn-4.9.2.cjs workspaces foreach -A run test

# Run a single package
node .yarn/releases/yarn-4.9.2.cjs workspace @yalo/chat-sdk-core run test
node .yarn/releases/yarn-4.9.2.cjs workspace @yalo/chat-sdk run test
```

---

## Demo HTML (`index.html`)
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Yalo Chat SDK — Demo</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: system-ui, -apple-system, sans-serif;
      background: #f0f2f5;
      display: flex; align-items: center; justify-content: center; min-height: 100vh;
    }
    .chat-wrapper {
      width: 400px; height: 680px;
      border-radius: 16px; overflow: hidden;
      box-shadow: 0 8px 32px rgba(0,0,0,0.15);
    }
    yalo-chat { width: 100%; height: 100%; display: block; }
  </style>
</head>
<body>
  <div class="chat-wrapper">
    <yalo-chat
      name="Support"
      flow-key="YOUR_FLOW_KEY"
      user-token="YOUR_USER_TOKEN"
      auth-token="YOUR_AUTH_TOKEN"
      chat-base-url="https://YOUR_CHAT_BASE_URL"
      show-attachment-button="true"
    ></yalo-chat>
  </div>
  <script type="module">
    import './dist/yalo-chat.js';
    const chat = document.querySelector('yalo-chat');
    chat.theme = { sendButtonColor: '#2207F1', backgroundColor: '#ffffff' };
    chat.addEventListener('shop-pressed', () => console.log('shop'));
    chat.addEventListener('cart-pressed', () => console.log('cart'));
  </script>
</body>
</html>
```

Serve with: `npx serve .` or `python3 -m http.server 8080` (must use a server, not `file://`).

---

## Gotchas & Lessons Learned

1. **Yarn 4 syntax** — use `foreach -A` not `run`. Topological build order: `--topological-dev`.
2. **`.js` imports in Jest** — add `moduleNameMapper: { '^(\\.{1,2}/.*)\\.js$': '$1' }` to every Jest config.
3. **TypeScript Project References** — web-components must use `tsc -b` and `"references": [{"path": "../core"}]`. Core needs `"composite": true`. Without this, `rootDir` errors appear at build time.
4. **`moduleNameMapper` empty string** — mapping `.js$` to `''` crashes Jest resolver. Always use `'$1'` capture group.
5. **`Uint8Array` + `Blob`** — in strict TS, cast `data.buffer as ArrayBuffer`.
6. **ICU plural regex** — `[^}]+` matches `{` so naïve regex breaks on nested braces. Use `(\w+)\s*\{([^}]*)\}/g` to extract keyword/text pairs directly.
7. **esbuild + workspace packages** — use an `onResolve` plugin to redirect `@yalo/chat-sdk-core` → absolute source path so both packages are bundled together.
8. **Bundle location** — `scripts/bundle.js` and `dist/` live at the monorepo root, not inside any package.
