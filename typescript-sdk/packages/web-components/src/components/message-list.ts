// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import type { ChatStore } from '@yalo/chat-sdk-core';
import { initialChatState } from '@yalo/chat-sdk-core';
import type { ChatState } from '@yalo/chat-sdk-core';
import './messages/message.js';

@customElement('yalo-message-list')
export class YaloMessageList extends LitElement {
  @property({ attribute: false }) store!: ChatStore;

  @state() private _state: ChatState = initialChatState();

  private _handler = (e: Event) => {
    this._state = (e as CustomEvent<ChatState>).detail;
    this._scrollToBottom();
  };

  connectedCallback() {
    super.connectedCallback();
    this.store?.addEventListener('change', this._handler);
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    this.store?.removeEventListener('change', this._handler);
  }

  static styles = css`
    :host {
      display: flex;
      flex-direction: column;
      flex: 1;
      overflow: hidden;
    }
    .scroll-area {
      flex: 1;
      overflow-y: auto;
      display: flex;
      flex-direction: column-reverse;
      padding: 8px 0;
      scroll-behavior: smooth;
    }
    .messages {
      display: flex;
      flex-direction: column;
      gap: 2px;
    }
    .load-more {
      text-align: center;
      padding: 8px;
    }
    .load-more button {
      background: none;
      border: 1px solid var(--yalo-input-border-color, #E8E8E8);
      border-radius: 16px;
      padding: 6px 16px;
      cursor: pointer;
      font-size: 12px;
      color: var(--yalo-expand-controls-color, #2207F1);
    }
    .typing {
      display: flex;
      gap: 4px;
      padding: 8px 16px;
    }
    .dot {
      width: 8px; height: 8px;
      border-radius: 50%;
      background: var(--yalo-assistant-msg-text-color, #999);
      animation: bounce 1.2s infinite ease-in-out;
    }
    .dot:nth-child(2) { animation-delay: 0.2s; }
    .dot:nth-child(3) { animation-delay: 0.4s; }
    @keyframes bounce {
      0%, 80%, 100% { transform: scale(0.7); opacity: 0.5; }
      40% { transform: scale(1); opacity: 1; }
    }
  `;

  private _scrollToBottom() {
    const el = this.shadowRoot?.querySelector('.scroll-area');
    if (el) el.scrollTop = 0; // column-reverse means top = newest
  }

  private _onScroll(e: Event) {
    const el = e.target as HTMLElement;
    // With column-reverse, scrollTop ~0 means bottom; check if near actual top
    const scrolledUp = el.scrollHeight + el.scrollTop - el.clientHeight < 40;
    if (scrolledUp && this._state.hasMore && !this._state.isLoading) {
      this.store?.loadMessages('next');
    }
  }

  render() {
    const messages = [...this._state.messages];

    return html`
      <div class="scroll-area" @scroll=${this._onScroll}>
        <div class="messages">
          ${this._state.isSystemTypingMessage ? html`
            <div class="typing">
              <div class="dot"></div>
              <div class="dot"></div>
              <div class="dot"></div>
            </div>
          ` : ''}
          ${messages.map((msg) => html`
            <yalo-message .message=${msg} .store=${this.store}></yalo-message>
          `)}
          ${this._state.hasMore ? html`
            <div class="load-more">
              <button @click=${() => this.store?.loadMessages('next')}>
                ${this._state.isLoading ? 'Loading…' : 'Load more'}
              </button>
            </div>
          ` : ''}
        </div>
      </div>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-message-list': YaloMessageList;
  }
}
