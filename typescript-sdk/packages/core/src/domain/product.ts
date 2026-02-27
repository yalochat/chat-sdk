// Copyright (c) Yalochat, Inc. All rights reserved.

/** Represents a product in the catalog. */
export interface Product {
  /** Stock keeping unit */
  sku: string;
  /** Display name shown as a title */
  name: string;
  /** Original price */
  price: number;
  /** Product image URLs */
  imagesUrl: string[];
  /** Sale price — takes precedence over price when defined */
  salePrice?: number;
  /**
   * Number of subunits per unit (e.g. items per box).
   * Used to increase units when purchasing >= subunits.
   */
  subunits: number;
  /** Step increment when adjusting units */
  unitStep: number;
  /** ICU-format plural label for the unit (e.g. "{amount, plural, one {box} other {boxes}}") */
  unitName: string;
  /** ICU-format plural label for the subunit (optional) */
  subunitName?: string;
  /** Step increment when adjusting subunits */
  subunitStep: number;
  /** User-selected unit quantity */
  unitsAdded: number;
  /** User-selected subunit quantity */
  subunitsAdded: number;
}

export function createProduct(partial: Omit<Product, 'subunits' | 'unitStep' | 'subunitStep' | 'unitsAdded' | 'subunitsAdded' | 'imagesUrl'> & Partial<Product>): Product {
  return {
    subunits: 1,
    unitStep: 1,
    subunitStep: 1,
    unitsAdded: 0,
    subunitsAdded: 0,
    imagesUrl: [],
    ...partial,
  };
}

export function productFromJson(json: Record<string, unknown>): Product {
  return {
    sku: json['sku'] as string,
    name: json['name'] as string,
    price: json['price'] as number,
    imagesUrl: (json['imagesUrl'] as string[] | undefined) ?? [],
    salePrice: json['salePrice'] as number | undefined,
    subunits: (json['subunits'] as number | undefined) ?? 1,
    unitStep: (json['unitStep'] as number | undefined) ?? 1,
    unitName: json['unitName'] as string,
    subunitName: json['subunitName'] as string | undefined,
    subunitStep: (json['subunitStep'] as number | undefined) ?? 1,
    unitsAdded: (json['unitsAdded'] as number | undefined) ?? 0,
    subunitsAdded: (json['subunitsAdded'] as number | undefined) ?? 0,
  };
}

export function productToJson(product: Product): Record<string, unknown> {
  const result: Record<string, unknown> = {
    sku: product.sku,
    name: product.name,
    price: product.price,
    imagesUrl: product.imagesUrl,
    subunits: product.subunits,
    unitStep: product.unitStep,
    unitName: product.unitName,
    subunitStep: product.subunitStep,
    unitsAdded: product.unitsAdded,
    subunitsAdded: product.subunitsAdded,
  };
  if (product.salePrice !== undefined) result['salePrice'] = product.salePrice;
  if (product.subunitName !== undefined) result['subunitName'] = product.subunitName;
  return result;
}
