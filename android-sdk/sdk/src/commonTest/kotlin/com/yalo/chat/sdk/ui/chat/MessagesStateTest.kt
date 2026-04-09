// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertIs
import kotlin.test.assertTrue

class MessagesStateTest {

    @Test
    fun `default MessagesState has empty messages and Initial status`() {
        val state = MessagesState()
        assertTrue(state.messages.isEmpty())
        assertEquals("", state.userMessage)
        assertFalse(state.isLoading)
        assertFalse(state.isConnected)
        assertIs<ChatStatus.Initial>(state.chatStatus)
        assertTrue(state.quickReplies.isEmpty())
    }

    @Test
    fun `copy with updated userMessage returns new state`() {
        val state = MessagesState().copy(userMessage = "hello")
        assertEquals("hello", state.userMessage)
    }
}
