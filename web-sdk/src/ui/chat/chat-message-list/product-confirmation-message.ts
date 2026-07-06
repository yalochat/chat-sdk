// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import {
  registeredCommandsContext,
  type RegisteredCommands,
} from '@domain/models/command/registered-commands-context';
import { consume } from '@lit/context';
import { msg } from '@lit/localize';
import { css, html, LitElement, nothing } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import ProductConfirmationMessageController from './product-confirmation-message-controller';

@customElement('yalo-chat-product-confirmation-message')
export class ProductConfirmationMessage extends LitElement {
  static styles = css`
    :host {
      display: block;
      width: 100%;
    }

    .card {
      display: flex;
      flex-direction: column;
      gap: var(--yalo-chat-product-confirmation-gap, 0.75rem);
      padding: var(--yalo-chat-product-confirmation-padding, 1rem);
      background: var(--yalo-chat-product-confirmation-background, #ffffff);
      border: 1px solid
        var(--yalo-chat-product-confirmation-border-color, #dde4ec);
      border-radius: var(--yalo-chat-product-confirmation-border-radius, 1rem);
      box-shadow: var(
        --yalo-chat-product-confirmation-box-shadow,
        0 4.396px 8px 0 rgba(0, 0, 0, 0.06)
      );
      box-sizing: border-box;
    }

    .title {
      color: var(--yalo-chat-product-confirmation-title-color, #111111);
      font-weight: var(
        --yalo-chat-product-confirmation-title-font-weight,
        bold
      );
      word-break: break-word;
    }

    .body {
      color: var(--yalo-chat-product-confirmation-body-color, #111111);
      word-break: break-word;
    }

    .button {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.25rem;
      padding: var(--yalo-chat-product-confirmation-button-padding, 0.5rem);
      border: var(--yalo-chat-product-confirmation-button-border, none);
      border-radius: var(
        --yalo-chat-product-confirmation-button-border-radius,
        0.5rem
      );
      background: var(
        --yalo-chat-product-confirmation-button-background,
        #111111
      );
      color: var(--yalo-chat-product-confirmation-button-color, #ffffff);
      font-size: var(
        --yalo-chat-product-confirmation-button-font-size,
        0.875rem
      );
      cursor: pointer;
      word-break: break-word;
    }

    .button.clicked {
      background: var(
        --yalo-chat-product-confirmation-button-background-clicked,
        #0b996d
      );
      color: var(
        --yalo-chat-product-confirmation-button-color-clicked,
        #ffffff
      );
    }

    .button:disabled {
      cursor: default;
    }

    .button.loading {
      filter: grayscale(1);
      animation: loading-pulse 1.2s ease-in-out infinite;
    }

    @keyframes loading-pulse {
      0%,
      100% {
        opacity: 0.75;
      }
      50% {
        opacity: 0.45;
      }
    }

    .yalo-icon {
      font-size: var(--yalo-chat-product-confirmation-icon-font-size, 1rem);
      font-family: var(
        --yalo-chat-icon-font-family,
        'Material Symbols Outlined'
      );
      font-weight: var(--yalo-chat-icon-font-weight, normal);
      line-height: 1;
      font-feature-settings: 'liga';
    }

    .yalo-icon[data-icon='check']::before {
      content: var(--yalo-chat-icon-check, 'check');
    }

    .footer {
      align-self: center;
      background: none;
      border: none;
      padding: 0;
      color: var(--yalo-chat-product-confirmation-footer-color, #444444);
      font-size: var(
        --yalo-chat-product-confirmation-footer-font-size,
        0.875rem
      );
      text-decoration: underline;
      cursor: pointer;
      word-break: break-word;
    }
  `;

  private _controller = new ProductConfirmationMessageController(this);

  @property({ attribute: false })
  message!: ChatMessage;

  @consume({ context: registeredCommandsContext, subscribe: true })
  commands?: RegisteredCommands;

  @state()
  private _pending = false;

  private _onButtonClick = async () => {
    this._pending = true;
    try {
      await this._controller.onButtonClick(this.message);
    } finally {
      this._pending = false;
    }
  };

  private _onGoToCartClick = () => {
    this._controller.onGoToCartClick();
  };

  private _onFooterClick = () => {
    this._controller.onFooterClick(this.message.footer ?? '');
  };

  render() {
    const button = this.message.buttons[0];
    const clicked = this.message.status === 'CLICKED';
    const loading = this._pending && !clicked;
    const showsGoToCart = clicked && this._controller.hasGoToCartCommand();
    return html`
      <div class="card">
        <div class="title">${this.message.header}</div>
        <div class="body">${this.message.content}</div>
        <button
          type="button"
          class="button ${clicked ? 'clicked' : ''} ${loading ? 'loading' : ''}"
          ?disabled=${loading || (clicked && !showsGoToCart)}
          @click=${showsGoToCart ? this._onGoToCartClick : this._onButtonClick}
        >
          ${clicked
            ? html`<span class="icon">
                <span
                  class="yalo-icon"
                  data-icon="check"
                  aria-hidden="true"
                ></span>
              </span>`
            : nothing}
          ${showsGoToCart ? msg('Go to cart') : button.text}
        </button>
        <button type="button" class="footer" @click=${this._onFooterClick}>
          ${this.message.footer}
        </button>
      </div>
    `;
  }
}
