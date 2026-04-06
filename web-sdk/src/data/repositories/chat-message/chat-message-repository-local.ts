// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Page } from '@domain/common/page';
import type { Result } from '@domain/common/result';
import { Err, Ok } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { ChatMessageRepository } from './chat-message-repository';

type ChatMessageData = ConstructorParameters<typeof ChatMessage>[0] & {
  id: number;
};

export class ChatMessageRepositoryLocal implements ChatMessageRepository {
  private static readonly _STORE_NAME = 'chatMessage';

  static upgrade(db: IDBDatabase): void {
    if (!db.objectStoreNames.contains(ChatMessageRepositoryLocal._STORE_NAME)) {
      const store = db.createObjectStore(
        ChatMessageRepositoryLocal._STORE_NAME,
        { keyPath: 'id', autoIncrement: true }
      );
      store.createIndex('wiId', 'wiId', { unique: true });
      store.createIndex('timestamp', 'timestamp', { unique: false });
    }
  }

  private db: IDBDatabase;

  constructor(db: IDBDatabase) {
    this.db = db;
  }

  async close(): Promise<void> {
    this.db.close();
  }

  async getChatMessagePageDesc(
    cursor: number | null,
    pageSize: number
  ): Promise<Result<Page<ChatMessage>>> {
    try {
      const db = this.db;
      const data = await new Promise<ChatMessage[]>((resolve, reject) => {
        const tx = db.transaction(
          ChatMessageRepositoryLocal._STORE_NAME,
          'readonly'
        );
        const store = tx.objectStore(ChatMessageRepositoryLocal._STORE_NAME);
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

  async insertChatMessage(message: ChatMessage): Promise<Result<ChatMessage>> {
    try {
      const db = this.db;
      const { ...data } = message;
      delete data.id;
      const id = await new Promise<number>((resolve, reject) => {
        const tx = db.transaction(
          ChatMessageRepositoryLocal._STORE_NAME,
          'readwrite'
        );
        const store = tx.objectStore(ChatMessageRepositoryLocal._STORE_NAME);
        const request = store.add(data);
        request.onsuccess = () => resolve(request.result as number);
        request.onerror = () => reject(request.error);
      });

      return new Ok(new ChatMessage({ ...message, id }));
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  async replaceChatMessage(message: ChatMessage): Promise<Result<boolean>> {
    if (message.id === undefined) {
      return new Err(new Error('Message must contain an id to replace'));
    }
    try {
      const db = this.db;
      await new Promise<void>((resolve, reject) => {
        const tx = db.transaction(
          ChatMessageRepositoryLocal._STORE_NAME,
          'readwrite'
        );
        const store = tx.objectStore(ChatMessageRepositoryLocal._STORE_NAME);
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
