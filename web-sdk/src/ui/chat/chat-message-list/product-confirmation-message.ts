// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { consume } from '@lit/context';
import { css, html, LitElement, nothing } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';
import ProductConfirmationMessageController from './product-confirmation-message-controller';

@customElement('yalo-chat-product-confirmation-message')
export class ProductConfirmationMessage extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-product-confirmation-background: #ffffff;
      --yalo-chat-product-confirmation-border-color: #dde4ec;
      --yalo-chat-product-confirmation-border-radius: 1rem;
      --yalo-chat-product-confirmation-box-shadow: 0 4.396px 8px 0
        rgba(0, 0, 0, 0.06);
      --yalo-chat-product-confirmation-padding: 1rem;
      --yalo-chat-product-confirmation-gap: 0.75rem;
      --yalo-chat-product-confirmation-title-color: #111111;
      --yalo-chat-product-confirmation-title-font-weight: bold;
      --yalo-chat-product-confirmation-body-color: #111111;
      --yalo-chat-product-confirmation-button-background: #111111;
      --yalo-chat-product-confirmation-button-color: #ffffff;
      --yalo-chat-product-confirmation-button-background-clicked: #0b996d;
      --yalo-chat-product-confirmation-button-color-clicked: #ffffff;
      --yalo-chat-product-confirmation-button-border: none;
      --yalo-chat-product-confirmation-button-border-radius: 0.5rem;
      --yalo-chat-product-confirmation-button-padding: 0.5rem;
      --yalo-chat-product-confirmation-button-font-size: 0.875rem;
      --yalo-chat-product-confirmation-footer-color: #444444;
      --yalo-chat-product-confirmation-footer-font-size: 0.875rem;
      --yalo-chat-product-confirmation-icon-font-size: 1rem;
      display: block;
      width: 100%;
    }

    .card {
      display: flex;
      flex-direction: column;
      gap: var(--yalo-chat-product-confirmation-gap);
      padding: var(--yalo-chat-product-confirmation-padding);
      background: var(--yalo-chat-product-confirmation-background);
      border: 1px solid var(--yalo-chat-product-confirmation-border-color);
      border-radius: var(--yalo-chat-product-confirmation-border-radius);
      box-shadow: var(--yalo-chat-product-confirmation-box-shadow);
      box-sizing: border-box;
    }

    .title {
      color: var(--yalo-chat-product-confirmation-title-color);
      font-weight: var(--yalo-chat-product-confirmation-title-font-weight);
      word-break: break-word;
    }

    .body {
      color: var(--yalo-chat-product-confirmation-body-color);
      word-break: break-word;
    }

    .button {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.25rem;
      padding: var(--yalo-chat-product-confirmation-button-padding);
      border: var(--yalo-chat-product-confirmation-button-border);
      border-radius: var(--yalo-chat-product-confirmation-button-border-radius);
      background: var(--yalo-chat-product-confirmation-button-background);
      color: var(--yalo-chat-product-confirmation-button-color);
      font-size: var(--yalo-chat-product-confirmation-button-font-size);
      cursor: pointer;
      word-break: break-word;
    }

    .button.clicked {
      background: var(
        --yalo-chat-product-confirmation-button-background-clicked
      );
      color: var(--yalo-chat-product-confirmation-button-color-clicked);
      cursor: default;
    }

    .material-symbols-outlined {
      font-size: var(--yalo-chat-product-confirmation-icon-font-size);
      font-family: 'Material Symbols Outlined';
    }

    .footer {
      align-self: center;
      background: none;
      border: none;
      padding: 0;
      color: var(--yalo-chat-product-confirmation-footer-color);
      font-size: var(--yalo-chat-product-confirmation-footer-font-size);
      text-decoration: underline;
      cursor: pointer;
      word-break: break-word;
    }
  `;

  private _controller = new ProductConfirmationMessageController(this);

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @property({ attribute: false })
  message!: ChatMessage;

  @state()
  private _clicked = false;

  private _onButtonClick = () => {
    this._clicked = true;
    this._controller.onButtonClick(this.message);
  };

  private _onFooterClick = () => {
    this._controller.onFooterClick(this.message.footer ?? '');
  };

  render() {
    const button = this.message.buttons[0];
    const clicked = this._clicked || this.message.status === 'CLICKED';
    return html`
      <div class="card">
        <div class="title">${this.message.header}</div>
        <div class="body">${this.message.content}</div>
        <button
          type="button"
          class="button ${clicked ? 'clicked' : ''}"
          ?disabled=${clicked}
          @click=${this._onButtonClick}
        >
          ${clicked
            ? html`<span class="icon"
                >${unsafeHTML(this.config.icons?.check)}</span
              >`
            : nothing}
          ${button.text}
        </button>
        <button type="button" class="footer" @click=${this._onFooterClick}>
          ${this.message.footer}
        </button>
      </div>
    `;
  }
}
