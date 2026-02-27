// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('yalo-chat-app-bar')
export class YaloChatAppBar extends LitElement {
  @property({ type: String }) title = '';
  @property({ type: Boolean }) showShopButton = false;
  @property({ type: Boolean }) showCartButton = false;
  @property({ type: String }) chatIconUrl = '';
  @property({ type: Boolean }) isTyping = false;
  @property({ type: String }) typingText = '';

  static styles = css`
    :host {
      display: block;
      background: var(--yalo-app-bar-bg-color, #F1F5FC);
      height: 64px;
    }
    .bar {
      display: flex;
      align-items: center;
      height: 100%;
      padding: 0 16px;
      gap: 12px;
    }
    .avatar {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      object-fit: cover;
      background: var(--yalo-user-msg-color, #F9FAFC);
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }
    .avatar img { width: 100%; height: 100%; object-fit: cover; }
    .title-area { flex: 1; display: flex; flex-direction: column; }
    .title {
      font-size: 16px;
      font-weight: 600;
      color: var(--yalo-modal-header-color, #010101);
    }
    .typing {
      font-size: 12px;
      color: var(--yalo-timer-text-color, #7C8086);
    }
    .actions { display: flex; gap: 4px; }
    button {
      background: none;
      border: none;
      cursor: pointer;
      font-size: 20px;
      color: var(--yalo-action-icon-color, #000);
      width: 40px;
      height: 40px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    button:hover { background: rgba(0,0,0,0.06); }
  `;

  render() {
    return html`
      <div class="bar">
        <div class="avatar">
          ${this.chatIconUrl
            ? html`<img src="${this.chatIconUrl}" alt="" />`
            : html`💬`}
        </div>
        <div class="title-area">
          <span class="title">${this.title}</span>
          ${this.isTyping ? html`<span class="typing">${this.typingText || 'Typing…'}</span>` : ''}
        </div>
        <div class="actions">
          ${this.showShopButton ? html`
            <button aria-label="shop"
              @click=${() => this.dispatchEvent(new CustomEvent('shop-pressed', { bubbles: true, composed: true }))}>
              🏪
            </button>` : ''}
          ${this.showCartButton ? html`
            <button aria-label="cart"
              @click=${() => this.dispatchEvent(new CustomEvent('cart-pressed', { bubbles: true, composed: true }))}>
              🛒
            </button>` : ''}
        </div>
      </div>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-chat-app-bar': YaloChatAppBar;
  }
}
