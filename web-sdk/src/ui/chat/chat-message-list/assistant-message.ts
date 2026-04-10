// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';
import snarkdown from 'snarkdown';
import dompurify from 'dompurify';
import './attachment-message';
import './buttons-message';
import './cta-message';
import './image-message';
import './video-message';
import './voice-message';

@customElement('assistant-message')
export class AssistantMessage extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-cta-buttons-border-color: #dde4ec;
      --yalo-chat-link-button-color: #2207f1;
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
      color: var(--yalo-chat-link-button-color);
    }

    .voice-bubble {
      max-width: 90%;
    }

    .image-bubble,
    .video-bubble {
      max-width: 90%;
      border-radius: 1.125rem;
      border-bottom-left-radius: 0.25rem;
      overflow: hidden;
    }

    .attachment-bubble {
      max-width: 90%;
    }

    .buttons-bubble,
    .cta-bubble {
      max-width: 90%;
      border: 1px solid var(--yalo-chat-cta-buttons-border-color);
      border-radius: 1rem;
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
      case 'video':
        return html`<div class="video-bubble">
          <video-message .message=${this.message}></video-message>
        </div>`;
      case 'attachment':
        return html`<div class="attachment-bubble">
          <attachment-message .message=${this.message}></attachment-message>
        </div>`;
      case 'buttons':
        return html`<div class="buttons-bubble">
          <buttons-message .message=${this.message}></buttons-message>
        </div>`;
      case 'cta':
        return html`<div class="cta-bubble">
          <cta-message .message=${this.message}></cta-message>
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
