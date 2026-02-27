// Copyright (c) Yalochat, Inc. All rights reserved.

import { err, ok, type Result } from '../../../common/result.js';
import {
  chatMessageText,
  MessageRole,
  MessageStatus,
  MessageType,
  type ChatMessage,
} from '../../../domain/chat-message.js';
import { typingStart, typingStop, type ChatEvent } from '../../../domain/chat-event.js';
import type { YaloFetchMessagesResponse, YaloTextMessageRequest } from '../../../domain/yalo-message.js';
import type { YaloChatClient } from '../../client/yalo-chat-client.js';
import type { EventCallback, MessageCallback, YaloMessageRepository } from './yalo-message-repository.js';

/** Simple Map-based LRU cache with a maximum capacity. */
class LruCache<K, V> {
  private readonly map = new Map<K, V>();
  constructor(private readonly capacity: number) {}

  get(key: K): V | undefined {
    const value = this.map.get(key);
    if (value !== undefined) {
      // Refresh recency
      this.map.delete(key);
      this.map.set(key, value);
    }
    return value;
  }

  set(key: K, value: V): void {
    if (this.map.has(key)) this.map.delete(key);
    else if (this.map.size >= this.capacity) {
      // Evict oldest
      this.map.delete(this.map.keys().next().value as K);
    }
    this.map.set(key, value);
  }
}

export class YaloMessageRepositoryRemote implements YaloMessageRepository {
  private readonly messageListeners: MessageCallback[] = [];
  private readonly eventListeners: EventCallback[] = [];
  private polling = false;
  private readonly pollingRateMs = 1000;
  private readonly pollingRateWindowSec = 5;
  private readonly cache = new LruCache<string, boolean>(500);

  constructor(private readonly client: YaloChatClient) {}

  onMessage(callback: MessageCallback): () => void {
    this.messageListeners.push(callback);
    if (!this.polling) this._startPolling();
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

  async sendMessage(message: ChatMessage): Promise<Result<void>> {
    if (message.type === MessageType.Text) {
      this._emitEvent(typingStart('Writing message...'));
      const timestampSec = Math.floor(Date.now() / 1000);
      const request: YaloTextMessageRequest = {
        timestamp: timestampSec,
        content: {
          timestamp: Math.floor(message.timestamp / 1000),
          text: message.content,
          status: message.status,
          role: message.role,
        },
      };
      return this.client.sendTextMessage(request);
    }
    return err(new Error('Message type is not supported'));
  }

  async executeActions(): Promise<void> {
    for (const action of this.client.actions) {
      action.action();
    }
  }

  dispose(): void {
    this.polling = false;
  }

  // ── Private ─────────────────────────────────────────────────────────────

  private _emitMessage(message: ChatMessage): void {
    for (const cb of this.messageListeners) cb(message);
  }

  private _emitEvent(event: ChatEvent): void {
    for (const cb of this.eventListeners) cb(event);
  }

  private _translateResponse(item: YaloFetchMessagesResponse): ChatMessage {
    const role = item.message.role === MessageRole.User ? MessageRole.User : MessageRole.Assistant;
    return chatMessageText({
      role,
      timestamp: new Date(item.date).getTime(),
      content: item.message.text,
      wiId: item.id,
      status: MessageStatus.Delivered,
    });
  }

  private async _startPolling(): Promise<void> {
    this.polling = true;
    while (this.polling) {
      const since = Math.floor(Date.now() / 1000) - this.pollingRateWindowSec;
      const result = await this.client.fetchMessages(since);

      if (result.ok) {
        const messages = result.value
          .map((item) => this._translateResponse(item))
          .filter((msg) => {
            if (!msg.wiId || this.cache.get(msg.wiId) !== undefined) return false;
            this.cache.set(msg.wiId, true);
            return true;
          });

        if (messages.length > 0) {
          this._emitEvent(typingStop());
          for (const msg of messages) this._emitMessage(msg);
        }
      } else {
        console.error('Unable to fetch messages since', since, result.error);
        this._emitEvent(typingStop());
      }

      await new Promise<void>((resolve) => setTimeout(resolve, this.pollingRateMs));
    }
  }
}
