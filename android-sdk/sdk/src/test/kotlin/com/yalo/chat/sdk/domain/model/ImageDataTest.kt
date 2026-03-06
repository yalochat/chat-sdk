// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals

class ImageDataTest {

    @Test
    fun `two instances with identical bytes are equal`() {
        val bytes = byteArrayOf(1, 2, 3)
        val a = ImageData(path = "/img.jpg", bytes = bytes, mimeType = "image/jpeg")
        val b = ImageData(path = "/img.jpg", bytes = byteArrayOf(1, 2, 3), mimeType = "image/jpeg")
        assertEquals(a, b)
    }

    @Test
    fun `instances with different bytes are not equal`() {
        val a = ImageData(bytes = byteArrayOf(1, 2, 3))
        val b = ImageData(bytes = byteArrayOf(4, 5, 6))
        assertNotEquals(a, b)
    }

    @Test
    fun `instances with null bytes are equal when other fields match`() {
        val a = ImageData(path = "/img.jpg", bytes = null)
        val b = ImageData(path = "/img.jpg", bytes = null)
        assertEquals(a, b)
    }

    @Test
    fun `hashCode is consistent for equal instances`() {
        val bytes = byteArrayOf(10, 20)
        val a = ImageData(bytes = bytes)
        val b = ImageData(bytes = byteArrayOf(10, 20))
        assertEquals(a.hashCode(), b.hashCode())
    }
}
