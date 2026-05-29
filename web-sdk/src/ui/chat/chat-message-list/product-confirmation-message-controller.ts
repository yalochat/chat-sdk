// Copyright (c) Yalochat, Inc. All rights reserved.

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

  onButtonClick(message: ChatMessage) {
    this.host.dispatchEvent(
      new CustomEvent('yalo-chat-product-confirmation-clicked', {
        detail: message,
        bubbles: true,
        composed: true,
      })
    );
  }
}
