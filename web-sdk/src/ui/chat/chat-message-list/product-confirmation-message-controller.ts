// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ProductConfirmationClicked } from '@domain/models/chat-events/product-confirmation-clicked';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { ReactiveController } from 'lit';
import type { ProductConfirmationMessage } from './product-confirmation-message';

export default class ProductConfirmationMessageController
  implements ReactiveController
{
  host: ProductConfirmationMessage;

  constructor(host: ProductConfirmationMessage) {
    this.host = host;
    this.host.addController(this);
  }

  hostConnected() {}

  onFooterClick(text: string) {
    this.host.dispatchEvent(
      new CustomEvent('yalo-chat-send-text-message', {
        detail: ChatMessage.text({
          role: 'USER',
          timestamp: new Date(),
          content: text,
        }),
        bubbles: true,
        composed: true,
      })
    );
  }

  // Resolves once the confirmation settles: the handler assigns `completed`
  // to the detail while the event is dispatched. Resolves to false when no
  // handler picked the event up.
  onButtonClick(message: ChatMessage): Promise<boolean> {
    const detail: ProductConfirmationClicked = { message };
    this.host.dispatchEvent(
      new CustomEvent('yalo-chat-product-confirmation-clicked', {
        detail,
        bubbles: true,
        composed: true,
      })
    );
    return detail.completed ?? Promise.resolve(false);
  }

  hasGoToCartCommand(): boolean {
    return this.host.commands?.has('goToCart') ?? false;
  }

  onGoToCartClick() {
    this.host.dispatchEvent(
      new CustomEvent('yalo-chat-go-to-cart', {
        bubbles: true,
        composed: true,
      })
    );
  }
}
