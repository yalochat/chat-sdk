// Copyright (c) Yalochat, Inc. All rights reserved.

import type { Result } from '@domain/common/result';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';

export type PollCallback = (messages: ChatMessage[]) => void;

export abstract class YaloMessageRepository {
  // Inserts a chat message to the inbound messages API
  abstract insertMessage(message: ChatMessage): Promise<Result<ChatMessage>>;

  // Sends an add-to-cart command for the given SKU and quantity
  abstract addToCart(sku: string, quantity: number): Promise<Result<void>>;

  // Sends a remove-from-cart command for the given SKU and optional quantity
  abstract removeFromCart(sku: string, quantity?: number): Promise<Result<void>>;

  // Sends a clear-cart command to remove all items from the cart
  abstract clearCart(): Promise<Result<void>>;

  // Sends an add-promotion command for the given promotion ID
  abstract addPromotion(promotionId: string): Promise<Result<void>>;

  // Polls messages based on timestamp every X seconds and notifies
  // via callback
  abstract subscribeToMessages(callback: PollCallback): void;

  // Unsubscribe from the message polling
  abstract unsubscribeMessages(): void;
}
