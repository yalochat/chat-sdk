// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import './image-message';
import './voice-message';

@customElement('user-message')
export class UserMessage extends LitElement {
  static styles = css`
    :host {
      display: flex;
      justify-content: flex-end;
      margin: 0.25rem 0.5rem;
      width: 100%;
    }

    .bubble {
      max-width: 80%;
      padding: 0.5rem 0.75rem;
      border-radius: 1.125rem;
      border-bottom-right-radius: 0.25rem;
      background: var(--yalo-chat-user-message-background, #f9fafc);
      word-break: break-word;
    }

    .voice-bubble {
      width: 60%;
      padding: 0.5rem 0.75rem;
      border-radius: 1.125rem;
      border-bottom-right-radius: 0.25rem;
      background: var(--yalo-chat-user-message-background, #f9fafc);
    }

    .image-bubble {
      max-width: 80%;
      border-radius: 1.125rem;
      border-bottom-right-radius: 0.25rem;
      overflow: hidden;
    }
  `;

  @property({ attribute: false })
  message!: ChatMessage;

  render() {
    switch (this.message.type) {
      case 'voice':
        return html`<div class="voice-bubble">
          <voice-message .message=${this.message}></voice-message>
        </div>`;
      case 'image':
        return html`<div class="image-bubble">
          <image-message .message=${this.message}></image-message>
        </div>`;
      case 'text':
      default:
        return html`<span class="bubble">${this.message.content}</span>`;
    }
  }
}
