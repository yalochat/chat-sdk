// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

// Payload passed to the updateCartProduct command callback. It carries the
// absolute cart quantities for a single SKU, replacing whatever was there
// before. It is delivered both when the chat triggers the update locally and
// when the channel requests it.
class CartProductUpdate extends Equatable {
  // The SKU of the product being updated.
  final String sku;

  // Absolute number of primary units for this SKU after the update.
  final double units;

  // Absolute number of subunits for this SKU after the update. Zero when the
  // product has no subunit dimension.
  final double subunits;

  const CartProductUpdate({
    required this.sku,
    required this.units,
    required this.subunits,
  });

  @override
  List<Object?> get props => [sku, units, subunits];
}

// Handler the host registers for the updateCartProduct command. It receives the
// absolute cart quantities for a SKU and runs instead of the built-in remote
// call.
typedef UpdateCartProductCallback = void Function(CartProductUpdate product);
