// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '@domain/common/result';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import type {
  CustomCommandInvocation,
  CustomCommandStatus,
} from '@domain/models/command/custom-command';
import type { SdkMessageAck } from '@domain/models/events/external_channel/in_app/sdk/sdk_message';

export type PollCallback = (
  event: ChatMessage[] | SdkMessageAck | CustomCommandInvocation
) => void;

export abstract class YaloMessageRepository {
  // Inserts a chat message to the inbound messages API
  abstract insertMessage(message: ChatMessage): Promise<Result<ChatMessage>>;

  // Sets the absolute cart quantities for the given SKU, replacing whatever
  // was there before.
  abstract updateCartProduct(
    sku: string,
    units: number,
    subunits?: number
  ): Promise<Result<void>>;

  // Sends a clear-cart command to remove all items from the cart
  abstract clearCart(): Promise<Result<void>>;

  // Sends an add-promotion command for the given promotion ID
  abstract addPromotion(promotionId: string): Promise<Result<void>>;

  // Requests guidance cards from the channel for the given target and context
  abstract requestGuidanceCard(
    targetId?: string,
    context?: string
  ): Promise<Result<void>>;

  // Replies to a custom command request from the channel. The correlationId
  // must match the one received on the request so the channel can correlate it.
  abstract sendCustomCommandResponse(
    correlationId: string,
    status: CustomCommandStatus,
    payload: string
  ): Promise<Result<void>>;

  // The callback also receives a CustomCommandInvocation for channel-to-client
  // custom command requests.

  // Subscribes to server events. The callback receives a ChatMessage[] for
  // incoming poll messages and an SdkMessageAck for delivery confirmations
  // of previously-sent client messages (matched by correlation_id).
  abstract subscribeToMessages(callback: PollCallback): void;

  // Unsubscribe from the message stream
  abstract unsubscribeMessages(): void;
}
