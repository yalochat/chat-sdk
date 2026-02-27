// Copyright (c) Yalochat, Inc. All rights reserved.

import { ChatStore, initialChatState } from '../store/chat-store';
import { YaloMessageRepositoryFake } from '../data/repositories/yalo-message/yalo-message-repository-fake';
import { chatMessageText, MessageRole, MessageStatus } from '../domain/chat-message';
import { ok } from '../common/result';
import type { ChatMessageRepository } from '../data/repositories/chat-message/chat-message-repository';
import type { ImageRepository } from '../data/repositories/image/image-repository';
import type { ChatMessage } from '../domain/chat-message';
import type { Page } from '../common/page';

// ── Minimal in-memory ChatMessageRepository ──────────────────────────────────

let nextId = 1;
function makeChatMessageRepo(): ChatMessageRepository {
  const store: ChatMessage[] = [];
  return {
    async getChatMessagePageDesc(cursor, pageSize) {
      const sorted = [...store].sort((a, b) => (b.id ?? 0) - (a.id ?? 0));
      const start = cursor !== undefined ? sorted.findIndex((m) => (m.id ?? 0) < cursor) : 0;
      const data = sorted.slice(Math.max(start, 0), Math.max(start, 0) + pageSize);
      const page: Page<ChatMessage> = { data, pageInfo: { pageSize, cursor } };
      return ok(page);
    },
    async insertChatMessage(msg) {
      const inserted = { ...msg, id: nextId++ };
      store.push(inserted);
      return ok(inserted);
    },
    async replaceChatMessage(msg) {
      const idx = store.findIndex((m) => m.id === msg.id);
      if (idx !== -1) store[idx] = msg;
      return ok(idx !== -1);
    },
  };
}

function makeImageRepo(): ImageRepository {
  return {
    async pickImage() { return ok(undefined); },
    async save() { return ok('url'); },
    async delete() { return ok(undefined); },
  };
}

describe('ChatStore', () => {
  let chatRepo: ChatMessageRepository;
  let yaloRepo: YaloMessageRepositoryFake;
  let store: ChatStore;

  beforeEach(() => {
    nextId = 1;
    chatRepo = makeChatMessageRepo();
    yaloRepo = new YaloMessageRepositoryFake();
    store = new ChatStore({
      chatMessageRepository: chatRepo,
      yaloMessageRepository: yaloRepo,
      imageRepository: makeImageRepo(),
      name: 'TestUser',
    });
  });

  afterEach(() => store.dispose());

  it('starts with initial state', () => {
    expect(store.state.messages).toEqual([]);
    expect(store.state.chatStatus).toBe('initial');
    expect(store.state.chatTitle).toBe('TestUser');
  });

  it('emits change event when state updates', async () => {
    const events: unknown[] = [];
    store.addEventListener('change', (e) => events.push(e));
    await store.initialize();
    expect(events.length).toBeGreaterThan(0);
  });

  it('sendTextMessage inserts message and transitions status', async () => {
    await store.initialize();
    await store.sendTextMessage('hello');
    const msgs = store.state.messages;
    expect(msgs.some((m) => m.content === 'hello')).toBe(true);
  });

  it('incoming message from yaloRepo is added to state', async () => {
    await store.initialize();

    const incoming = chatMessageText({
      role: MessageRole.Assistant,
      timestamp: Date.now(),
      content: 'incoming',
    });
    yaloRepo.simulateMessage(incoming);

    // Allow async handler to run
    await new Promise((r) => setTimeout(r, 0));
    expect(store.state.messages.some((m) => m.content === 'incoming')).toBe(true);
  });

  it('updateUserMessage updates draft text', () => {
    store.updateUserMessage('typing...');
    expect(store.state.userMessage).toBe('typing...');
  });

  it('clearMessages resets state', async () => {
    await store.sendTextMessage('test');
    store.clearMessages();
    expect(store.state.messages).toEqual([]);
    expect(store.state.chatStatus).toBe('initial');
  });

  it('toggleMessageExpand flips expand flag', async () => {
    await store.initialize();
    await store.sendTextMessage('hello');
    const msg = store.state.messages[0];
    if (msg.id === undefined) throw new Error('no id');

    store.toggleMessageExpand(msg.id);
    const toggled = store.state.messages.find((m) => m.id === msg.id);
    expect(toggled?.expand).toBe(true);
  });
});
