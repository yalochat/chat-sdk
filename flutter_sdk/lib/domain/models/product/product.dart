// Copyright (c) Yalochat, Inc. All rights reserved.

// Class used to represent a product
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product extends Equatable {
  // The SKU of the product
  final String sku;

  // The name of the product that will be displayed as a title
  final String name;

  // The price of the product
  final double price;

  // The images to display with the product
  final List<String> imagesUrl;

  // The sale price of the product, if it's defined this price will
  // take precedence over price
  final double? salePrice;

  // The units per quantity of the product added, for example
  // if the product is sold as boxes, this value should contain
  // the number of elements inside the box. This value will be used
  // to increase the amount of boxes if a user purchases more or equal
  // amount of units in the box.
  final double subunits;

  // The step to add when increasing/decreasing units
  final double unitStep;

  // The unit name of the product, e.g box.
  final String unitName;

  // The plural unit name of the product in plural e.g boxes
  final String unitNamePlural;

  // The name of the subunit if applies.
  final String? subunitName;

  // The plural of the subunits if applies.
  final String? subunitNamePlural;

  // The step to add when increasing/decreasing subunits
  final double subunitStep;

  // The units added by the user
  final double unitsAdded;

  // The subunits added by the user
  final double subunitsAdded;

  const Product({
    required this.sku,
    required this.name,
    required this.price,
    this.imagesUrl = const [],
    this.salePrice,
    this.subunits = 1,
    this.unitStep = 1,
    required this.unitName,
    required this.unitNamePlural,
    this.subunitName,
    this.subunitNamePlural,
    this.subunitStep = 1,
    this.unitsAdded = 0,
    this.subunitsAdded = 0,
  });

  Product copyWith({
    String? sku,
    String? name,
    double? price,
    List<String>? imagesUrl,
    double? salePrice,
    double? subunits,
    double? unitStep,
    String? unitName,
    String? unitNamePlural,
    String? subunitName,
    String? subunitNamePlural,
    double? subunitStep,
    double? unitsAdded,
    double? subunitsAdded,
  }) {
    return Product(
      sku: sku ?? this.sku,
      name: name ?? this.name,
      price: price ?? this.price,
      imagesUrl: imagesUrl ?? this.imagesUrl,
      salePrice: salePrice ?? this.salePrice,
      subunits: subunits ?? this.subunits,
      unitStep: unitStep ?? this.unitStep,
      unitName: unitName ?? this.unitName,
      unitNamePlural: unitNamePlural ?? this.unitNamePlural,
      subunitName: subunitName ?? this.subunitName,
      subunitNamePlural: subunitNamePlural ?? this.subunitNamePlural,
      subunitStep: subunitStep ?? this.subunitStep,
      unitsAdded: unitsAdded ?? this.unitsAdded,
      subunitsAdded: subunitsAdded ?? this.subunitsAdded,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  @override
  List<Object?> get props => [
    sku,
    name,
    price,
    subunits,
    imagesUrl,
    salePrice,
    subunits,
    unitStep,
    unitName,
    unitNamePlural,
    subunitName,
    subunitNamePlural,
    subunitStep,
    unitsAdded,
    subunitsAdded,
  ];
}
