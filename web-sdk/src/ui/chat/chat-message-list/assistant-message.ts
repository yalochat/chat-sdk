// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { consume } from '@lit/context';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';
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

    .buttons button,
    .buttons a {
      padding: var(--yalo-chat-buttons-padding);
      border: 1px solid var(--yalo-chat-buttons-border-color);
      border-radius: var(--yalo-chat-buttons-border-radius);
      background: var(--yalo-chat-buttons-background);
      color: var(--yalo-chat-buttons-color);
      font-size: var(--yalo-chat-buttons-font-size);
      cursor: pointer;
      word-break: break-word;
    }

    .buttons a {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
      text-align: center;
      text-decoration: none;
    }

    .buttons .arrow {
      display: flex;
      align-items: center;
      flex-shrink: 0;
      font-size: 1rem;
    }

    .material-symbols-outlined {
      font-size: 1rem;
      font-family: 'Material Symbols Outlined';
    }

    .buttons button:hover,
    .buttons a:hover {
      background-color: #dde4ec;
    }
  `;

  private _controller = new AssistantMessageController(this);

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @property({ attribute: false })
  message!: ChatMessage;

  render() {
    let body;
    switch (this.message.type) {
      case 'voice':
        body = html`<div class="voice-bubble">
          <voice-message .message=${this.message}></voice-message>
        </div>`;
        break;
      case 'image':
        body = html`<div class="image-bubble">
          <image-message .message=${this.message}></image-message>
        </div>`;
        break;
      case 'video':
        body = html`<div class="video-bubble">
          <video-message .message=${this.message}></video-message>
        </div>`;
        break;
      case 'attachment':
        body = html`<div class="attachment-bubble">
          <attachment-message .message=${this.message}></attachment-message>
        </div>`;
        break;
      case 'product':
        body = html`<div class="product-bubble">
          <product-message
            .message=${this.message}
            direction="vertical"
          ></product-message>
        </div>`;
        break;
      case 'productCarousel':
        body = html`<div class="product-bubble">
          <product-message
            .message=${this.message}
            direction="horizontal"
          ></product-message>
        </div>`;
        break;
      case 'text':
      default:
        body = html`<p>${renderMarkdown(this.message.content)}</p>`;
    }

    return html`
      ${this.message.header
        ? html`<div class="header">${this.message.header}</div>`
        : null}
      ${body}
      ${this.message.footer
        ? html`<div class="footer">${this.message.footer}</div>`
        : null}
      ${this.message.buttons.length > 0
        ? html`<div class="buttons">
            ${this.message.buttons.map((button) =>
              button.type === 'link' && button.url
                ? html`<a
                    href=${button.url}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    ${button.text}
                    <span class="arrow">
                      ${unsafeHTML(this.config.icons?.arrowForward)}
                    </span>
                  </a>`
                : html`<button
                    type="button"
                    @click=${() => this._controller.onReplyClick(button.text)}
                  >
                    ${button.text}
                  </button>`
            )}
          </div>`
        : null}
    `;
  }
}
