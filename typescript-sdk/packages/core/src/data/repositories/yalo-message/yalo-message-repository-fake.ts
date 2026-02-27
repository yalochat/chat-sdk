// Copyright (c) Yalochat, Inc. All rights reserved.

import { ok, type Result } from '../../../common/result.js';
import type { ChatMessage } from '../../../domain/chat-message.js';
import type { ChatEvent } from '../../../domain/chat-event.js';
import type { EventCallback, MessageCallback, YaloMessageRepository } from './yalo-message-repository.js';

/** In-memory stub for use in tests and development without a real backend. */
export class YaloMessageRepositoryFake implements YaloMessageRepository {
  private readonly messageListeners: MessageCallback[] = [];
  private readonly eventListeners: EventCallback[] = [];

  /** Simulate an incoming message (call from tests). */
  simulateMessage(message: ChatMessage): void {
    for (const cb of this.messageListeners) cb(message);
  }

  /** Simulate a chat event (call from tests). */
  simulateEvent(event: ChatEvent): void {
    for (const cb of this.eventListeners) cb(event);
  }

  onMessage(callback: MessageCallback): () => void {
    this.messageListeners.push(callback);
    return () => {
      const idx = this.messageListeners.indexOf(callback);
      if (idx !== -1) this.messageListeners.splice(idx, 1);
    };
  }

  onEvent(callback: EventCallback): () => void {
    this.eventListeners.push(callback);
    return () => {
      const idx = this.eventListeners.indexOf(callback);
      if (idx !== -1) this.eventListeners.splice(idx, 1);
    };
  }

  async sendMessage(_message: ChatMessage): Promise<Result<void>> {
    return ok(undefined);
  }

  async executeActions(): Promise<void> {
    // no-op
  }

  dispose(): void {
    // no-op
  }
}
