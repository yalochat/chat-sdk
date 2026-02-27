// Copyright (c) Yalochat, Inc. All rights reserved.

import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import type { Product } from '@yalo/chat-sdk-core';
import { SdkConstants } from '../../theme/constants.js';
import './product-vertical-card.js';
import './product-horizontal-card.js';
import './expand-button.js';

@customElement('yalo-assistant-product-message')
export class YaloAssistantProductMessage extends LitElement {
  @property({ attribute: false }) products: Product[] = [];
  @property({ type: Boolean }) expanded = false;
  @property({ type: Boolean }) carousel = false;

  static styles = css`
    :host { display: block; }
    .cards-row {
      display: flex;
      gap: 8px;
      overflow-x: auto;
      padding-bottom: 4px;
    }
    .cards-column {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    yalo-product-vertical-card {
      flex-shrink: 0;
      width: 180px;
    }
  `;

  render() {
    const max = SdkConstants.collapsedListMaxItems;
    const visibleProducts = this.expanded ? this.products : this.products.slice(0, max);

    return html`
      ${this.carousel
        ? html`
            <div class="cards-row">
              ${visibleProducts.map((p) => html`
                <yalo-product-vertical-card .product=${p}></yalo-product-vertical-card>
              `)}
            </div>
          `
        : html`
            <div class="cards-column">
              ${visibleProducts.map((p) => html`
                <yalo-product-horizontal-card .product=${p}></yalo-product-horizontal-card>
              `)}
            </div>
          `}
      <yalo-expand-button
        .expanded=${this.expanded}
        .totalItems=${this.products.length}
        .collapsedMax=${max}
        @expand-toggle=${() => this.dispatchEvent(new CustomEvent('expand-toggle', { bubbles: true, composed: true }))}
      ></yalo-expand-button>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'yalo-assistant-product-message': YaloAssistantProductMessage;
  }
}
