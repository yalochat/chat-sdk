// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import type { Product } from '@yalo/chat-sdk-core';
import { formatUnit } from '@yalo/chat-sdk-core';
import './image-placeholder.js';
import './product-message-price.js';
import './numeric-text-field.js';

@customElement('yalo-product-vertical-card')
export class YaloProductVerticalCard extends LitElement {
  @property({ attribute: false }) product!: Product;

  static styles = css`
    :host {
      display: block;
      border: 1px solid var(--yalo-card-border-color, #DDE4EC);
      border-radius: 12px;
      overflow: hidden;
      background: var(--yalo-card-bg-color, #FFFFFF);
      max-width: 200px;
    }
    .image-wrap {
      width: 100%;
      aspect-ratio: 1;
      overflow: hidden;
    }
    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    .body {
      padding: 8px;
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .name {
      font-weight: bold;
      font-size: 14px;
      color: var(--yalo-product-title-color, #000);
    }
    .subunit {
      font-size: 12px;
      color: var(--yalo-product-subunits-color, #334155);
    }
    .controls {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-top: 4px;
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
    const subunitLabel = p.subunitName ? formatUnit(p.subunits, p.subunitName) : '';
    return html`
      <div class="image-wrap">
        ${imageUrl
          ? html`<img src="${imageUrl}" alt="${p.name}" />`
          : html`<yalo-image-placeholder></yalo-image-placeholder>`}
      </div>
      <div class="body">
        <div class="name">${p.name}</div>
        ${subunitLabel ? html`<div class="subunit">${subunitLabel}</div>` : ''}
        <div class="controls">
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
    'yalo-product-vertical-card': YaloProductVerticalCard;
  }
}
