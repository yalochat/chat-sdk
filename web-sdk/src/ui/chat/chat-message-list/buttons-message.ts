// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { renderMarkdown } from './render-markdown';
import ButtonsMessageController from './buttons-message-controller';

@customElement('buttons-message')
export class ButtonsMessage extends LitElement {
  private _controller = new ButtonsMessageController(this);

  static styles = css`
    :host {
      --yalo-chat-buttons-footer-color: #7c8086;
      --yalo-chat-buttons-gap: 0.5rem;
      --yalo-chat-buttons-padding: 0.5rem;
      --yalo-chat-buttons-border-radius: 0.5rem;
      --yalo-chat-buttons-background: transparent;
      --yalo-chat-buttons-color: #1111111;
      --yalo-chat-buttons-font-size: 0.875rem;
      display: block;
    }

    .header {
      font-weight: bold;
      margin-bottom: 0.25rem;
    }

    .body {
      margin-bottom: 0.25rem;
      word-break: break-word;
    }

    .footer {
      font-size: 0.75em;
      color: var(--yalo-chat-buttons-footer-color);
      margin-bottom: 0.5rem;
    }

    .buttons {
      display: flex;
      flex-direction: column;
      gap: var(--yalo-chat-buttons-gap);
    }

    .buttons-message {
      display: block;
      padding: var(--yalo-chat-buttons-padding);
    }

    button {
      padding: var(--yalo-chat-buttons-padding);
      border: none;
      border: 1px solid var(--yalo-chat-cta-buttons-border-color);
      border-radius: var(--yalo-chat-buttons-border-radius);
      background: var(--yalo-chat-buttons-background);
      color: var(--yalo-chat-buttons-color);
      cursor: pointer;
      font-size: var(--yalo-chat-buttons-font-size);
      word-break: break-word;
    }

    button:hover {
      background-color: #dde4ec;
    }
  `;

  @property({ attribute: false })
  message!: ChatMessage;

  render() {
    return html`
      <div class="buttons-message">
        ${this.message.header
          ? html`<div class="header">${this.message.header}</div>`
          : null}
        ${this.message.content
          ? html`<div class="body">${renderMarkdown(this.message.content)}</div>`
          : null}
        ${this.message.footer
          ? html`<div class="footer">${this.message.footer}</div>`
          : null}
      </div>
      <div class="buttons">
        ${this.message.buttons.map(
          (text) =>
            html`<button
              type="button"
              @click=${() => this._controller.onButtonClick(text)}
            >
              ${text}
            </button>`
        )}
      </div>
    `;
  }
}
