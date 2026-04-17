// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import { localized, msg } from '@lit/localize';
import { css, html, LitElement, nothing } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import './product-card';

export type ProductMessageDirection = 'vertical' | 'horizontal';

const COLLAPSED_MAX_ITEMS = 3;

@customElement('product-message')
@localized()
export class ProductMessage extends LitElement {
  static styles = css`
    :host {
      --yalo-chat-product-message-card-background: #ffffff;
      --yalo-chat-product-message-card-border-color: #dde4ec;
      --yalo-chat-product-message-card-radius: 1rem;
      --yalo-chat-product-message-card-padding: 1rem;
      --yalo-chat-product-message-gap: 1rem;
      --yalo-chat-product-message-expand-color: #2207f1;
      display: block;
    }

    .list {
      display: flex;
      gap: var(--yalo-chat-product-message-gap);
    }

    .list.vertical {
      flex-direction: column;
    }

    .list.horizontal {
      flex-direction: row;
      overflow-x: auto;
      scroll-snap-type: x mandatory;
      -webkit-overflow-scrolling: touch;
    }

    .item {
      background: var(--yalo-chat-product-message-card-background);
      border: 1px solid var(--yalo-chat-product-message-card-border-color);
      border-radius: var(--yalo-chat-product-message-card-radius);
      padding: var(--yalo-chat-product-message-card-padding);
      box-sizing: border-box;
    }

    .list.horizontal .item {
      flex: 0 0 70%;
      max-width: 14rem;
      scroll-snap-align: start;
    }

    .list.vertical .item {
      width: 100%;
    }

    .expand {
      background: none;
      border: none;
      padding: 0.5rem;
      cursor: pointer;
      color: var(--yalo-chat-product-message-expand-color);
      font-size: 0.875rem;
      font-weight: 600;
    }

    .expand:hover {
      text-decoration: underline;
    }

    .list.vertical .expand-wrap {
      width: 100%;
      display: flex;
      justify-content: center;
    }

    .list.horizontal .expand-wrap {
      align-self: center;
      flex: 0 0 auto;
    }
  `;

  @property({ attribute: false })
  message!: ChatMessage;

  @property({ type: String })
  direction: ProductMessageDirection = 'vertical';

  @property({ type: String })
  currency = 'USD';

  @state()
  private _expanded = false;

  private _toggle = () => {
    this._expanded = !this._expanded;
  };

  render() {
    const products = this.message.products;
    const cardLayout =
      this.direction === 'vertical' ? 'horizontal' : 'vertical';
    const overflow = products.length > COLLAPSED_MAX_ITEMS;
    const visible =
      overflow && !this._expanded
        ? products.slice(0, COLLAPSED_MAX_ITEMS)
        : products;

    return html`
      <div class="list ${this.direction}">
        ${visible.map(
          (product) => html`
            <div class="item">
              <product-card
                .product=${product}
                .messageId=${this.message.id!}
                .layout=${cardLayout}
                .currency=${this.currency}
              ></product-card>
            </div>
          `
        )}
        ${overflow
          ? html`
              <div class="expand-wrap">
                <button class="expand" type="button" @click=${this._toggle}>
                  ${this._expanded ? msg('Show less') : msg('Show more')}
                </button>
              </div>
            `
          : nothing}
      </div>
    `;
  }
}
