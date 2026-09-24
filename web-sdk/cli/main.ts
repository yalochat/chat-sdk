#!/usr/bin/env bun
// Copyright (c) Yalochat, Inc. All rights reserved.

import { parseArgs, USAGE, UsageError } from './args';
import { runChat } from './commands/chat';
import { runSend } from './commands/send';

async function main(): Promise<number> {
  let args;
  try {
    args = parseArgs(process.argv.slice(2));
  } catch (error) {
    if (error instanceof UsageError) {
      console.error(`error: ${error.message}\n\n${USAGE}`);
      return 2;
    }
    throw error;
  }

  switch (args.command) {
    case 'help':
      console.log(USAGE);
      return 0;
    case 'chat':
      return runChat(args.common);
    case 'send':
      return runSend(
        args.common,
        args.text,
        args.waitMs,
        args.quietMs,
        (line) => console.log(line),
        (line) => console.error(line)
      );
  }
}

process.exitCode = await main();
