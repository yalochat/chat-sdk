// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Page } from '@domain/common/page';
import type { Result } from '@domain/common/result';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';

export interface ChatMessageRepository {
  // Returns a page of messages in descending order. Pass null cursor for the first page;
  // subsequent calls should use the nextCursor from the returned PageInfo.
  getChatMessagePageDesc(
    cursor: number | null,
    pageSize: number
  ): Promise<Result<Page<ChatMessage>>>;

  // Inserts a message and returns it with the assigned id.
  insertChatMessage(message: ChatMessage): Promise<Result<ChatMessage>>;

  // Replaces an existing message by id.
  replaceChatMessage(message: ChatMessage): Promise<Result<boolean>>;
}
