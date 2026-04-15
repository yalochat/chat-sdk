// Copyright (c) Yalochat, Inc. All rights reserved.

export class Product {
  // The SKU of the product
  readonly sku: string;

  // The name of the product that will be displayed as a title
  readonly name: string;

  // The price of the product
  readonly price: number;

  // The images to display with the product
  readonly imagesUrl: string[];

  // The sale price of the product, if it's defined this price will
  // take precedence over price
  readonly salePrice?: number;

  // The units per quantity of the product added, for example
  // if the product is sold as boxes, this value should contain
  // the number of elements inside the box. This value will be used
  // to increase the amount of boxes if a user purchases more or equal
  // amount of units in the box.
  readonly subunits: number;

  // The step to add when increasing/decreasing units
  readonly unitStep: number;

  // The name of the unit, it must be an string using ICU message format grammar
  // to support plurals, use the amount parameter name to handle plurals.  e.g
  // {amount, plural, one {box} other {boxes}}
  readonly unitName: string;

  // The name of the subunit if applies, it must be an string using ICU message
  // format grammar to support plurals, use the amount parameter name to handle
  // plurals.  e.g {amount, plural, one {box} other {boxes}}
  readonly subunitName?: string;

  // The step to add when increasing/decreasing subunits
  readonly subunitStep: number;

  // The units added by the user
  readonly unitsAdded: number;

  // The subunits added by the user
  readonly subunitsAdded: number;

  constructor(params: {
    sku: string;
    name: string;
    price: number;
    imagesUrl?: string[];
    salePrice?: number;
    subunits?: number;
    unitStep?: number;
    unitName: string;
    subunitName?: string;
    subunitStep?: number;
    unitsAdded?: number;
    subunitsAdded?: number;
  }) {
    this.sku = params.sku;
    this.name = params.name;
    this.price = params.price;
    this.imagesUrl = params.imagesUrl ?? [];
    this.salePrice = params.salePrice;
    this.subunits = params.subunits ?? 1;
    this.unitStep = params.unitStep ?? 1;
    this.unitName = params.unitName;
    this.subunitName = params.subunitName;
    this.subunitStep = params.subunitStep ?? 1;
    this.unitsAdded = params.unitsAdded ?? 0;
    this.subunitsAdded = params.subunitsAdded ?? 0;
  }
}
