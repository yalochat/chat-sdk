// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('yalo-quick-reply')
export class YaloQuickReply extends LitElement {
  @property({ type: Array }) replies: string[] = [];

  static styles = css`
    :host {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      padding: 8px 16px;
    }
    button {
      background: var(--yalo-quick-reply-color, #F9FAFC);
      color: var(--yalo-quick-reply-text-color, #000);
      border: 1px solid var(--yalo-quick-reply-border-color, #ECEDEF);
      border-radius: 24px;
      padding: 8px 16px;
      font-size: 14px;
      cursor: pointer;
      height: 40px;
      white-space: nowrap;
    }
    button:hover { opacity: 0.8; }
  `;

  render() {
    if (!this.replies.length) return html``;
    return html`
      ${this.replies.map((r) => html`
        <button @click=${() => this._onReply(r)}>${r}</button>
      `)}
    `;
  }

  private _onReply(reply: string) {
    this.dispatchEvent(new CustomEvent('quick-reply-selected', {
      detail: reply,
      bubbles: true,
      composed: true,
    }));
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-quick-reply': YaloQuickReply;
  }
}
