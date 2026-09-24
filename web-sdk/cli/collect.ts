// Copyright (c) Yalochat, Inc. All rights reserved.

import type { PollMessageItem } from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import type { WebchatSession } from './session';

export interface CollectOptions {
  // Hard upper bound on how long to listen.
  waitMs: number;
  // Once at least one message arrived, stop after this long without a new one.
  // A flow answers in bursts (welcome step, then the agent a few seconds later),
  // so this has to be longer than the gap between bursts.
  quietMs: number;
}

// Subscribes, runs `start` (the send), and resolves with everything that
// arrived before the conversation went quiet or the hard deadline hit.
export function collectReplies(
  session: WebchatSession,
  start: () => Promise<void>,
  options: CollectOptions,
  onMessage: (item: PollMessageItem) => void = () => {}
): Promise<PollMessageItem[]> {
  return new Promise((resolve, reject) => {
    const received: PollMessageItem[] = [];
    let quietTimer: ReturnType<typeof setTimeout> | undefined;

    const finish = () => {
      clearTimeout(quietTimer);
      clearTimeout(deadline);
      session.close();
      resolve(received);
    };

    const deadline = setTimeout(finish, options.waitMs);

    session.subscribe((item) => {
      received.push(item);
      onMessage(item);
      clearTimeout(quietTimer);
      quietTimer = setTimeout(finish, options.quietMs);
    });

    start().catch((error: unknown) => {
      clearTimeout(quietTimer);
      clearTimeout(deadline);
      session.close();
      reject(error);
    });
  });
}
