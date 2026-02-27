// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import type { Product } from '@yalo/chat-sdk-core';
import './image-placeholder.js';
import './product-message-price.js';
import './numeric-text-field.js';

@customElement('yalo-product-horizontal-card')
export class YaloProductHorizontalCard extends LitElement {
  @property({ attribute: false }) product!: Product;

  static styles = css`
    :host {
      display: flex;
      align-items: center;
      gap: 8px;
      border: 1px solid var(--yalo-card-border-color, #DDE4EC);
      border-radius: 12px;
      overflow: hidden;
      background: var(--yalo-card-bg-color, #FFFFFF);
      padding: 8px;
    }
    .image-wrap {
      width: 64px;
      height: 64px;
      flex-shrink: 0;
      overflow: hidden;
      border-radius: 4px;
    }
    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    .body {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .name {
      font-weight: bold;
      font-size: 14px;
      color: var(--yalo-product-title-color, #000);
    }
    .footer {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
  `;

  private _onUnitsChange(e: CustomEvent) {
    this.dispatchEvent(new CustomEvent('units-change', {
      detail: { sku: this.product.sku, unitsAdded: e.detail, subunitsAdded: this.product.subunitsAdded },
      bubbles: true, composed: true,
    }));
  }

  render() {
    const p = this.product;
    const imageUrl = p.imagesUrl[0];
    return html`
      <div class="image-wrap">
        ${imageUrl
          ? html`<img src="${imageUrl}" alt="${p.name}" />`
          : html`<yalo-image-placeholder size="32"></yalo-image-placeholder>`}
      </div>
      <div class="body">
        <div class="name">${p.name}</div>
        <div class="footer">
          <yalo-product-message-price
            .price=${p.price}
            .salePrice=${p.salePrice}
          ></yalo-product-message-price>
          <yalo-numeric-text-field
            .value=${p.unitsAdded}
            .step=${p.unitStep}
            @value-change=${this._onUnitsChange}
          ></yalo-numeric-text-field>
        </div>
      </div>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-product-horizontal-card': YaloProductHorizontalCard;
  }
}
