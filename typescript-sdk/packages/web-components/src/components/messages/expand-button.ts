// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('yalo-expand-button')
export class YaloExpandButton extends LitElement {
  @property({ type: Boolean }) expanded = false;
  @property({ type: Number }) totalItems = 0;
  @property({ type: Number }) collapsedMax = 3;

  static styles = css`
    button {
      background: none;
      border: none;
      cursor: pointer;
      color: var(--yalo-expand-controls-color, #2207F1);
      font-size: 14px;
      padding: 4px 0;
    }
    button:hover { text-decoration: underline; }
  `;

  private _handleClick() {
    this.dispatchEvent(new CustomEvent('expand-toggle', { bubbles: true, composed: true }));
  }

  render() {
    if (this.totalItems <= this.collapsedMax) return html``;
    const label = this.expanded
      ? 'See less'
      : `See all ${this.totalItems}`;
    return html`<button @click=${this._handleClick}>${label}</button>`;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-expand-button': YaloExpandButton;
  }
}
