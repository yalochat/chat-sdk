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
    const value = this.host.textArea.value.trim();
    if (!value) return;
    this.host.textArea.value = '';
    this.host.textArea.style.height = 'auto';
    this.host.textArea.style.overflowY = 'hidden';
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
    const el = this.host.textArea;
    el.style.overflowY = 'hidden';
    el.style.height = 'auto';
    el.style.height = `${el.scrollHeight}px`;
    const maxHeight = parseFloat(getComputedStyle(el).maxHeight);
    if (el.scrollHeight > maxHeight) {
      el.style.overflowY = 'scroll';
    }
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
