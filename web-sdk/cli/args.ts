// Copyright (c) Yalochat, Inc. All rights reserved.

import { isEnv, type Env } from './config';

export interface CommonArgs {
  env: Env;
  channelId: string;
  organizationId: string;
  userId?: string;
  context?: string;
  json: boolean;
}

export type ParsedArgs =
  | {
      command: 'send';
      text: string;
      waitMs: number;
      quietMs: number;
      common: CommonArgs;
    }
  | { command: 'chat'; common: CommonArgs }
  | { command: 'help' };

export class UsageError extends Error {}

export const USAGE = `yalo-webchat — talk to a Yalo webchat channel from the terminal

Usage:
  yalo-webchat send "<text>" --channel-id <uuid> --org-id <id> [options]
  yalo-webchat chat --channel-id <uuid> --org-id <id> [options]

Options:
  --env prod|staging   Environment (default: prod)
  --channel-id         Channel id (Studio → Channels → "ID del canal")
  --org-id             Organization id (Studio → Channels → "ID de organización")
  --user-id            Authenticate as a third-party user instead of anonymous
  --context '<json>'   Open the conversation with this context (widget openContext)
  --wait <seconds>     send: max time to listen for replies (default: 30)
  --quiet <seconds>    send: stop after this long without a new reply (default: 20)
  --json               Print one raw SdkMessage per line (NDJSON)
  -h, --help           Show this help
`;

const VALUE_FLAGS = new Set([
  '--env',
  '--channel-id',
  '--org-id',
  '--user-id',
  '--context',
  '--wait',
  '--quiet',
]);

// Hand-rolled on purpose: node:util parseArgs would pull a Node-only import
// into code the browser-mode test runner has to load.
export function parseArgs(argv: string[]): ParsedArgs {
  const flags = new Map<string, string>();
  const positionals: string[] = [];
  let json = false;

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '-h' || arg === '--help') return { command: 'help' };
    if (arg === '--json') {
      json = true;
    } else if (VALUE_FLAGS.has(arg)) {
      const value = argv[++i];
      if (value === undefined) throw new UsageError(`${arg} needs a value`);
      flags.set(arg, value);
    } else if (arg.startsWith('--')) {
      throw new UsageError(`unknown option ${arg}`);
    } else {
      positionals.push(arg);
    }
  }

  const [command, ...rest] = positionals;
  if (!command) return { command: 'help' };

  const env = flags.get('--env') ?? 'prod';
  if (!isEnv(env))
    throw new UsageError(`--env must be prod or staging, got ${env}`);

  const channelId = flags.get('--channel-id');
  const organizationId = flags.get('--org-id');
  if (!channelId || !organizationId) {
    throw new UsageError('--channel-id and --org-id are required');
  }

  const context = flags.get('--context');
  if (context !== undefined) {
    try {
      JSON.parse(context);
    } catch {
      throw new UsageError('--context must be valid JSON');
    }
  }

  const common: CommonArgs = {
    env,
    channelId,
    organizationId,
    userId: flags.get('--user-id'),
    context,
    json,
  };

  if (command === 'chat') return { command: 'chat', common };

  if (command === 'send') {
    const text = rest.join(' ');
    if (!text) throw new UsageError('send needs the text to send');
    return {
      command: 'send',
      text,
      waitMs: seconds(flags.get('--wait'), 30, '--wait'),
      quietMs: seconds(flags.get('--quiet'), 20, '--quiet'),
      common,
    };
  }

  throw new UsageError(`unknown command ${command}`);
}

function seconds(
  value: string | undefined,
  fallback: number,
  name: string
): number {
  if (value === undefined) return fallback * 1000;
  const n = Number(value);
  if (!Number.isFinite(n) || n <= 0)
    throw new UsageError(`${name} must be a positive number`);
  return n * 1000;
}
