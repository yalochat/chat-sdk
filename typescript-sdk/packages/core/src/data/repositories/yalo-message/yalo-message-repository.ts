// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '../../../common/result.js';
import type { ChatMessage } from '../../../domain/chat-message.js';
import type { ChatEvent } from '../../../domain/chat-event.js';

export type MessageCallback = (message: ChatMessage) => void;
export type EventCallback = (event: ChatEvent) => void;

export interface YaloMessageRepository {
  /**
   * Subscribe to incoming assistant messages.
   * Returns an unsubscribe function.
   */
  onMessage(callback: MessageCallback): () => void;

  /**
   * Subscribe to chat events (typing start/stop).
   * Returns an unsubscribe function.
   */
  onEvent(callback: EventCallback): () => void;

  /** Send an outgoing message. */
  sendMessage(message: ChatMessage): Promise<Result<void>>;

  /** Execute all registered client actions. */
  executeActions(): Promise<void>;

  /** Stop polling / clean up resources. */
  dispose(): void;
}
