// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { ChatMessageRepositoryLocal } from './chat-message-repository-local';
import { TokenRepositoryLocal } from '@data/repositories/token/token-repository-local';

const DB_NAME = 'YaloChatMessages';
const DB_VERSION = 2;

function openDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION);

    request.onupgradeneeded = (event) => {
      const db = (event.target as IDBOpenDBRequest).result;
      ChatMessageRepositoryLocal.upgrade(db);
      TokenRepositoryLocal.upgrade(db);
    };

    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

function deleteDb(): Promise<void> {
  return new Promise((resolve, reject) => {
    const req = indexedDB.deleteDatabase(DB_NAME);
    req.onsuccess = () => resolve();
    req.onerror = () => reject(req.error);
  });
}

const makeMessage = (
  overrides: Partial<ConstructorParameters<typeof ChatMessage>[0]> = {}
) =>
  new ChatMessage({
    role: 'USER',
    type: 'text',
    content: 'Hello',
    timestamp: new Date('2024-01-01T10:00:00Z'),
    ...overrides,
  });

describe('ChatMessageRepositoryLocal', () => {
  let db: IDBDatabase;
  let repo: ChatMessageRepositoryLocal;

  beforeEach(async () => {
    db = await openDb();
    repo = new ChatMessageRepositoryLocal(db);
  });

  afterEach(async () => {
    db.close();
    await deleteDb();
  });

  describe('insertChatMessage', () => {
    it('returns Ok with the inserted message', async () => {
      const message = makeMessage();
      const result = await repo.insertChatMessage(message);
      expect(result).toBeInstanceOf(Ok);
    });

    it('assigns an id to the inserted message', async () => {
      const message = makeMessage();
      const result = await repo.insertChatMessage(message);
      expect((result as Ok<ChatMessage>).value.id).toBeDefined();
    });

    it('assigns incrementing ids for multiple inserts', async () => {
      const r1 = await repo.insertChatMessage(makeMessage());
      const r2 = await repo.insertChatMessage(makeMessage());
      const id1 = (r1 as Ok<ChatMessage>).value.id!;
      const id2 = (r2 as Ok<ChatMessage>).value.id!;
      expect(id2).toBeGreaterThan(id1);
    });

    it('preserves message fields after insert', async () => {
      const message = makeMessage({
        content: 'test content',
        role: 'AGENT',
        type: 'text',
      });
      const result = await repo.insertChatMessage(message);
      const inserted = (result as Ok<ChatMessage>).value;
      expect(inserted.content).toBe('test content');
      expect(inserted.role).toBe('AGENT');
      expect(inserted.type).toBe('text');
    });
  });

  describe('replaceChatMessage', () => {
    it('returns Err when message has no id', async () => {
      const message = makeMessage();
      const result = await repo.replaceChatMessage(message);
      expect(result).toBeInstanceOf(Err);
      expect((result as Err).error.message).toBe(
        'Message must contain an id to replace'
      );
    });

    it('returns Ok(true) after a successful replace', async () => {
      const insertResult = await repo.insertChatMessage(makeMessage());
      const inserted = (insertResult as Ok<ChatMessage>).value;

      const updated = new ChatMessage({
        ...inserted,
        content: 'updated',
        status: 'READ',
      });
      const replaceResult = await repo.replaceChatMessage(updated);

      expect(replaceResult).toBeInstanceOf(Ok);
      expect((replaceResult as Ok<boolean>).value).toBe(true);
    });

    it('reflects updated content when fetched after replace', async () => {
      const insertResult = await repo.insertChatMessage(makeMessage());
      const inserted = (insertResult as Ok<ChatMessage>).value;

      await repo.replaceChatMessage(
        new ChatMessage({ ...inserted, content: 'updated content' })
      );

      const pageResult = await repo.getChatMessagePageDesc(null, 10);
      const messages = (pageResult as Ok<{ data: ChatMessage[] }>).value.data;
      expect(messages.find((m) => m.id === inserted.id)?.content).toBe(
        'updated content'
      );
    });
  });

  describe('getChatMessagePageDesc', () => {
    it('returns Ok with empty data when store is empty', async () => {
      const result = await repo.getChatMessagePageDesc(null, 10);
      expect(result).toBeInstanceOf(Ok);
      expect((result as Ok<{ data: ChatMessage[] }>).value.data).toHaveLength(
        0
      );
    });

    it('returns inserted messages', async () => {
      await repo.insertChatMessage(makeMessage());
      await repo.insertChatMessage(makeMessage());

      const result = await repo.getChatMessagePageDesc(null, 10);
      expect((result as Ok<{ data: ChatMessage[] }>).value.data).toHaveLength(
        2
      );
    });

    it('returns messages in descending timestamp order', async () => {
      await repo.insertChatMessage(
        makeMessage({ timestamp: new Date('2024-01-01T09:00:00Z') })
      );
      await repo.insertChatMessage(
        makeMessage({ timestamp: new Date('2024-01-01T11:00:00Z') })
      );
      await repo.insertChatMessage(
        makeMessage({ timestamp: new Date('2024-01-01T10:00:00Z') })
      );

      const result = await repo.getChatMessagePageDesc(null, 10);
      const messages = (result as Ok<{ data: ChatMessage[] }>).value.data;

      expect(messages[0].timestamp.getTime()).toBeGreaterThanOrEqual(
        messages[1].timestamp.getTime()
      );
      expect(messages[1].timestamp.getTime()).toBeGreaterThanOrEqual(
        messages[2].timestamp.getTime()
      );
    });

    it('respects pageSize', async () => {
      for (let i = 0; i < 5; i++) {
        await repo.insertChatMessage(makeMessage());
      }

      const result = await repo.getChatMessagePageDesc(null, 3);
      expect((result as Ok<{ data: ChatMessage[] }>).value.data).toHaveLength(
        3
      );
    });

    it('sets nextCursor when there are more pages', async () => {
      for (let i = 0; i < 5; i++) {
        await repo.insertChatMessage(makeMessage());
      }

      const result = await repo.getChatMessagePageDesc(null, 3);
      const pageInfo = (
        result as Ok<{ data: ChatMessage[]; pageInfo: { nextCursor?: number } }>
      ).value.pageInfo;
      expect(pageInfo.nextCursor).toBeDefined();
    });

    it('sets nextCursor to undefined on the last page', async () => {
      await repo.insertChatMessage(makeMessage());
      await repo.insertChatMessage(makeMessage());

      const result = await repo.getChatMessagePageDesc(null, 10);
      const pageInfo = (
        result as Ok<{ data: ChatMessage[]; pageInfo: { nextCursor?: number } }>
      ).value.pageInfo;
      expect(pageInfo.nextCursor).toBeUndefined();
    });

    it('returns the next page when cursor is provided', async () => {
      for (let i = 0; i < 5; i++) {
        await repo.insertChatMessage(
          makeMessage({ timestamp: new Date(1000 * i) })
        );
      }

      const firstPage = await repo.getChatMessagePageDesc(null, 3);
      const { data, pageInfo } = (
        firstPage as Ok<{
          data: ChatMessage[];
          pageInfo: { nextCursor?: number };
        }>
      ).value;
      const firstIds = data.map((m) => m.id);

      const secondPage = await repo.getChatMessagePageDesc(
        pageInfo.nextCursor ?? null,
        3
      );
      const secondIds = (
        secondPage as Ok<{ data: ChatMessage[] }>
      ).value.data.map((m) => m.id);

      // No overlap between pages
      expect(secondIds.some((id) => firstIds.includes(id))).toBe(false);
    });

    it('reflects correct cursor in pageInfo', async () => {
      await repo.insertChatMessage(makeMessage());

      const result = await repo.getChatMessagePageDesc(null, 10);
      const pageInfo = (
        result as Ok<{ data: ChatMessage[]; pageInfo: { cursor?: number } }>
      ).value.pageInfo;
      expect(pageInfo.cursor).toBeUndefined();
    });
  });
});
