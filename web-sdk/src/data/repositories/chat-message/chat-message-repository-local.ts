// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Page } from '@domain/common/page';
import type { Result } from '@domain/common/result';
import { Err, Ok } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { ChatMessageRepository } from './chat-message-repository';

export class ChatMessageRepositoryLocal implements ChatMessageRepository {
  private static readonly _STORE_NAME = 'chatMessage';

  static upgrade(db: IDBDatabase): void {
    if (!db.objectStoreNames.contains(ChatMessageRepositoryLocal._STORE_NAME)) {
      const store = db.createObjectStore(
        ChatMessageRepositoryLocal._STORE_NAME,
        { keyPath: 'id', autoIncrement: true }
      );
      store.createIndex('sessionId_wiId', ['sessionId', 'wiId'], {
        unique: true,
      });
      store.createIndex('sessionId', 'sessionId', { unique: false });
    }
  }

  private readonly db: IDBDatabase;
  private readonly sessionId: string;

  constructor(db: IDBDatabase, sessionId: string) {
    this.db = db;
    this.sessionId = sessionId;
  }

  async dispose(): Promise<void> {
    this.db.close();
  }

  async getChatMessagePageDesc(
    cursor: number | null,
    pageSize: number
  ): Promise<Result<Page<ChatMessage>>> {
    try {
      const sessionId = this.sessionId;
      const db = this.db;
      const data = await new Promise<ChatMessage[]>((resolve, reject) => {
        const tx = db.transaction(
          ChatMessageRepositoryLocal._STORE_NAME,
          'readonly'
        );
        const store = tx.objectStore(ChatMessageRepositoryLocal._STORE_NAME);
        const index = store.index('sessionId');
        const results: ChatMessage[] = [];
        let seeked = cursor === null;

        const request = index.openCursor(
          IDBKeyRange.only(sessionId),
          'prev'
        );

        request.onsuccess = () => {
          const idbCursor = request.result;
          if (!idbCursor) {
            resolve(results);
            return;
          }

          if (!seeked) {
            seeked = true;
            idbCursor.continuePrimaryKey(sessionId, cursor!);
            return;
          }

          if (idbCursor.primaryKey === cursor) {
            idbCursor.continue();
            return;
          }

          if (results.length < pageSize + 1) {
            results.push(idbCursor.value as ChatMessage);
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
      const sessionId = this.sessionId;
      const db = this.db;
      const { ...data } = message;
      delete data.id;
      const record = { ...data, sessionId };
      const id = await new Promise<number>((resolve, reject) => {
        const tx = db.transaction(
          ChatMessageRepositoryLocal._STORE_NAME,
          'readwrite'
        );
        const store = tx.objectStore(ChatMessageRepositoryLocal._STORE_NAME);

        if (record.wiId === undefined) {
          const addReq = store.add(record);
          addReq.onsuccess = () => resolve(addReq.result as number);
          addReq.onerror = () => reject(addReq.error);
          return;
        }

        const existingReq = store
          .index('sessionId_wiId')
          .get([sessionId, record.wiId]);
        existingReq.onsuccess = () => {
          const existing = existingReq.result as ChatMessage | undefined;
          if (existing) {
            resolve(existing.id!);
            return;
          }
          const addReq = store.add(record);
          addReq.onsuccess = () => resolve(addReq.result as number);
          addReq.onerror = () => reject(addReq.error);
        };
        existingReq.onerror = () => reject(existingReq.error);
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
      const sessionId = this.sessionId;
      const db = this.db;
      await new Promise<void>((resolve, reject) => {
        const tx = db.transaction(
          ChatMessageRepositoryLocal._STORE_NAME,
          'readwrite'
        );
        const store = tx.objectStore(ChatMessageRepositoryLocal._STORE_NAME);
        const request = store.put({ ...message, sessionId });
        request.onsuccess = () => resolve();
        request.onerror = () => reject(request.error);
      });

      return new Ok(true);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  async clearSession(): Promise<Result<boolean>> {
    try {
      const sessionId = this.sessionId;
      const db = this.db;
      await new Promise<void>((resolve, reject) => {
        const tx = db.transaction(
          ChatMessageRepositoryLocal._STORE_NAME,
          'readwrite'
        );
        const store = tx.objectStore(ChatMessageRepositoryLocal._STORE_NAME);
        const index = store.index('sessionId');
        const request = index.openCursor(IDBKeyRange.only(sessionId));
        request.onsuccess = () => {
          const cursor = request.result;
          if (!cursor) {
            resolve();
            return;
          }
          cursor.delete();
          cursor.continue();
        };
        request.onerror = () => reject(request.error);
      });
      return new Ok(true);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }
}
