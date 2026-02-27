// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';

@customElement('yalo-attachment-button')
export class YaloAttachmentButton extends LitElement {
  @property({ type: Boolean }) open = false;

  static styles = css`
    :host { position: relative; }
    .trigger {
      width: 44px;
      height: 44px;
      border-radius: 50%;
      border: none;
      background: none;
      cursor: pointer;
      font-size: 22px;
      color: var(--yalo-attach-icon-color, #7C8086);
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .menu {
      position: absolute;
      bottom: 52px;
      left: 0;
      background: var(--yalo-attachment-bg-color, #FFFFFF);
      border: 1px solid var(--yalo-input-border-color, #E8E8E8);
      border-radius: 12px;
      padding: 8px;
      display: flex;
      flex-direction: column;
      gap: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.12);
      z-index: 10;
    }
    .menu-item {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 8px 12px;
      border-radius: 8px;
      cursor: pointer;
      font-size: 14px;
      border: 1px solid var(--yalo-picker-btn-border-color, #E6E6E6);
    }
    .menu-item:hover { background: var(--yalo-user-msg-color, #F9FAFC); }
  `;

  render() {
    return html`
      <button class="trigger"
        @click=${() => this.dispatchEvent(new CustomEvent('toggle', { bubbles: true, composed: true }))}
        aria-label="attachment options"
      >+</button>
      ${this.open ? html`
        <div class="menu">
          <div class="menu-item" @click=${() => this._emit('camera')}>📷 Camera</div>
          <div class="menu-item" @click=${() => this._emit('gallery')}>🖼 Gallery</div>
        </div>
      ` : ''}
    `;
  }

  private _emit(source: string) {
    this.dispatchEvent(new CustomEvent('pick', { detail: source, bubbles: true, composed: true }));
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-attachment-button': YaloAttachmentButton;
  }
}
