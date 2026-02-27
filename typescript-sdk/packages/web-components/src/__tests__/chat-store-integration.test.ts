// Copyright (c) Yalochat, Inc. All rights reserved.

/**
 * Integration test: verifies that ChatStore + YaloMessageRepositoryFake
 * correctly wires message delivery end-to-end.
 */
import {
  ChatStore,
  initialChatState,
  YaloMessageRepositoryFake,
  chatMessageText,
  MessageRole,
} from '@yalo/chat-sdk-core';
import type { ChatMessageRepository } from '@yalo/chat-sdk-core';
import type { ImageRepository } from '@yalo/chat-sdk-core';
import type { ChatMessage, Page } from '@yalo/chat-sdk-core';
import { ok } from '@yalo/chat-sdk-core';

let nextId = 1;
function makeRepos() {
  const messages: ChatMessage[] = [];

  const chatRepo: ChatMessageRepository = {
    async getChatMessagePageDesc(_cursor, pageSize) {
      const sorted = [...messages].sort((a, b) => (b.id ?? 0) - (a.id ?? 0));
      const data = sorted.slice(0, pageSize);
      const page: Page<ChatMessage> = { data, pageInfo: { pageSize } };
      return ok(page);
    },
    async insertChatMessage(msg) {
      const m = { ...msg, id: nextId++ };
      messages.push(m);
      return ok(m);
    },
    async replaceChatMessage(msg) {
      const idx = messages.findIndex((m) => m.id === msg.id);
      if (idx !== -1) messages[idx] = msg;
      return ok(idx !== -1);
    },
  };

  const imageRepo: ImageRepository = {
    async pickImage() { return ok(undefined); },
    async save() { return ok('url'); },
    async delete() { return ok(undefined); },
  };

  return { chatRepo, imageRepo };
}

describe('ChatStore integration', () => {
  let yaloRepo: YaloMessageRepositoryFake;
  let store: ChatStore;

  beforeEach(async () => {
    nextId = 1;
    const { chatRepo, imageRepo } = makeRepos();
    yaloRepo = new YaloMessageRepositoryFake();
    store = new ChatStore({
      chatMessageRepository: chatRepo,
      yaloMessageRepository: yaloRepo,
      imageRepository: imageRepo,
    });
    await store.initialize();
  });

  afterEach(() => store.dispose());

  it('starts empty after initialize', () => {
    expect(store.state.messages).toHaveLength(0);
    expect(store.state.chatStatus).toBe('success');
  });

  it('sends a text message and adds it to state', async () => {
    await store.sendTextMessage('hello world');
    expect(store.state.messages.some((m) => m.content === 'hello world')).toBe(true);
  });

  it('receives incoming messages from yaloRepo', async () => {
    const msg = chatMessageText({
      role: MessageRole.Assistant,
      timestamp: Date.now(),
      content: 'response from bot',
    });
    yaloRepo.simulateMessage(msg);
    await new Promise((r) => setTimeout(r, 0));
    expect(store.state.messages.some((m) => m.content === 'response from bot')).toBe(true);
  });

  it('clears messages', async () => {
    await store.sendTextMessage('test');
    store.clearMessages();
    expect(store.state.messages).toHaveLength(0);
  });
});
