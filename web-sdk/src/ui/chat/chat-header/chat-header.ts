// Copyright (c) Yalochat, Inc. All rights reserved.

import { css, html, LitElement } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('chat-header')
export class ChatHeader extends LitElement {
  static styles = css`
    .chat-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 12px 16px;
      background: #6200ea;
      color: #fff;
    }

    .chat-header-title {
      font-size: 16px;
      font-weight: 600;
      margin: 0;
    }

    .chat-close-btn {
      background: none;
      border: none;
      color: #fff;
      cursor: pointer;
      padding: 4px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 4px;
      line-height: 1;
      font-size: 20px;
    }

    .chat-close-btn:hover {
      background: rgba(255, 255, 255, 0.15);
    }
  `;

  @property()
  handleClose?: () => void;

  render() {
    return html`
      <header class="chat-header">
        <span class="chat-header-title">Chat</span>
        <button class="chat-close-btn" aria-label="Chat" @click=${this.handleClose}>&#x2715;</button>
      </header>
    `;
  }
}
