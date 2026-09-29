// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.common.hash

import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Every expected value here was produced by the web SDK's `xxhash32` for the
 * same input. They are what keeps a conversation scoped by context the same
 * one on both clients, so a change that moves any of them has to be made on
 * both sides at once.
 */
class XxHash32Test {

    @Test
    fun matchesTheWebSdkForTheSameInput() {
        val expected: Map<String, String> = mapOf(
            "" to "ry8zp",
            "a" to "nlkdw6",
            "abc" to "e3lqf3",
            "{}" to "6qi9vt",
            """{"source":"product-page"}""" to "1e2gi7e",
            """{"source":"product-page","sku":"37549996"}""" to "188hajw",
            """{"sku":"37549996","source":"product-page"}""" to "13rbbtq",
            "the quick brown fox jumps over the lazy dog" to "sf9uuv",
            """{"emoji":"ñ é 漢字"}""" to "tyxmh7",
        )

        for ((input, hash) in expected) {
            assertEquals("hash of <$input>", hash, xxhash32(input))
        }
    }

    @Test
    fun readsTheSameInputTheSameWayEveryTime() {
        val input = """{"source":"product-page","sku":"37549996"}"""

        assertEquals(xxhash32(input), xxhash32(input))
    }
}
