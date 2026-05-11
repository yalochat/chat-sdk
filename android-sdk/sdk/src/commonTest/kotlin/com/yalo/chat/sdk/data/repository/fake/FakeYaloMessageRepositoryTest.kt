// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ButtonType
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageType
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertIs
import kotlin.test.assertTrue

class FakeYaloMessageRepositoryTest {

    private val repo = FakeYaloMessageRepository()

    @Test
    fun `fetchMessages returns non-empty list`() = runTest {
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertTrue(result.result.isNotEmpty())
    }

    @Test
    fun `fetchMessages covers all MessageType variants`() = runTest {
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val types = result.result.map { it.type }.toSet()
        assertTrue(MessageType.Text in types)
        assertTrue(MessageType.Image in types)
        assertTrue(MessageType.Voice in types)
        assertTrue(MessageType.Product in types)
        assertTrue(MessageType.ProductCarousel in types)
        assertTrue(MessageType.Promotion in types)
        assertTrue(MessageType.Unknown in types)
        // Proto 2.0: quick replies are Text messages with REPLY-typed buttons, not a separate type.
        val hasReplyButtons = result.result.any { msg ->
            msg.type == MessageType.Text && msg.buttons.any { it.type == ButtonType.REPLY }
        }
        assertTrue(hasReplyButtons, "Seed data must include a Text message with REPLY buttons")
    }

    @Test
    fun `fetchMessages includes both USER and AGENT roles`() = runTest {
        val result = repo.fetchMessages(since = 0L)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val roles = result.result.map { it.role }.toSet()
        assertTrue(MessageRole.USER in roles)
        assertTrue(MessageRole.AGENT in roles)
    }

    @Test
    fun `sendMessage returns Ok`() = runTest {
        val message = FakeYaloMessageRepository.SEED_MESSAGES.first()
        val result = repo.sendMessage(message)
        assertIs<Result.Ok<Unit>>(result)
    }
}
