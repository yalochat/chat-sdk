// @ts-check
import { build } from 'esbuild';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, '..');

await build({
  entryPoints: [resolve(root, 'packages/web-components/src/index.ts')],
  bundle: true,
  format: 'esm',
  minify: true,
  outfile: resolve(root, 'dist/yalo-chat.js'),
  plugins: [
    {
      name: 'resolve-core',
      setup(build) {
        build.onResolve({ filter: /^@yalo\/chat-sdk-core$/ }, () => ({
          path: resolve(root, 'packages/core/src/index.ts'),
        }));
      },
    },
  ],
  define: {
    'process.env.NODE_ENV': '"production"',
  },
});

console.log('Bundle written to dist/yalo-chat.js');
