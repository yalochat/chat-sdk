// Copyright (c) Yalochat, Inc. All rights reserved.

import { err, ok, type Result } from '../../../common/result.js';
import type { Page } from '../../../common/page.js';
import type { ChatMessage } from '../../../domain/chat-message.js';
import type { IdbService } from '../../services/database/idb-service.js';
import type { ChatMessageRepository } from './chat-message-repository.js';

export class ChatMessageRepositoryIdb implements ChatMessageRepository {
  constructor(private readonly idb: IdbService) {}

  async getChatMessagePageDesc(
    cursor: number | undefined,
    pageSize: number,
  ): Promise<Result<Page<ChatMessage>>> {
    try {
      const page = await this.idb.getPageDesc(cursor, pageSize);
      return ok(page);
    } catch (e) {
      return err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  async insertChatMessage(message: ChatMessage): Promise<Result<ChatMessage>> {
    try {
      const inserted = await this.idb.insert(message);
      return ok(inserted);
    } catch (e) {
      return err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  async replaceChatMessage(message: ChatMessage): Promise<Result<boolean>> {
    try {
      const success = await this.idb.replace(message);
      return ok(success);
    } catch (e) {
      return err(e instanceof Error ? e : new Error(String(e)));
    }
  }
}
