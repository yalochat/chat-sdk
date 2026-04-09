// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals

class ProductTest {

    private val base = Product(
        sku = "SKU-001",
        name = "Test Product",
        price = 9.99,
        imagesUrl = listOf("https://example.com/img.jpg"),
        unitName = "unit",
    )

    @Test
    fun `two instances with identical fields are equal`() {
        assertEquals(base, base.copy())
    }

    @Test
    fun `copy with single field change produces distinct instance`() {
        val modified = base.copy(price = 19.99)
        assertNotEquals(base, modified)
        assertEquals(19.99, modified.price)
        assertEquals(base.sku, modified.sku)
    }

    @Test
    fun `default values are applied correctly`() {
        val product = Product(sku = "SKU-002", name = "Minimal", price = 1.0, unitName = "item")
        assertEquals(emptyList(), product.imagesUrl)
        assertEquals(0.0, product.unitsAdded)
        assertEquals(0.0, product.subunitsAdded)
        assertEquals(1.0, product.subunits)
    }
}
