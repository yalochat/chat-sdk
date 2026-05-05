// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import AssistantMessageController from './assistant-message-controller';
import { renderMarkdown } from './render-markdown';
import './attachment-message';
import './image-message';
import './product-message';
import './video-message';
import './voice-message';

@customElement('assistant-message')
export class AssistantMessage extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-link-button-color: #2207f1;
      --yalo-chat-message-header-font-weight: bold;
      --yalo-chat-message-footer-color: #7c8086;
      --yalo-chat-message-footer-font-size: 0.75em;
      --yalo-chat-buttons-border-color: #9db1c8;
      --yalo-chat-buttons-gap: 0.5rem;
      --yalo-chat-buttons-padding: 0.5rem;
      --yalo-chat-buttons-border-radius: 0.5rem;
      --yalo-chat-buttons-background: transparent;
      --yalo-chat-buttons-color: #111111;
      --yalo-chat-buttons-font-size: 0.875rem;
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

    .product-bubble {
      width: 100%;
      max-width: 100%;
    }

    .header {
      font-weight: var(--yalo-chat-message-header-font-weight);
      margin-bottom: 0.25rem;
      word-break: break-word;
    }

    .footer {
      color: var(--yalo-chat-message-footer-color);
      font-size: var(--yalo-chat-message-footer-font-size);
      margin-top: 0.25rem;
      word-break: break-word;
    }

    .buttons {
      display: flex;
      flex-direction: column;
      gap: var(--yalo-chat-buttons-gap);
      margin-top: 0.5rem;
    }

    .buttons button {
      padding: var(--yalo-chat-buttons-padding);
      border: 1px solid var(--yalo-chat-buttons-border-color);
      border-radius: var(--yalo-chat-buttons-border-radius);
      background: var(--yalo-chat-buttons-background);
      color: var(--yalo-chat-buttons-color);
      font-size: var(--yalo-chat-buttons-font-size);
      cursor: pointer;
      word-break: break-word;
    }

    .buttons button:hover {
      background-color: #dde4ec;
    }
  `;

  private _controller = new AssistantMessageController(this);

  @property({ attribute: false })
  message!: ChatMessage;

  render() {
    return html`
      ${this.message.header
        ? html`<div class="header">${this.message.header}</div>`
        : null}
      ${this.renderBody()}
      ${this.message.footer
        ? html`<div class="footer">${this.message.footer}</div>`
        : null}
      ${this.message.buttons.length > 0
        ? html`<div class="buttons">
            ${this.message.buttons.map(
              (text) =>
                html`<button
                  type="button"
                  @click=${() => this._controller.onButtonClick(text)}
                >
                  ${text}
                </button>`
            )}
          </div>`
        : null}
    `;
  }

  private renderBody() {
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
      case 'product':
        return html`<div class="product-bubble">
          <product-message
            .message=${this.message}
            direction="vertical"
          ></product-message>
        </div>`;
      case 'productCarousel':
        return html`<div class="product-bubble">
          <product-message
            .message=${this.message}
            direction="horizontal"
          ></product-message>
        </div>`;
      case 'text':
      default:
        return html`<p>${renderMarkdown(this.message.content)}</p>`;
    }
  }
}
