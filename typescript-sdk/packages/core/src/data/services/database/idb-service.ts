// Copyright (c) Yalochat, Inc. All rights reserved.

import { openDB, type IDBPDatabase } from 'idb';
import type { ChatMessage } from '../../../domain/chat-message.js';
import { productFromJson, productToJson } from '../../../domain/product.js';
import type { Page, PageInfo } from '../../../common/page.js';
import { DEFAULT_PAGE_SIZE } from '../../../common/page.js';

const DB_NAME = 'yalo_chat_db';
const DB_VERSION = 1;
const STORE_NAME = 'chat_messages';

interface ChatMessageRecord {
  id?: number;
  wiId?: string;
  role: string;
  content: string;
  type: string;
  status: string;
  fileName?: string;
  amplitudes?: string;   // JSON-encoded number[]
  duration?: number;
  products?: string;     // JSON-encoded Product[]
  quickReplies?: string; // JSON-encoded string[]
  timestamp: number;     // ms since epoch
}

function recordToMessage(record: ChatMessageRecord & { id: number }): ChatMessage {
  return {
    id: record.id,
    wiId: record.wiId,
    role: record.role as ChatMessage['role'],
    content: record.content,
    type: record.type as ChatMessage['type'],
    status: record.status as ChatMessage['status'],
    timestamp: record.timestamp,
    fileName: record.fileName,
    amplitudes: record.amplitudes ? (JSON.parse(record.amplitudes) as number[]) : undefined,
    duration: record.duration,
    products: record.products ? (JSON.parse(record.products) as Record<string, unknown>[]).map(productFromJson) : [],
    expand: false,
    quickReplies: record.quickReplies ? (JSON.parse(record.quickReplies) as string[]) : [],
  };
}

function messageToRecord(message: ChatMessage): ChatMessageRecord {
  return {
    id: message.id,
    wiId: message.wiId,
    role: message.role,
    content: message.content,
    type: message.type,
    status: message.status,
    fileName: message.fileName,
    amplitudes: message.amplitudes ? JSON.stringify(message.amplitudes) : undefined,
    duration: message.duration,
    products: message.products.length > 0 ? JSON.stringify(message.products.map(productToJson)) : undefined,
    quickReplies: message.quickReplies.length > 0 ? JSON.stringify(message.quickReplies) : undefined,
    timestamp: message.timestamp,
  };
}

export class IdbService {
  private _db: IDBPDatabase | null = null;

  private async db(): Promise<IDBPDatabase> {
    if (!this._db) {
      this._db = await openDB(DB_NAME, DB_VERSION, {
        upgrade(db) {
          const store = db.createObjectStore(STORE_NAME, {
            keyPath: 'id',
            autoIncrement: true,
          });
          store.createIndex('by-timestamp', 'timestamp');
          store.createIndex('by-wiId', 'wiId', { unique: true });
        },
      });
    }
    return this._db;
  }

  /** Inserts a message and returns it with the generated id. */
  async insert(message: ChatMessage): Promise<ChatMessage> {
    const db = await this.db();
    const record = messageToRecord(message);
    delete record.id; // let IDB generate it
    const id = (await db.add(STORE_NAME, record)) as number;
    return { ...message, id };
  }

  /**
   * Replaces an existing message by id.
   * Returns true on success, false if the message has no id.
   */
  async replace(message: ChatMessage): Promise<boolean> {
    if (message.id === undefined) return false;
    const db = await this.db();
    await db.put(STORE_NAME, messageToRecord(message));
    return true;
  }

  /**
   * Cursor-based paginated fetch, descending by id (newest first).
   * cursor = the last seen id; pass undefined for the first page.
   */
  async getPageDesc(cursor: number | undefined, pageSize: number = DEFAULT_PAGE_SIZE): Promise<Page<ChatMessage>> {
    const db = await this.db();
    const tx = db.transaction(STORE_NAME, 'readonly');
    const store = tx.objectStore(STORE_NAME);

    const upperBound = cursor !== undefined ? IDBKeyRange.upperBound(cursor, true) : undefined;
    let cursorObj = await store.openCursor(upperBound, 'prev');

    const data: ChatMessage[] = [];
    let nextCursor: number | undefined;

    while (cursorObj && data.length < pageSize) {
      const record = cursorObj.value as ChatMessageRecord & { id: number };
      data.push(recordToMessage(record));
      cursorObj = await cursorObj.continue();
    }

    if (cursorObj) {
      nextCursor = (cursorObj.value as ChatMessageRecord & { id: number }).id;
    }

    const pageInfo: PageInfo = {
      cursor,
      nextCursor,
      pageSize,
    };

    return { data, pageInfo };
  }

  async close(): Promise<void> {
    this._db?.close();
    this._db = null;
  }
}
