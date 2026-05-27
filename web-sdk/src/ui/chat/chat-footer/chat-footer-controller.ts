// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ReactiveController } from 'lit';
import type { ChatFooter } from './chat-footer';
import { ChatMessage } from '@domain/models/chat-message/chat-message';

export class ChatFooterController implements ReactiveController {
  host: ChatFooter;

  constructor(host: ChatFooter) {
    this.host = host;
    this.host.addController(this);
  }

  async sendTextMessage(e: Event) {
    e.preventDefault();
    const value = this.host.input.innerText.trim();
    if (!value) {
      return;
    }
    this.host.input.textContent = '';
    this.host.hasText = false;
    this.host.logger.debug(`sending text message "${value}"`);
    const chatMessageToInsert = ChatMessage.text({
      role: 'USER',
      timestamp: new Date(),
      content: value,
    });

    this.host.dispatchEvent(
      new CustomEvent('yalo-chat-send-text-message', {
        detail: chatMessageToInsert,
        bubbles: true,
        composed: true,
      })
    );
    this.host.requestUpdate();
  }

  handleOnInput() {
    this.host.hasText = (this.host.input.textContent ?? '').length > 0;
    this.host.requestUpdate();
  }

  handleOnKeyDown(e: KeyboardEvent) {
    if (e.key === 'Enter' && !e.shiftKey) {
      this.sendTextMessage(e);
    }
  }

  hostConnected() {}
  hostDisconnected() {}
}
