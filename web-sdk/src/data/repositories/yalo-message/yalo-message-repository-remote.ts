// Copyright (c) Yalochat, Inc. All rights reserved.

import { Err, Ok, type Result } from '@domain/common/result';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
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

export class YaloMessageRepositoryRemote implements YaloMessageRepository {
  private readonly _service: YaloMessageService;
  private readonly _mediaService: YaloMediaService;

  constructor(service: YaloMessageService, mediaService: YaloMediaService) {
    this._service = service;
    this._mediaService = mediaService;
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

  subscribeToMessages(callback: PollCallback): void {
    this._service.subscribe((item: PollMessageItem) => {
      const message = pollMessageItemToChatMessage(item);
      if (message) callback([message]);
    });
  }

  unsubscribeMessages(): void {
    this._service.unsubscribe();
  }
}
