// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import type { ChatStore } from '@yalo/chat-sdk-core';
import { initialChatState, MessageRole } from '@yalo/chat-sdk-core';
import type { ChatState } from '@yalo/chat-sdk-core';
import './messages/message.js';

@customElement('yalo-message-list')
export class YaloMessageList extends LitElement {
  @property({ attribute: false }) store!: ChatStore;

  @state() private _state: ChatState = initialChatState();
  private _isAtBottom = true;
  private _prevMessageCount = 0;

  private _handler = (e: Event) => {
    const next = (e as CustomEvent<ChatState>).detail;
    const hasNewMessage = next.messages.length > this._prevMessageCount;
    const userJustSent = hasNewMessage && next.messages[0]?.role === MessageRole.User;
    this._prevMessageCount = next.messages.length;
    this._state = next;

    // Scroll to bottom when: user sent a message (always), or a new message
    // arrived and the user was already at the bottom.
    if (userJustSent || (hasNewMessage && this._isAtBottom)) {
      if (userJustSent) this._isAtBottom = true;
      this._scrollToBottom();
    }
  };

  connectedCallback() {
    super.connectedCallback();
    this.store?.addEventListener('change', this._handler);
    // The store may already have messages from the initial load that fired
    // before this element existed. Sync state immediately so they render.
    if (this.store) {
      this._state = this.store.state as ChatState;
      this._prevMessageCount = this._state.messages.length;
    }
  }

  protected firstUpdated(): void {
    // Scroll to bottom after the first render so the newest message is visible.
    requestAnimationFrame(() => {
      const el = this.shadowRoot?.querySelector('.scroll-area');
      if (el) el.scrollTop = el.scrollHeight;
    });
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
      padding: 8px 0;
      scroll-behavior: smooth;
    }
    .messages {
      display: flex;
      flex-direction: column;
      gap: 2px;
      justify-content: flex-end;
      min-height: 100%;
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
    requestAnimationFrame(() => {
      const el = this.shadowRoot?.querySelector('.scroll-area');
      if (el) el.scrollTop = el.scrollHeight;
    });
  }

  private _onScroll(e: Event) {
    const el = e.target as HTMLElement;
    this._isAtBottom = el.scrollHeight - el.scrollTop - el.clientHeight < 80;
    if (el.scrollTop < 40 && this._state.hasMore && !this._state.isLoading) {
      this.store?.loadMessages('next');
    }
  }

  render() {
    // Store keeps messages newest-first; reverse to render oldest→newest top→bottom.
    const messages = [...this._state.messages].reverse();

    return html`
      <div class="scroll-area" @scroll=${this._onScroll}>
        <div class="messages">
          ${this._state.hasMore ? html`
            <div class="load-more">
              <button @click=${() => this.store?.loadMessages('next')}>
                ${this._state.isLoading ? 'Loading…' : 'Load more'}
              </button>
            </div>
          ` : ''}
          ${messages.map((msg) => html`
            <yalo-message .message=${msg} .store=${this.store}></yalo-message>
          `)}
          ${this._state.isSystemTypingMessage ? html`
            <div class="typing">
              <div class="dot"></div>
              <div class="dot"></div>
              <div class="dot"></div>
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
