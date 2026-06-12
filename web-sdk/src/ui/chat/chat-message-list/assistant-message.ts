// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import AssistantMessageController from './assistant-message-controller';
import { renderMarkdown } from './render-markdown';
import './attachment-message';
import './image-message';
import './product-confirmation-message';
import './product-message';
import './video-message';
import './voice-message';

@customElement('yalo-chat-assistant-message')
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
      color: var(--yalo-chat-link-button-color, #2207f1);
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
      font-weight: var(--yalo-chat-message-header-font-weight, bold);
      margin-bottom: 0.25rem;
      word-break: break-word;
    }

    .footer {
      color: var(--yalo-chat-message-footer-color, #7c8086);
      font-size: var(--yalo-chat-message-footer-font-size, 0.75em);
      margin-top: 0.25rem;
      word-break: break-word;
    }

    .buttons {
      display: flex;
      flex-direction: column;
      gap: var(--yalo-chat-buttons-gap, 0.5rem);
      margin-top: 0.5rem;
    }

    .buttons button,
    .buttons a {
      padding: var(--yalo-chat-buttons-padding, 0.5rem);
      border: 1px solid var(--yalo-chat-buttons-border-color, #9db1c8);
      border-radius: var(--yalo-chat-buttons-border-radius, 0.5rem);
      background: var(--yalo-chat-buttons-background, transparent);
      color: var(--yalo-chat-buttons-color, #111111);
      font-size: var(--yalo-chat-buttons-font-size, 0.875rem);
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

    .yalo-icon {
      font-size: var(--yalo-chat-assistant-message-icon-font-size, 1rem);
      font-family: var(
        --yalo-chat-icon-font-family,
        'Material Symbols Outlined'
      );
      font-weight: var(--yalo-chat-icon-font-weight, normal);
      line-height: 1;
      font-feature-settings: 'liga';
    }

    .yalo-icon[data-icon='arrow-forward']::before {
      content: var(--yalo-chat-icon-arrow-forward, 'arrow_forward');
    }

    .buttons button:hover,
    .buttons a:hover {
      background-color: var(--yalo-chat-buttons-hover-background, #dde4ec);
    }
  `;

  private _controller = new AssistantMessageController(this);

  @property({ attribute: false })
  message!: ChatMessage;

  @property({ type: Boolean })
  hideQuickReplies: boolean = false;

  render() {
    let body;
    switch (this.message.type) {
      case 'voice':
        body = html`<div class="voice-bubble">
          <yalo-chat-voice-message .message=${this.message}></yalo-chat-voice-message>
        </div>`;
        break;
      case 'image':
        body = html`<div class="image-bubble">
          <yalo-chat-image-message .message=${this.message}></yalo-chat-image-message>
        </div>`;
        break;
      case 'video':
        body = html`<div class="video-bubble">
          <yalo-chat-video-message .message=${this.message}></yalo-chat-video-message>
        </div>`;
        break;
      case 'attachment':
        body = html`<div class="attachment-bubble">
          <yalo-chat-attachment-message .message=${this.message}></yalo-chat-attachment-message>
        </div>`;
        break;
      case 'product':
        body = html`<div class="product-bubble">
          <yalo-chat-product-message
            .message=${this.message}
            direction="vertical"
          ></yalo-chat-product-message>
        </div>`;
        break;
      case 'productCarousel':
        body = html`<div class="product-bubble">
          <yalo-chat-product-message
            .message=${this.message}
            direction="horizontal"
          ></yalo-chat-product-message>
        </div>`;
        break;
      case 'productConfirmation':
        return html`<yalo-chat-product-confirmation-message
          .message=${this.message}
        ></yalo-chat-product-confirmation-message>`;
      case 'text':
      default:
        body = html`<p>${renderMarkdown(this.message.content)}</p>`;
    }

    const buttons = this.hideQuickReplies
      ? this.message.buttons.filter((button) => button.type !== 'reply')
      : this.message.buttons;

    return html`
      ${this.message.header
        ? html`<div class="header">${this.message.header}</div>`
        : null}
      ${body}
      ${this.message.footer
        ? html`<div class="footer">${this.message.footer}</div>`
        : null}
      ${buttons.length > 0
        ? html`<div class="buttons">
            ${buttons.map((button) =>
              button.type === 'link' && button.url
                ? html`<a
                    href=${button.url}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    ${button.text}
                    <span class="arrow">
                      <span
                        class="yalo-icon"
                        data-icon="arrow-forward"
                        aria-hidden="true"
                      ></span>
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
