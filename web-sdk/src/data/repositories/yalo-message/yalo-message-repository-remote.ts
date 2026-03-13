// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { YaloMessageAuthService } from '@data/services/yalo-message/yalo-message-auth-service';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type {
  PollCallback,
  YaloMessageRepository,
} from './yalo-message-repository';

interface JwtPayload {
  user_id: string;
}

interface Message {
  id: string;
  message: { text: string; role: string };
  date: string;
  user_id: string;
  status: string;
}

export class YaloMessageRepositoryRemote implements YaloMessageRepository {
  private readonly _baseUrl: string;
  private readonly _config: YaloChatClientConfig;
  private readonly _authService: YaloMessageAuthService;
  private _pollTimeout?: ReturnType<typeof setTimeout>;
  private _seenIds = new Set<string>();

  constructor(
    baseUrl: string,
    config: YaloChatClientConfig,
    authService: YaloMessageAuthService
  ) {
    this._baseUrl = baseUrl;
    this._config = config;
    this._authService = authService;
  }

  async insertMessage(message: ChatMessage): Promise<Result<ChatMessage>> {
    const authResult = await this._authService.auth();
    if (!authResult.ok) return authResult;

    const token = authResult.value;
    const userId = this._decodeUserId(token);

    try {
      const timestamp = Date.now();
      const response = await fetch(
        `${this._baseUrl}/webchat/inbound_messages`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            accept: 'application/json, text/plain, */*',
            'x-channel-id': this._config.channelId,
            'x-user-id': userId,
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({
            content: {
              timestamp,
              text: message.content,
              status: message.status,
              role: message.role,
            },
            timestamp,
          }),
        }
      );

      if (!response.ok) {
        return new Err(new Error(`insertMessage failed: ${response.status}`));
      }

      return new Ok(message);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  subscribeToMessages(callback: PollCallback): void {
    const poll = async () => {
      const authResult = await this._authService.auth();
      if (!authResult.ok) return;

      const token = authResult.value;
      const userId = this._decodeUserId(token);

      try {
        const response = await fetch(`${this._baseUrl}/webchat/messages`, {
          headers: {
            Authorization: `Bearer ${token}`,
            'x-channel-id': this._config.channelId,
            'x-user-id': userId,
          },
        });

        if (!response.ok) return;

        const data = (await response.json()) as Array<Message>;

        const newMessages = data
          .filter((item) => !this._seenIds.has(item.id))
          .map((item) => {
            this._seenIds.add(item.id);
            return new ChatMessage({
              wiId: item.id,
              role: item.message.role as ChatMessage['role'],
              content: item.message.text,
              type: 'text',
              status: 'DELIVERED',
              timestamp: new Date(item.date),
            });
          });

        if (newMessages.length > 0) callback(newMessages);
      } catch {
        // swallow network errors — next poll will retry
      }

      this._pollTimeout = setTimeout(poll, 5000);
    };

    poll();
  }

  unsubscribeMessages(): void {
    clearTimeout(this._pollTimeout);
    this._pollTimeout = undefined;
    this._seenIds.clear();
  }

  private _decodeUserId(token: string): string {
    const payload = token.split('.')[1];
    const decoded = atob(payload.replace(/-/g, '+').replace(/_/g, '/'));
    return (JSON.parse(decoded) as JwtPayload).user_id;
  }
}
