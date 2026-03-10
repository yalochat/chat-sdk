// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.remote

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class SimpleCacheTest {

    @Test
    fun `get returns null for absent key`() {
        val cache = SimpleCache<String, Boolean>(capacity = 10)
        assertNull(cache.get("missing"))
    }

    @Test
    fun `set and get round-trip`() {
        val cache = SimpleCache<String, Boolean>(capacity = 10)
        cache.set("id-1", true)
        assertEquals(true, cache.get("id-1"))
    }

    @Test
    fun `capacity eviction removes eldest entry`() {
        val cache = SimpleCache<Int, Int>(capacity = 3)
        cache.set(1, 1)
        cache.set(2, 2)
        cache.set(3, 3)
        // Access key 1 to make it "recently used" — key 2 becomes the eldest
        cache.get(1)
        // Insert a 4th entry, which exceeds capacity → eldest (key 2) is evicted
        cache.set(4, 4)
        assertNull(cache.get(2))
        assertEquals(1, cache.get(1))
        assertEquals(3, cache.get(3))
        assertEquals(4, cache.get(4))
    }

    @Test
    fun `overwriting an existing key does not grow beyond capacity`() {
        val cache = SimpleCache<Int, Int>(capacity = 2)
        cache.set(1, 1)
        cache.set(2, 2)
        cache.set(1, 99) // overwrite, not a new entry
        cache.set(3, 3) // should evict key 2 (eldest)
        assertNull(cache.get(2))
        assertEquals(99, cache.get(1))
        assertEquals(3, cache.get(3))
    }
}
