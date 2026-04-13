// Copyright (c) Yalochat, Inc. All rights reserved.

import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { ReactiveController } from 'lit';
import type { ButtonsMessage } from './buttons-message';

export default class ButtonsMessageController implements ReactiveController {
  host: ButtonsMessage;

  constructor(host: ButtonsMessage) {
    this.host = host;
    this.host.addController(this);
  }

  hostConnected() {}

  onButtonClick(text: string) {
    const chatMessage = ChatMessage.text({
      role: 'USER',
      timestamp: new Date(),
      content: text,
    });

    this.host.dispatchEvent(
      new CustomEvent('yalo-chat-send-text-message', {
        detail: chatMessage,
        bubbles: true,
        composed: true,
      })
    );
  }
}
