// Copyright (c) Yalochat, Inc. All rights reserved.

import { ChatMessage } from '@domain/models/chat-message/chat-message';
import type { ReactiveController } from 'lit';
import type ChatQuickReplies from './chat-quick-replies';

export default class ChatQuickRepliesController implements ReactiveController {
  host: ChatQuickReplies;

  constructor(host: ChatQuickReplies) {
    this.host = host;
    this.host.addController(this);
  }

  hostConnected() {}

  onReplyClick(text: string) {
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
}
