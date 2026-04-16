// Copyright (c) Yalochat, Inc. All rights reserved.

import IntlMessageFormat from 'intl-messageformat';
import type { ReactiveController } from 'lit';
import type { ProductCard } from './product-card';

export type ProductUnitType = 'unit' | 'subunit';

export default class ProductCardController implements ReactiveController {
  host: ProductCard;

  constructor(host: ProductCard) {
    this.host = host;
    this.host.addController(this);
  }

  hostConnected() {}

  formatUnit(amount: number, pattern: string): string {
    try {
      return new IntlMessageFormat(
        pattern,
        this.host.config?.locale
      ).format({ amount }) as string;
    } catch {
      return pattern;
    }
  }

  get pricePerSubunit(): number | undefined {
    const { price, subunits } = this.host.product;
    return subunits > 1 ? price / subunits : undefined;
  }

  onUnitChange = (e: CustomEvent<{ value: number }>) => {
    this._emitQuantityChange('unit', e.detail.value);
  };

  onSubunitChange = (e: CustomEvent<{ value: number }>) => {
    this._emitQuantityChange('subunit', e.detail.value);
  };

  private _emitQuantityChange(unitType: ProductUnitType, value: number) {
    this.host.dispatchEvent(
      new CustomEvent('yalo-chat-product-quantity-change', {
        detail: { sku: this.host.product.sku, unitType, value },
        bubbles: true,
        composed: true,
      })
    );
  }
}
