// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { MessageRole, MessageType, type ChatMessage } from '@yalo/chat-sdk-core';
import type { ChatStore } from '@yalo/chat-sdk-core';
import './user-message.js';
import './user-image-message.js';
import './user-voice-message.js';
import './assistant-message.js';
import './assistant-product-message.js';

@customElement('yalo-message')
export class YaloMessage extends LitElement {
  @property({ attribute: false }) message!: ChatMessage;
  @property({ attribute: false }) store?: ChatStore;

  static styles = css`
    :host { display: block; padding: 4px 16px; }
    .typing-indicator {
      display: flex;
      gap: 4px;
      padding: 8px;
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

  private _onExpandToggle() {
    if (this.message.id !== undefined) {
      this.store?.toggleMessageExpand(this.message.id);
    }
  }

  private _onUnitsChange(e: CustomEvent) {
    if (this.message.id !== undefined) {
      const { sku, unitsAdded, subunitsAdded } = e.detail as { sku: string; unitsAdded: number; subunitsAdded: number };
      this.store?.updateProductQuantity(this.message.id, sku, unitsAdded, subunitsAdded);
    }
  }

  render() {
    const msg = this.message;
    if (!msg) return html``;

    if (msg.role === MessageRole.User) {
      if (msg.type === MessageType.Image) {
        return html`<yalo-user-image-message
          .fileName=${msg.fileName ?? ''}
          .content=${msg.content}
        ></yalo-user-image-message>`;
      }
      if (msg.type === MessageType.Voice) {
        return html`<yalo-user-voice-message
          .fileName=${msg.fileName ?? ''}
          .amplitudes=${msg.amplitudes ?? []}
          .duration=${msg.duration ?? 0}
        ></yalo-user-voice-message>`;
      }
      return html`<yalo-user-message .content=${msg.content}></yalo-user-message>`;
    }

    // Assistant messages
    if (msg.type === MessageType.Product || msg.type === MessageType.ProductCarousel) {
      return html`<yalo-assistant-product-message
        .products=${msg.products}
        .expanded=${msg.expand}
        .carousel=${msg.type === MessageType.ProductCarousel}
        @expand-toggle=${this._onExpandToggle}
        @units-change=${this._onUnitsChange}
      ></yalo-assistant-product-message>`;
    }

    return html`<yalo-assistant-message .content=${msg.content}></yalo-assistant-message>`;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-message': YaloMessage;
  }
}
