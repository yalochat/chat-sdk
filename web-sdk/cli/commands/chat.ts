// Copyright (c) Yalochat, Inc. All rights reserved.

import { createInterface } from 'node:readline/promises';
import type { CommonArgs } from '../args';
import { toJsonLine, toPrettyLine } from '../format';
import { WebchatSession } from '../session';

export async function runChat(common: CommonArgs): Promise<number> {
  const session = new WebchatSession(common);
  const auth = await session.connect();
  if (!auth.ok) {
    console.error(`auth failed: ${auth.error.message}`);
    return 1;
  }

  const rl = createInterface({ input: process.stdin, output: process.stdout });
  session.subscribe((item) => {
    console.log(common.json ? toJsonLine(item) : toPrettyLine(item));
    rl.prompt(true);
  });

  if (common.context !== undefined) {
    const opened = await session.requestGuidanceCard(common.context);
    if (!opened.ok)
      console.error(`open context failed: ${opened.error.message}`);
  }

  console.error('Connected. Type a message, Ctrl+D to quit.');
  rl.setPrompt('> ');
  rl.prompt();
  for await (const line of rl) {
    const text = line.trim();
    if (text) {
      const sent = await session.sendText(text);
      if (!sent.ok) console.error(`send failed: ${sent.error.message}`);
    }
    rl.prompt();
  }

  session.close();
  return 0;
}
