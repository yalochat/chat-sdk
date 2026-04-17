// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ProductUnitType } from '@domain/models/product/product';

export type ChangeQuantity = {
  messageId: number;
  sku: string;
  unitType: ProductUnitType;
  value: number;
};
