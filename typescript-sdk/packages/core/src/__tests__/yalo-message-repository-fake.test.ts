// Copyright (c) Yalochat, Inc. All rights reserved.

import { YaloMessageRepositoryFake } from '../data/repositories/yalo-message/yalo-message-repository-fake';
import { chatMessageText, MessageRole } from '../domain/chat-message';
import { typingStart, typingStop } from '../domain/chat-event';

describe('YaloMessageRepositoryFake', () => {
  let repo: YaloMessageRepositoryFake;

  beforeEach(() => {
    repo = new YaloMessageRepositoryFake();
  });

  it('delivers simulated messages to subscribers', () => {
    const received: ReturnType<typeof chatMessageText>[] = [];
    repo.onMessage((msg) => received.push(msg));

    const msg = chatMessageText({ role: MessageRole.Assistant, timestamp: Date.now(), content: 'hi' });
    repo.simulateMessage(msg);

    expect(received).toHaveLength(1);
    expect(received[0].content).toBe('hi');
  });

  it('delivers simulated events to subscribers', () => {
    const events: Array<{ type: string }> = [];
    repo.onEvent((e) => events.push(e));

    repo.simulateEvent(typingStart('thinking...'));
    repo.simulateEvent(typingStop());

    expect(events).toHaveLength(2);
    expect(events[0].type).toBe('typingStart');
    expect(events[1].type).toBe('typingStop');
  });

  it('unsubscribes correctly', () => {
    const received: unknown[] = [];
    const unsub = repo.onMessage((msg) => received.push(msg));
    unsub();

    repo.simulateMessage(chatMessageText({ role: MessageRole.Assistant, timestamp: Date.now(), content: 'x' }));
    expect(received).toHaveLength(0);
  });

  it('sendMessage always returns ok', async () => {
    const msg = chatMessageText({ role: MessageRole.User, timestamp: Date.now(), content: 'send' });
    const result = await repo.sendMessage(msg);
    expect(result.ok).toBe(true);
  });
});
