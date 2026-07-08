// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import {
  registeredCommandsContext,
  type RegisteredCommands,
} from '@domain/models/command/registered-commands-context';
import { consume } from '@lit/context';
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
      width: fit-content;
      max-width: 100%;
      margin-right: auto;
      gap: var(--yalo-chat-product-confirmation-gap, 0.75rem);
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
      position: relative;
      display: inline-flex;
      align-items: center;
      justify-content: center;
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

    .label {
      position: relative;
      display: inline-flex;
      align-items: center;
    }

    .icon {
      position: absolute;
      right: 100%;
      margin-right: 0.25rem;
      display: inline-flex;
      align-items: center;
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
      animation: footer-reveal 0.3s ease-out;
    }

    @keyframes footer-reveal {
      from {
        opacity: 0;
        transform: translateY(-0.25rem);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
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

  render() {
    const button = this.message.buttons[0];
    const clicked = this.message.status === 'CLICKED';
    const loading = this._pending && !clicked;
    const hasFooterText = (this.message.footer ?? '').trim().length > 0;
    const showsFooter =
      clicked && hasFooterText && this._controller.hasGoToCartCommand();
    return html`
      <div class="card">
        <div class="title">${this.message.header}</div>
        <div class="body">${this.message.content}</div>
        <button
          type="button"
          class="button ${clicked ? 'clicked' : ''} ${loading ? 'loading' : ''}"
          ?disabled=${loading || clicked}
          @click=${this._onButtonClick}
        >
          <span class="label">
            ${clicked
              ? html`<span class="icon">
                  <span
                    class="yalo-icon"
                    data-icon="check"
                    aria-hidden="true"
                  ></span>
                </span>`
              : nothing}
            ${button.text}
          </span>
        </button>
        ${showsFooter
          ? html`<button
              type="button"
              class="footer"
              @click=${this._onGoToCartClick}
            >
              ${this.message.footer}
            </button>`
          : nothing}
      </div>
    `;
  }
}
