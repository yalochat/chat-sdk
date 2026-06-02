// Copyright (c) Yalochat, Inc. All rights reserved.

import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import { Product } from '@domain/models/product/product';
import { consume } from '@lit/context';
import { localized, msg } from '@lit/localize';
import { css, html, LitElement, nothing, type PropertyValues } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';
import { defaultIcons } from '@domain/config/chat-config';
import ProductCardController from './product-card-controller';
import './numeric-input';
import './product-message-price';

export type ProductCardLayout = 'horizontal' | 'vertical';
export type ProductCardCartState = 'not-added' | 'in-cart' | 'modified';

@customElement('yalo-chat-product-card')
@localized()
export class ProductCard extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-product-title-color: #111111;
      --yalo-chat-product-subunits-color: #7c8086;
      --yalo-chat-product-image-radius: 0.125em;
      --yalo-chat-product-gap: 0.5rem;
      --yalo-chat-product-title-size: 1rem;
      --yalo-chat-product-subunits-size: 0.875rem;
      --yalo-chat-product-card-button-background: #111111;
      --yalo-chat-product-card-button-color: #ffffff;
      --yalo-chat-product-card-button-background-clicked: #0b996d;
      --yalo-chat-product-card-button-color-clicked: #ffffff;
      --yalo-chat-product-card-button-border: none;
      --yalo-chat-product-card-button-border-radius: 0.5rem;
      --yalo-chat-product-card-button-padding: 0.5rem;
      --yalo-chat-product-card-button-font-size: 0.875rem;
      --yalo-chat-product-card-button-icon-font-size: 1rem;
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

    .cart-button {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.25rem;
      margin-top: 0.5rem;
      padding: var(--yalo-chat-product-card-button-padding);
      border: var(--yalo-chat-product-card-button-border);
      border-radius: var(--yalo-chat-product-card-button-border-radius);
      background: var(--yalo-chat-product-card-button-background);
      color: var(--yalo-chat-product-card-button-color);
      font-size: var(--yalo-chat-product-card-button-font-size);
      cursor: pointer;
      word-break: break-word;
    }

    .cart-button.in-cart {
      background: var(--yalo-chat-product-card-button-background-clicked);
      color: var(--yalo-chat-product-card-button-color-clicked);
    }

    .material-symbols-outlined {
      font-size: var(--yalo-chat-product-card-button-icon-font-size);
      font-family: 'Material Symbols Outlined';
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

  @state()
  private _cartState?: ProductCardCartState;

  private get _effectiveCartState(): ProductCardCartState {
    if (this._cartState) {
      return this._cartState;
    }
    return this.product.inCart ? 'in-cart' : 'not-added';
  }

  willUpdate(changedProps: PropertyValues<this>) {
    const previous = changedProps.get('product') as Product | undefined;
    if (!previous) {
      return;
    }
    if (previous.sku !== this.product.sku) {
      this._cartState = undefined;
      return;
    }
    if (this._effectiveCartState !== 'in-cart') {
      return;
    }
    const quantityChanged =
      previous.unitsAdded !== this.product.unitsAdded ||
      previous.subunitsAdded !== this.product.subunitsAdded;
    if (quantityChanged) {
      this._cartState = 'modified';
    }
  }

  private _onCartButtonClick = () => {
    this._cartState = 'in-cart';
    this._controller.onCartButtonClick();
  };

  private _cartButtonLabel(): string {
    switch (this._effectiveCartState) {
      case 'in-cart':
        return msg('In the cart');
      case 'modified':
        return msg('Update the cart');
      default:
        return msg('Add to cart');
    }
  }

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
          <yalo-chat-product-message-price
            .price=${price}
            .salePrice=${salePrice}
            .pricePerSubunit=${this._controller.pricePerSubunit}
            .currency=${this.currency}
          ></yalo-chat-product-message-price>
          <div class="quantities">
            <yalo-chat-numeric-input
              .value=${unitsAdded}
              .step=${unitStep}
              .unitName=${this._controller.formatUnit(unitsAdded, unitName)}
              @yalo-chat-numeric-add=${this._controller.onUnitChange}
              @yalo-chat-numeric-remove=${this._controller.onUnitChange}
              @yalo-chat-numeric-change=${this._controller.onUnitChange}
            ></yalo-chat-numeric-input>
            ${subunitName
              ? html`<yalo-chat-numeric-input
                  .value=${subunitsAdded}
                  .step=${subunitStep}
                  .unitName=${this._controller.formatUnit(
                    subunitsAdded,
                    subunitName
                  )}
                  @yalo-chat-numeric-add=${this._controller.onSubunitChange}
                  @yalo-chat-numeric-remove=${this._controller.onSubunitChange}
                  @yalo-chat-numeric-change=${this._controller.onSubunitChange}
                ></yalo-chat-numeric-input>`
              : nothing}
          </div>
          <button
            type="button"
            class="cart-button ${this._effectiveCartState === 'in-cart'
              ? 'in-cart'
              : ''}"
            ?disabled=${this._effectiveCartState === 'in-cart'}
            @click=${this._onCartButtonClick}
          >
            ${this._effectiveCartState === 'in-cart'
              ? html`<span class="icon"
                  >${unsafeHTML(
                    this.config?.icons?.check ?? defaultIcons.check
                  )}</span
                >`
              : nothing}
            ${this._cartButtonLabel()}
          </button>
        </div>
      </div>
    `;
  }
}
