// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import {
  PollMessageItem,
  SdkMessage,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import type { TokenRepository } from '@data/repositories/token/token-repository';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type {
  MessageCallback,
  YaloMessageService,
} from './yalo-message-service';

interface JwtPayload {
  user_id: string;
}

const POLL_INTERVAL_MS = 2000;
const INITIAL_LOOKBACK_MS = 5000;

export class YaloMessageServiceHttps implements YaloMessageService {
  private readonly _baseUrl: string;
  private readonly _config: YaloChatClientConfig;
  private readonly _tokenRepository: TokenRepository;
  private _callback?: MessageCallback;
  private _pollTimeout?: ReturnType<typeof setTimeout>;
  private _seenIds = new Set<string>();
  private _lastMessageTimestamp?: Date;
  private _visibilityListener?: () => void;

  constructor(
    baseUrl: string,
    config: YaloChatClientConfig,
    tokenRepository: TokenRepository
  ) {
    this._baseUrl = `https://${baseUrl}/v1/channels`;
    this._config = config;
    this._tokenRepository = tokenRepository;
  }

  async sendMessage(message: SdkMessage): Promise<Result<void>> {
    const authResult = await this._tokenRepository.getToken();
    if (!authResult.ok) return authResult;

    const token = authResult.value;
    const userId = this._decodeUserId(token);

    try {
      const response = await fetch(
        `${this._baseUrl}/webchat/inbound_messages`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-channel-id': this._config.channelId,
            'x-user-id': userId,
            authorization: `Bearer ${token}`,
          },
          body: JSON.stringify(SdkMessage.toJSON(message)),
        }
      );

      if (!response.ok) {
        return new Err(new Error(`sendMessage failed: ${response.status}`));
      }

      return new Ok(undefined);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  subscribe(callback: MessageCallback): void {
    this._callback = callback;

    const poll = async () => {
      const authResult = await this._tokenRepository.getToken();
      if (!authResult.ok) return;

      const token = authResult.value;
      const userId = this._decodeUserId(token);

      try {
        const since = Math.floor(
          this._lastMessageTimestamp?.getTime() ??
            Date.now() - INITIAL_LOOKBACK_MS
        );
        const params = new URLSearchParams({ since: String(since) });
        const response = await fetch(
          `${this._baseUrl}/webchat/messages?${params}`,
          {
            method: 'GET',
            headers: {
              authorization: `Bearer ${token}`,
              accept: 'application/json',
              'x-channel-id': this._config.channelId,
              'x-user-id': userId,
            },
          }
        );

        if (!response.ok) return;

        const json = (await response.json()) as Array<unknown>;
        const data = json.map((item) => PollMessageItem.fromJSON(item));

        for (const item of data) {
          if (
            item.date &&
            (!this._lastMessageTimestamp ||
              item.date > this._lastMessageTimestamp)
          ) {
            this._lastMessageTimestamp = item.date;
          }
        }

        for (const item of data) {
          if (this._seenIds.has(item.id) || item.message == null) continue;
          this._seenIds.add(item.id);
          this._callback?.(item);
        }
      } catch {
        // swallow network errors — next poll will retry
      }

      if (!document.hidden) {
        this._pollTimeout = setTimeout(poll, POLL_INTERVAL_MS);
      }
    };

    this._visibilityListener = () => {
      clearTimeout(this._pollTimeout);
      this._pollTimeout = undefined;
      if (!document.hidden) poll();
    };
    document.addEventListener('visibilitychange', this._visibilityListener);

    poll();
  }

  unsubscribe(): void {
    clearTimeout(this._pollTimeout);
    this._pollTimeout = undefined;
    this._seenIds.clear();
    this._lastMessageTimestamp = undefined;
    this._callback = undefined;
    if (this._visibilityListener) {
      document.removeEventListener(
        'visibilitychange',
        this._visibilityListener
      );
      this._visibilityListener = undefined;
    }
  }

  private _decodeUserId(token: string): string {
    const payload = token.split('.')[1];
    const decoded = atob(payload.replace(/-/g, '+').replace(/_/g, '/'));
    return (JSON.parse(decoded) as JwtPayload).user_id;
  }
}
