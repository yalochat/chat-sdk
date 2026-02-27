// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '../../../common/result.js';
import type { Page } from '../../../common/page.js';
import type { ChatMessage } from '../../../domain/chat-message.js';

export interface ChatMessageRepository {
  /**
   * Returns a page of messages sorted descending by id (newest first).
   * @param cursor   Last seen id — pass undefined for the first page
   * @param pageSize Number of messages per page
   */
  getChatMessagePageDesc(cursor: number | undefined, pageSize: number): Promise<Result<Page<ChatMessage>>>;

  /** Inserts a new message and returns it with the generated id. */
  insertChatMessage(message: ChatMessage): Promise<Result<ChatMessage>>;

  /** Replaces an existing message (matched by id). Returns true on success. */
  replaceChatMessage(message: ChatMessage): Promise<Result<boolean>>;
}
