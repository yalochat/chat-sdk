// Copyright (c) Yalochat, Inc. All rights reserved.

import { collectReplies } from '../collect';
import type { CommonArgs } from '../args';
import { toJsonLine, toPrettyLine } from '../format';
import { WebchatSession } from '../session';

export async function runSend(
  common: CommonArgs,
  text: string,
  waitMs: number,
  quietMs: number,
  write: (line: string) => void,
  log: (line: string) => void
): Promise<number> {
  const session = new WebchatSession(common);
  const auth = await session.connect();
  if (!auth.ok) {
    log(`auth failed: ${auth.error.message}`);
    return 1;
  }

  const replies = await collectReplies(
    session,
    async () => {
      if (common.context !== undefined) {
        const opened = await session.requestGuidanceCard(common.context);
        if (!opened.ok) throw opened.error;
      }
      const sent = await session.sendText(text);
      if (!sent.ok) throw sent.error;
      if (!common.json) log(`→ ${text}`);
    },
    { waitMs, quietMs },
    (item) => write(common.json ? toJsonLine(item) : toPrettyLine(item))
  );

  if (!common.json) log(`${replies.length} message(s) received`);
  return 0;
}
