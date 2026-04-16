// Copyright (c) Yalochat, Inc. All rights reserved.

import { formatCurrency } from '@common/format';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import { consume } from '@lit/context';
import { css, html, LitElement, nothing } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('product-message-price')
export class ProductMessagePrice extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-product-price-background: #eef2f7;
      --yalo-chat-product-price-color: #111111;
      --yalo-chat-product-price-strike-color: #7c8086;
      --yalo-chat-product-price-per-subunit-color: #7c8086;
      --yalo-chat-product-price-padding: 0.3125em;
      --yalo-chat-product-price-radius: 2.0625em;
      --yalo-chat-product-price-gap: 0.5em;
      --yalo-chat-product-price-font-size: 0.875rem;
      display: block;
      overflow-x: auto;
    }

    .row {
      display: flex;
      align-items: center;
      gap: var(--yalo-chat-product-price-gap);
      font-size: var(--yalo-chat-product-price-font-size);
    }

    .pill {
      display: inline-flex;
      align-items: center;
      gap: 0.25em;
      padding: var(--yalo-chat-product-price-padding)
        calc(var(--yalo-chat-product-price-padding) * 2);
      background: var(--yalo-chat-product-price-background);
      color: var(--yalo-chat-product-price-color);
      border-radius: var(--yalo-chat-product-price-radius);
      font-weight: 600;
    }

    .strike {
      color: var(--yalo-chat-product-price-strike-color);
      text-decoration: line-through;
      font-weight: 400;
    }

    .per-subunit {
      color: var(--yalo-chat-product-price-per-subunit-color);
    }
  `;

  @consume({ context: yaloChatClientConfigContext })
  config!: YaloChatClientConfig;

  @property({ type: Number })
  price = 0;

  @property({ type: Number })
  salePrice?: number;

  @property({ type: Number })
  pricePerSubunit?: number;

  @property({ type: String })
  currency = 'USD';

  render() {
    const hasSale = this.salePrice !== undefined;
    const main = hasSale ? (this.salePrice as number) : this.price;
    const old = hasSale ? this.price : undefined;
    const options = {
      locale: this.config?.locale,
      currency: this.currency,
    };

    return html`
      <div class="row">
        <span class="pill">
          <span class="main">${formatCurrency(main, options)}</span>
          ${old !== undefined
            ? html`<span class="strike">${formatCurrency(old, options)}</span>`
            : nothing}
        </span>
        ${this.pricePerSubunit !== undefined
          ? html`<span class="per-subunit"
              >${formatCurrency(this.pricePerSubunit, options)}</span
            >`
          : nothing}
      </div>
    `;
  }
}
