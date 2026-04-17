// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import type { Product } from '@domain/models/product/product';
import { consume } from '@lit/context';
import { css, html, LitElement, nothing } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import ProductCardController from './product-card-controller';
import './numeric-input';
import './product-message-price';

export type ProductCardLayout = 'horizontal' | 'vertical';

@customElement('product-card')
export class ProductCard extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-product-title-color: #111111;
      --yalo-chat-product-subunits-color: #7c8086;
      --yalo-chat-product-image-radius: 0.125em;
      --yalo-chat-product-gap: 0.5rem;
      --yalo-chat-product-title-size: 1rem;
      --yalo-chat-product-subunits-size: 0.875rem;
      display: block;
      width: 100%;
    }

    .card {
      display: flex;
      gap: var(--yalo-chat-product-gap);
    }

    .card.horizontal {
      flex-direction: row;
      align-items: stretch;
    }

    .card.vertical {
      flex-direction: column;
    }

    .image-wrap {
      border-radius: var(--yalo-chat-product-image-radius);
      overflow: hidden;
      background: #f1f3f6;
      flex-shrink: 0;
    }

    .card.horizontal .image-wrap {
      flex: 1 1 33%;
    }

    .card.vertical .image-wrap {
      width: 100%;
    }

    .image-wrap img,
    .placeholder {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }

    .placeholder {
      background: repeating-linear-gradient(
        45deg,
        #e6e9ee,
        #e6e9ee 0.5em,
        #f1f3f6 0.5em,
        #f1f3f6 1em
      );
    }

    .info {
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
      min-width: 0;
      flex: 1 1 auto;
    }

    .title {
      font-size: var(--yalo-chat-product-title-size);
      font-weight: 600;
      color: var(--yalo-chat-product-title-color);
      word-break: break-word;
    }

    .subunits {
      font-size: var(--yalo-chat-product-subunits-size);
      color: var(--yalo-chat-product-subunits-color);
    }

    .quantities {
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
      margin-top: 0.25rem;
    }
  `;

  private _controller = new ProductCardController(this);

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @property({ attribute: false })
  product!: Product;

  @property({ type: Number })
  messageId!: number;

  @property({ type: String })
  layout: ProductCardLayout = 'horizontal';

  @property({ type: String })
  currency = 'USD';

  render() {
    const {
      name,
      price,
      salePrice,
      subunits,
      imagesUrl,
      unitsAdded,
      unitName,
      unitStep,
      subunitsAdded,
      subunitName,
      subunitStep,
    } = this.product;
    const imageUrl = imagesUrl[0];

    return html`
      <div class="card ${this.layout}">
        <div class="image-wrap">
          ${imageUrl
            ? html`<img src=${imageUrl} alt=${name} loading="lazy" />`
            : html`<div class="placeholder" aria-hidden="true"></div>`}
        </div>
        <div class="info">
          <div class="title">${name}</div>
          ${subunitName
            ? html`<div class="subunits">
                ${subunits}
                ${this._controller.formatUnit(subunits, subunitName)}
              </div>`
            : nothing}
          <product-message-price
            .price=${price}
            .salePrice=${salePrice}
            .pricePerSubunit=${this._controller.pricePerSubunit}
            .currency=${this.currency}
          ></product-message-price>
          <div class="quantities">
            <numeric-input
              .value=${unitsAdded}
              .step=${unitStep}
              .unitName=${this._controller.formatUnit(unitsAdded, unitName)}
              @yalo-chat-numeric-add=${this._controller.onUnitChange}
              @yalo-chat-numeric-remove=${this._controller.onUnitChange}
              @yalo-chat-numeric-change=${this._controller.onUnitChange}
            ></numeric-input>
            ${subunitName
              ? html`<numeric-input
                  .value=${subunitsAdded}
                  .step=${subunitStep}
                  .unitName=${this._controller.formatUnit(
                    subunitsAdded,
                    subunitName
                  )}
                  @yalo-chat-numeric-add=${this._controller.onSubunitChange}
                  @yalo-chat-numeric-remove=${this._controller.onSubunitChange}
                  @yalo-chat-numeric-change=${this._controller.onSubunitChange}
                ></numeric-input>`
              : nothing}
          </div>
        </div>
      </div>
    `;
  }
}
