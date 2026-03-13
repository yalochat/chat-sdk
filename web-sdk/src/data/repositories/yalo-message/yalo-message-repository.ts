// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '@domain/common/result';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';

export type PollCallback = (messages: ChatMessage[]) => void;

export abstract class YaloMessageRepository {
  // Inserts a chat message to the inbound messages API
  abstract insertMessage(message: ChatMessage): Promise<Result<ChatMessage>>;

  // Polls messages based on timestamp every X seconds and notifies
  // via callback
  abstract subscribeToMessages(callback: PollCallback): void;

  // Unsubscribe from the message polling
  abstract unsubscribeMessages(): void;
}
