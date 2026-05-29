// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import {
  UnitType,
  type PollMessageItem,
} from '@domain/models/events/external_channel/in_app/sdk/sdk_message';
import type { ProductUnitType } from '@domain/models/product/product';
import type { YaloMediaService } from '@data/services/yalo-media/yalo-media-service';
import type { YaloMessageService } from '@data/services/yalo-message/yalo-message-service';
import type {
  PollCallback,
  YaloMessageRepository,
} from './yalo-message-repository';
import {
  chatMessageToSdkMessage,
  pollMessageItemToChatMessage,
} from './sdk-message-mapper';

const DEFAULT_CHAT_STATUS_TIMEOUT_MS = 15000;

export class YaloMessageRepositoryRemote implements YaloMessageRepository {
  private readonly _service: YaloMessageService;
  private readonly _mediaService: YaloMediaService;
  private readonly _chatStatusTimeoutMs: number;
  private _chatStatusTimer?: ReturnType<typeof setTimeout>;

  constructor(
    service: YaloMessageService,
    mediaService: YaloMediaService,
    chatStatusTimeoutMs: number = DEFAULT_CHAT_STATUS_TIMEOUT_MS
  ) {
    this._service = service;
    this._mediaService = mediaService;
    this._chatStatusTimeoutMs = chatStatusTimeoutMs;
  }

  async insertMessage(message: ChatMessage): Promise<Result<ChatMessage>> {
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
      const result = await this._service.sendMessage(body);
      if (!result.ok) return result;
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
    const timestamp = new Date();
    return this._service.sendMessage({
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
    });
  }

  async removeFromCart(
    sku: string,
    unitType: ProductUnitType,
    quantity?: number
  ): Promise<Result<void>> {
    const timestamp = new Date();
    return this._service.sendMessage({
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
    });
  }

  async updateCartProduct(
    sku: string,
    units: number,
    subunits?: number
  ): Promise<Result<void>> {
    const timestamp = new Date();
    return this._service.sendMessage({
      correlationId: `update-cart-product-${sku}-${Date.now()}`,
      updateCartProductRequest: {
        sku,
        units,
        subunits,
        timestamp,
      },
      timestamp,
    });
  }

  async clearCart(): Promise<Result<void>> {
    const timestamp = new Date();
    return this._service.sendMessage({
      correlationId: `clear-cart-${Date.now()}`,
      clearCartRequest: { timestamp },
      timestamp,
    });
  }

  async addPromotion(promotionId: string): Promise<Result<void>> {
    const timestamp = new Date();
    return this._service.sendMessage({
      correlationId: `add-promotion-${promotionId}-${Date.now()}`,
      addPromotionRequest: { promotionId, timestamp },
      timestamp,
    });
  }

  async requestGuidanceCard(
    targetId?: string,
    context?: string
  ): Promise<Result<void>> {
    const timestamp = new Date();
    return this._service.sendMessage({
      correlationId: `guidance-card-${Date.now()}`,
      guidanceCardRequest: { timestamp, targetId, context },
      timestamp,
    });
  }

  subscribeToMessages(callback: PollCallback): void {
    this._service.subscribe((item: PollMessageItem) => {
      const message = pollMessageItemToChatMessage(item);
      if (message) {
        this._emit(message, callback);
      }
    });
  }

  unsubscribeMessages(): void {
    this._clearChatStatusTimer();
    this._service.unsubscribe();
  }

  // A non-empty chat-status arms a timer that emits an empty chat-status if
  // the backend goes silent; any subsequent emission cancels it.
  private _emit(message: ChatMessage, callback: PollCallback): void {
    callback([message]);
    this._clearChatStatusTimer();
    if (message.type === 'chat-status' && message.content.length > 0) {
      this._chatStatusTimer = setTimeout(() => {
        callback([ChatMessage.chatStatus({ timestamp: new Date(), content: '' })]);
        this._chatStatusTimer = undefined;
      }, this._chatStatusTimeoutMs);
    }
  }

  private _clearChatStatusTimer(): void {
    if (this._chatStatusTimer !== undefined) {
      clearTimeout(this._chatStatusTimer);
      this._chatStatusTimer = undefined;
    }
  }
}
