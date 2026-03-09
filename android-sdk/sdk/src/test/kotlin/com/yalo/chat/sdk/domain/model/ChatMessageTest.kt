// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals

class ChatMessageTest {

    private val base = ChatMessage(
        role = MessageRole.USER,
        type = MessageType.Text,
        content = "hello",
        timestamp = 1000L,
    )

    @Test
    fun `two instances with identical fields are equal`() {
        val a = base.copy()
        val b = base.copy()
        assertEquals(a, b)
    }

    @Test
    fun `copy with single field change produces distinct instance`() {
        val modified = base.copy(content = "world")
        assertNotEquals(base, modified)
        assertEquals("world", modified.content)
        assertEquals(base.role, modified.role)
    }

    @Test
    fun `default values are applied when optional fields are omitted`() {
        val msg = ChatMessage(role = MessageRole.AGENT, type = MessageType.Text, timestamp = 0L)
        assertEquals("", msg.content)
        assertEquals(MessageStatus.IN_PROGRESS, msg.status)
        assertEquals(emptyList(), msg.products)
        assertEquals(emptyList(), msg.quickReplies)
        assertEquals(emptyList(), msg.amplitudes)
    }
}
