// Copyright (c) Yalochat, Inc. All rights reserved.

// Compiles cli/main.ts into a standalone binary.
//
// src/domain/models/events is a symlink into ../proto/typescript, and the
// bundler resolves imports from a file's real path. From there it cannot see
// web-sdk/node_modules, so bare specifiers inside the generated proto code
// (@bufbuild/protobuf/...) fail. Vite avoids this with preserveSymlinks; here a
// plugin resolves them from web-sdk instead.
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const webSdk = resolve(dirname(fileURLToPath(import.meta.url)), '..');

const result = await Bun.build({
  entrypoints: [resolve(webSdk, 'cli/main.ts')],
  target: 'bun',
  compile: { outfile: resolve(webSdk, 'dist/yalo-webchat') },
  plugins: [
    {
      name: 'resolve-packages-from-web-sdk',
      setup(build) {
        build.onResolve({ filter: /^@bufbuild\// }, (args) => ({
          path: Bun.resolveSync(args.path, webSdk),
        }));
      },
    },
  ],
});

if (!result.success) {
  for (const log of result.logs) console.error(log);
  process.exit(1);
}
console.log('Wrote dist/yalo-webchat');
