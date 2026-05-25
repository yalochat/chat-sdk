// Copyright (c) Yalochat, Inc. All rights reserved.

import type { MessageButton } from '@domain/models/chat-message/chat-message';
import { css, html, LitElement, nothing } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import ChatQuickRepliesController from './chat-quick-replies-controller';

@customElement('chat-quick-replies')
export default class ChatQuickReplies extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-quick-replies-gap: 0.5rem;
      --yalo-chat-quick-replies-padding: 0.5rem;
      --yalo-chat-quick-replies-border: 1px solid #e8e8e8;
      --yalo-chat-quick-replies-chip-padding: 0.5rem 0.75rem;
      --yalo-chat-quick-replies-chip-border-color: #9db1c8;
      --yalo-chat-quick-replies-chip-border-radius: 1.125rem;
      --yalo-chat-quick-replies-chip-background: transparent;
      --yalo-chat-quick-replies-chip-color: #111111;
      --yalo-chat-quick-replies-chip-font-size: 0.875rem;
      --yalo-chat-quick-replies-animation-duration: 0.3s;
      display: block;
    }

    .container {
      display: grid;
      grid-template-rows: 0fr;
      transition: grid-template-rows
        var(--yalo-chat-quick-replies-animation-duration) ease;
    }

    .container.open {
      grid-template-rows: 1fr;
    }

    .inner {
      overflow: hidden;
      min-height: 0;
    }

    .chips {
      display: flex;
      flex-wrap: wrap;
      justify-content: flex-start;
      gap: var(--yalo-chat-quick-replies-gap);
      padding: var(--yalo-chat-quick-replies-padding);
      border-top: var(--yalo-chat-quick-replies-border);
    }

    button {
      padding: var(--yalo-chat-quick-replies-chip-padding);
      border: 1px solid var(--yalo-chat-quick-replies-chip-border-color);
      border-radius: var(--yalo-chat-quick-replies-chip-border-radius);
      background: var(--yalo-chat-quick-replies-chip-background);
      color: var(--yalo-chat-quick-replies-chip-color);
      font-size: var(--yalo-chat-quick-replies-chip-font-size);
      cursor: pointer;
      word-break: break-word;
    }

    button:hover {
      background-color: #dde4ec;
    }
  `;

  @property({ attribute: false })
  replies: MessageButton[] = [];

  private _controller = new ChatQuickRepliesController(this);

  render() {
    const isOpen = this.replies.length > 0;
    return html`
      <div class="container ${isOpen ? 'open' : ''}" aria-hidden=${!isOpen}>
        <div class="inner">
          ${isOpen
            ? html`<div class="chips">
                ${this.replies.map(
                  (reply) => html`<button
                    type="button"
                    @click=${() => this._controller.onReplyClick(reply.text)}
                  >
                    ${reply.text}
                  </button>`
                )}
              </div>`
            : nothing}
        </div>
      </div>
    `;
  }
}
