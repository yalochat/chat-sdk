// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Page } from '@domain/common/page';
import type { Result } from '@domain/common/result';
import { Err, Ok } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import { ChatMessageRepository } from './chat-message-repository';

const DB_NAME = 'yalo-chat-messages';
const DB_VERSION = 1;
const STORE_NAME = 'chat_message';

type ChatMessageData = ConstructorParameters<typeof ChatMessage>[0] & {
  id: number;
};

export class ChatMessageRepositoryLocal extends ChatMessageRepository {
  private dbPromise: Promise<IDBDatabase>;

  constructor() {
    super();
    this.dbPromise = this.openDb();
  }

  async close(): Promise<void> {
    const db = await this.dbPromise;
    db.close();
  }

  private openDb(): Promise<IDBDatabase> {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION);

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result;
        if (!db.objectStoreNames.contains(STORE_NAME)) {
          const store = db.createObjectStore(STORE_NAME, {
            keyPath: 'id',
            autoIncrement: true,
          });
          store.createIndex('timestamp', 'timestamp', { unique: false });
        }
      };

      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  override async getChatMessagePageDesc(
    cursor: number | null,
    pageSize: number,
  ): Promise<Result<Page<ChatMessage>>> {
    try {
      const db = await this.dbPromise;
      const data = await new Promise<ChatMessage[]>((resolve, reject) => {
        const tx = db.transaction(STORE_NAME, 'readonly');
        const store = tx.objectStore(STORE_NAME);
        const index = store.index('timestamp');
        const results: ChatMessage[] = [];
        let skipping = cursor !== null;

        const request = index.openCursor(null, 'prev');

        request.onsuccess = () => {
          const idbCursor = request.result;
          if (!idbCursor) {
            resolve(results);
            return;
          }

          const record = idbCursor.value as ChatMessageData;

          if (skipping) {
            if (record.id === cursor) skipping = false;
            idbCursor.continue();
            return;
          }

          if (results.length < pageSize + 1) {
            results.push(new ChatMessage(record));
            idbCursor.continue();
          } else {
            resolve(results);
          }
        };

        request.onerror = () => reject(request.error);
      });

      const hasMore = data.length > pageSize;
      const page = hasMore ? data.slice(0, pageSize) : data;
      const nextCursor = hasMore ? page[page.length - 1].id : undefined;

      return new Ok({
        data: page,
        pageInfo: { cursor: cursor ?? undefined, nextCursor, pageSize },
      });
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  override async insertChatMessage(
    message: ChatMessage,
  ): Promise<Result<ChatMessage>> {
    try {
      const db = await this.dbPromise;
      const { id: _id, ...data } = message;
      const id = await new Promise<number>((resolve, reject) => {
        const tx = db.transaction(STORE_NAME, 'readwrite');
        const store = tx.objectStore(STORE_NAME);
        const request = store.add(data);
        request.onsuccess = () => resolve(request.result as number);
        request.onerror = () => reject(request.error);
      });

      return new Ok(new ChatMessage({ ...message, id }));
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  override async replaceChatMessage(
    message: ChatMessage,
  ): Promise<Result<boolean>> {
    if (message.id === undefined) {
      return new Err(new Error('Message must contain an id to replace'));
    }
    try {
      const db = await this.dbPromise;
      await new Promise<void>((resolve, reject) => {
        const tx = db.transaction(STORE_NAME, 'readwrite');
        const store = tx.objectStore(STORE_NAME);
        const request = store.put({ ...message });
        request.onsuccess = () => resolve();
        request.onerror = () => reject(request.error);
      });

      return new Ok(true);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }
}
