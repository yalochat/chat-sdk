// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { TokenRepository } from '@data/repositories/token/token-repository';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import type {
  PollCallback,
  YaloMessageRepository,
} from './yalo-message-repository';
import {
  PollMessageItem,
  SdkMessage,
  UnitType,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import type { ProductUnitType } from '@domain/models/product/product';
import type { YaloMediaService } from '@data/services/yalo-media/yalo-media-service';
import {
  chatMessageToSdkMessage,
  pollMessageItemToChatMessage,
} from './sdk-message-mapper';

interface JwtPayload {
  user_id: string;
}

export class YaloMessageRepositoryRemote implements YaloMessageRepository {
  private readonly _baseUrl: string;
  private readonly _config: YaloChatClientConfig;
  private readonly _tokenRepository: TokenRepository;
  private readonly _mediaService: YaloMediaService;
  private _pollTimeout?: ReturnType<typeof setTimeout>;
  private _seenIds = new Set<string>();
  private _lastMessageTimestamp?: Date;
  private _pollInterval = 2000;
  private _visibilityListener?: () => void;

  constructor(
    baseUrl: string,
    config: YaloChatClientConfig,
    tokenRepository: TokenRepository,
    mediaService: YaloMediaService
  ) {
    this._baseUrl = `https://${baseUrl}/v1/channels`;
    this._config = config;
    this._tokenRepository = tokenRepository;
    this._mediaService = mediaService;
  }

  async insertMessage(message: ChatMessage): Promise<Result<ChatMessage>> {
    const authResult = await this._tokenRepository.getToken();
    if (!authResult.ok) return authResult;

    const token = authResult.value;
    const userId = this._decodeUserId(token);

    try {
      let mediaId: string | undefined;
      if (
        (message.type === 'image' ||
          message.type === 'voice' ||
          message.type === 'video' ||
          message.type === 'attachment') &&
        message.blob
      ) {
        const file = new File(
          [message.blob],
          message.fileName ?? `media-${Date.now()}`,
          { type: message.mediaType ?? message.blob.type }
        );
        const uploadResult = await this._mediaService.uploadMedia(file);
        if (!uploadResult.ok) return uploadResult;
        mediaId = uploadResult.value.id;
      }

      const body = chatMessageToSdkMessage(message, mediaId);
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
          body: JSON.stringify(SdkMessage.toJSON(body)),
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

  async addToCart(
    sku: string,
    unitType: ProductUnitType,
    quantity: number
  ): Promise<Result<void>> {
    const authResult = await this._tokenRepository.getToken();
    if (!authResult.ok) return authResult;

    const token = authResult.value;
    const userId = this._decodeUserId(token);
    const timestamp = new Date();

    try {
      const body: SdkMessage = {
        correlationId: `add-to-cart-${sku}-${Date.now()}`,
        addToCartRequest: {
          sku,
          quantity,
          timestamp,
          unitType:
            unitType === 'unit'
              ? UnitType.UNIT_TYPE_UNIT
              : UnitType.UNIT_TYPE_SUBUNIT,
        },
        timestamp,
      };

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
          body: JSON.stringify(SdkMessage.toJSON(body)),
        }
      );

      if (!response.ok) {
        return new Err(new Error(`addToCart failed: ${response.status}`));
      }

      return new Ok(undefined);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  async removeFromCart(
    sku: string,
    unitType: ProductUnitType,
    quantity?: number
  ): Promise<Result<void>> {
    const authResult = await this._tokenRepository.getToken();
    if (!authResult.ok) return authResult;

    const token = authResult.value;
    const userId = this._decodeUserId(token);
    const timestamp = new Date();

    try {
      const body: SdkMessage = {
        correlationId: `remove-from-cart-${sku}-${Date.now()}`,
        removeFromCartRequest: {
          sku,
          quantity,
          timestamp,
          unitType:
            unitType === 'unit'
              ? UnitType.UNIT_TYPE_UNIT
              : UnitType.UNIT_TYPE_SUBUNIT,
        },
        timestamp,
      };

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
          body: JSON.stringify(SdkMessage.toJSON(body)),
        }
      );

      if (!response.ok) {
        return new Err(
          new Error(`removeFromCart failed: ${response.status}`)
        );
      }

      return new Ok(undefined);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  async clearCart(): Promise<Result<void>> {
    const authResult = await this._tokenRepository.getToken();
    if (!authResult.ok) return authResult;

    const token = authResult.value;
    const userId = this._decodeUserId(token);
    const timestamp = new Date();

    try {
      const body: SdkMessage = {
        correlationId: `clear-cart-${Date.now()}`,
        clearCartRequest: { timestamp },
        timestamp,
      };

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
          body: JSON.stringify(SdkMessage.toJSON(body)),
        }
      );

      if (!response.ok) {
        return new Err(new Error(`clearCart failed: ${response.status}`));
      }

      return new Ok(undefined);
    } catch (e) {
      return new Err(e instanceof Error ? e : new Error(String(e)));
    }
  }

  async addPromotion(promotionId: string): Promise<Result<void>> {
    const authResult = await this._tokenRepository.getToken();
    if (!authResult.ok) return authResult;

    const token = authResult.value;
    const userId = this._decodeUserId(token);
    const timestamp = new Date();

    try {
      const body: SdkMessage = {
        correlationId: `add-promotion-${promotionId}-${Date.now()}`,
        addPromotionRequest: { promotionId, timestamp },
        timestamp,
      };

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
          body: JSON.stringify(SdkMessage.toJSON(body)),
        }
      );

      if (!response.ok) {
        return new Err(
          new Error(`addPromotion failed: ${response.status}`)
        );
      }

      return new Ok(undefined);
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
        const since = Math.floor(
          this._lastMessageTimestamp?.getTime() ?? Date.now() - 5000
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

        const newMessages = data
          .filter((item) => !this._seenIds.has(item.id) && item.message != null)
          .map((item) => {
            this._seenIds.add(item.id);
            return pollMessageItemToChatMessage(item);
          })
          .filter((msg): msg is ChatMessage => msg !== null);

        if (newMessages.length > 0) callback(newMessages);
      } catch {
        // swallow network errors — next poll will retry
      }

      if (!document.hidden) {
        this._pollTimeout = setTimeout(poll, this._pollInterval);
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

  unsubscribeMessages(): void {
    clearTimeout(this._pollTimeout);
    this._pollTimeout = undefined;
    this._seenIds.clear();
    this._lastMessageTimestamp = undefined;
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
