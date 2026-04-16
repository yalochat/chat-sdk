// Copyright (c) Yalochat, Inc. All rights reserved.
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { playwright } from '@vitest/browser-playwright';
import type { UserConfig } from 'vite';
import { defineConfig } from 'vitest/config';
import { version } from './package.json';

const __dirname = dirname(fileURLToPath(import.meta.url));
export default defineConfig(({ command }) => {
  const config = {
    resolve: {
      preserveSymlinks: true,
      alias: {
        '@common': resolve(__dirname, 'src/common'),
        '@data': resolve(__dirname, 'src/data'),
        '@domain': resolve(__dirname, 'src/domain'),
        '@i18n': resolve(__dirname, 'src/i18n'),
        '@log': resolve(__dirname, 'src/log'),
        '@ui': resolve(__dirname, 'src/ui'),
      },
    },
    publicDir: command === 'build' ? false : 'public',
    build: {
      outDir: `dist/v${version}`,
      lib: {
        entry: resolve(__dirname, 'src/chat.ts'),
        name: 'YaloChatSdk',
        fileName: () => 'sdk.js',
        formats: ['umd'],
      },
    },
    test: {
      browser: {
        provider: playwright(),
        enabled: true,
        instances: [{ browser: 'chromium' }],
      },
      coverage: {
        provider: 'istanbul',
        exclude: ['**/**/sdk_message.ts', '**/google/**/*'],
      },
    },
  } satisfies UserConfig;

  return config;
});
