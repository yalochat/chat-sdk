// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';
import snarkdown from 'snarkdown';
import dompurify from 'dompurify';
import './image-message';
import './voice-message';

@customElement('assistant-message')
export class AssistantMessage extends LitElement {
  static styles = css`
    :host {
      display: flow;
      justify-content: flex-start;
      margin: 0.25rem 0.5rem;
      padding-left: 0.5rem;
    }

    p {
      margin: 0;
      word-break: break-word;
    }

    a {
      color: var(--yalo-chat-send-btn-background, #2207f1);
    }

    .voice-bubble {
      max-width: 90%;
    }

    .image-bubble {
      max-width: 90%;
      border-radius: 1.125rem;
      border-bottom-left-radius: 0.25rem;
      overflow: hidden;
    }
  `;

  @property({ attribute: false })
  message!: ChatMessage;

  private _highlightLinks(text: string): string {
    return text.replace(/(?<!\]\()https?:\/\/[^\s)]+/g, '[$&]($&)');
  }

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
        return html`<p>
          ${unsafeHTML(
            dompurify.sanitize(
              snarkdown(this._highlightLinks(this.message.content))
            )
          )}
        </p>`;
    }
  }
}
