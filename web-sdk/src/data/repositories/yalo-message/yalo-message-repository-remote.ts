// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { TokenRepository } from '@data/repositories/token/token-repository';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type {
  PollCallback,
  YaloMessageRepository,
} from './yalo-message-repository';
import {
  MessageRole,
  MessageStatus,
  type SdkMessage,
  PollMessageItem,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';

interface JwtPayload {
  user_id: string;
}

export class YaloMessageRepositoryRemote implements YaloMessageRepository {
  private readonly _baseUrl: string;
  private readonly _config: YaloChatClientConfig;
  private readonly _tokenRepository: TokenRepository;
  private _pollTimeout?: ReturnType<typeof setTimeout>;
  private _seenIds = new Set<string>();
  private _pollInterval = 2000;

  constructor(
    baseUrl: string,
    config: YaloChatClientConfig,
    tokenRepository: TokenRepository
  ) {
    this._baseUrl = baseUrl;
    this._config = config;
    this._tokenRepository = tokenRepository;
  }

  async insertMessage(message: ChatMessage): Promise<Result<ChatMessage>> {
    const authResult = await this._tokenRepository.getToken();
    if (!authResult.ok) return authResult;

    const token = authResult.value;
    const userId = this._decodeUserId(token);

    try {
      const timestamp = new Date();

      const body: SdkMessage = {
        correlationId: message.id?.toString() || '',
        textMessageRequest: {
          content: {
            timestamp: undefined,
            text: message.content,
            status: MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
            role: MessageRole.MESSAGE_ROLE_USER,
          },
          timestamp: message.timestamp,
        },
        timestamp: timestamp,
      };
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
          body: JSON.stringify(body),
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
      const authResult = await this._tokenRepository.getToken();
      if (!authResult.ok) return;

      const token = authResult.value;
      const userId = this._decodeUserId(token);

      try {
        const params = new URLSearchParams({
          timestamp: String(Math.floor(Date.now() - 5000)),
        });
        const response = await fetch(
          `${this._baseUrl}/webchat/messages?${params}`,
          {
            headers: {
              Authorization: `Bearer ${token}`,
              'x-channel-id': this._config.channelId,
              'x-user-id': userId,
            },
          }
        );

        if (!response.ok) return;

        const data = (await response.json()) as Array<PollMessageItem>;

        const newMessages = data
          .filter(
            (item) =>
              !this._seenIds.has(item.id) &&
              item.message?.textMessageRequest != null
          )
          .map((item) => {
            this._seenIds.add(item.id);
            const { text } = item.message!.textMessageRequest!.content!;
            return new ChatMessage({
              wiId: item.id,
              role: 'AGENT',
              content: text,
              type: 'text',
              status: 'DELIVERED',
              timestamp: item.date ?? new Date(),
            });
          });

        if (newMessages.length > 0) callback(newMessages);
      } catch {
        // swallow network errors — next poll will retry
      }

      this._pollTimeout = setTimeout(poll, this._pollInterval);
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
