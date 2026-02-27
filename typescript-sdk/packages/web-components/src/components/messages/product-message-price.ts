// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { formatCurrency } from '@yalo/chat-sdk-core';

@customElement('yalo-product-message-price')
export class YaloProductMessagePrice extends LitElement {
  @property({ type: Number }) price = 0;
  @property({ type: Number }) salePrice?: number;

  static styles = css`
    :host {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      background-color: var(--yalo-product-price-bg-color, #ECFDF5);
      border-radius: 33px;
      padding: 4px 8px;
    }
    .price {
      font-weight: bold;
      color: var(--yalo-product-price-color, #186C54);
      font-size: 13px;
    }
    .original {
      text-decoration: line-through;
      color: var(--yalo-product-sale-strike-color, #0B996D);
      font-size: 12px;
    }
  `;

  render() {
    const displayPrice = this.salePrice ?? this.price;
    return html`
      <span class="price">${formatCurrency(displayPrice)}</span>
      ${this.salePrice !== undefined && this.salePrice < this.price
        ? html`<span class="original">${formatCurrency(this.price)}</span>`
        : ''}
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-product-message-price': YaloProductMessagePrice;
  }
}
