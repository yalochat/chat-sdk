// Copyright (c) Yalochat, Inc. All rights reserved.
import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url';

import { defineConfig, type UserConfig } from 'vite';
import { version } from './package.json';

const __dirname = dirname(fileURLToPath(import.meta.url));
export default defineConfig(({ command }) => {

  const config = {
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
  } satisfies UserConfig;

  return config;
});
