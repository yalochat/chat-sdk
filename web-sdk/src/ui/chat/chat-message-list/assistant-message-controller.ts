// Copyright (c) Yalochat, Inc. All rights reserved.

import type { MessageFeedbackChanged } from '@domain/models/chat-events/message-feedback-changed';
import {
  ChatMessage,
  type MessageFeedback,
} from '@domain/models/chat-message/chat-message';
import type { ReactiveController } from 'lit';
import type { AssistantMessage } from './assistant-message';

export default class AssistantMessageController implements ReactiveController {
  host: AssistantMessage;

  constructor(host: AssistantMessage) {
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

  // Picking the rating that is already selected clears it.
  onFeedbackClick(feedback: MessageFeedback) {
    const message = this.host.message;
    const detail: MessageFeedbackChanged = {
      message,
      feedback: message.feedback === feedback ? undefined : feedback,
    };
    this.host.dispatchEvent(
      new CustomEvent('yalo-chat-message-feedback', {
        detail,
        bubbles: true,
        composed: true,
      })
    );
  }
}
