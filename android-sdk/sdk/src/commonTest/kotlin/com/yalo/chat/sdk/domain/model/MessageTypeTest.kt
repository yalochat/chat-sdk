// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.domain.model

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs

class MessageTypeTest {

    @Test
    fun `fromString returns correct type for all known values`() {
        assertEquals(MessageType.Text, MessageType.fromString("text"))
        assertEquals(MessageType.Image, MessageType.fromString("image"))
        assertEquals(MessageType.Voice, MessageType.fromString("voice"))
        assertEquals(MessageType.Product, MessageType.fromString("product"))
        assertEquals(MessageType.ProductCarousel, MessageType.fromString("productCarousel"))
        assertEquals(MessageType.Promotion, MessageType.fromString("promotion"))
        assertEquals(MessageType.QuickReply, MessageType.fromString("quickReply"))
        assertEquals(MessageType.Unknown, MessageType.fromString("unknown"))
    }

    @Test
    fun `fromString returns Unknown for unrecognized string`() {
        assertIs<MessageType.Unknown>(MessageType.fromString("notAType"))
        assertIs<MessageType.Unknown>(MessageType.fromString(""))
        assertIs<MessageType.Unknown>(MessageType.fromString("TEXT"))
    }

    @Test
    fun `MessageRole fromString returns correct role`() {
        assertEquals(MessageRole.USER, MessageRole.fromString("USER"))
        assertEquals(MessageRole.AGENT, MessageRole.fromString("AGENT"))
    }

    @Test
    fun `MessageRole fromString returns AGENT for unknown value`() {
        // Mirrors Flutter SDK: orElse: () => MessageRole.assistant (AGENT)
        assertEquals(MessageRole.AGENT, MessageRole.fromString("unknown"))
        assertEquals(MessageRole.AGENT, MessageRole.fromString(""))
    }

    @Test
    fun `MessageStatus fromString returns correct status`() {
        assertEquals(MessageStatus.SENT, MessageStatus.fromString("SENT"))
        assertEquals(MessageStatus.DELIVERED, MessageStatus.fromString("DELIVERED"))
        assertEquals(MessageStatus.READ, MessageStatus.fromString("READ"))
        assertEquals(MessageStatus.IN_PROGRESS, MessageStatus.fromString("IN_PROGRESS"))
        assertEquals(MessageStatus.ERROR, MessageStatus.fromString("ERROR"))
    }

    @Test
    fun `MessageStatus fromString returns IN_PROGRESS for unknown value`() {
        assertEquals(MessageStatus.IN_PROGRESS, MessageStatus.fromString("unknown"))
        assertEquals(MessageStatus.IN_PROGRESS, MessageStatus.fromString(""))
    }
}
