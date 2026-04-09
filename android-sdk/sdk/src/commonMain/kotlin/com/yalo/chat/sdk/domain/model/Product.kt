// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import kotlinx.serialization.Serializable

// Port of flutter-sdk/lib/domain/models/product/product.dart
// All fields mirror the Flutter model exactly, including unit/subunit handling.
@Serializable
data class Product(
    val sku: String,
    val name: String,
    val price: Double,
    val imagesUrl: List<String> = emptyList(),
    val salePrice: Double? = null,
    val subunits: Double = 1.0,
    val unitStep: Double = 1.0,
    val unitName: String = "",
    val subunitName: String? = null,
    val subunitStep: Double = 1.0,
    val unitsAdded: Double = 0.0,
    val subunitsAdded: Double = 0.0,
)
