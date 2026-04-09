// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.repository.fake

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue

class FakeChatMessageRepositoryTest {

    private fun repo() = FakeChatMessageRepository()

    private fun message(id: Long, content: String = "msg $id") = ChatMessage(
        id = id,
        role = MessageRole.USER,
        type = MessageType.Text,
        status = MessageStatus.SENT,
        content = content,
    )

    @Test
    fun `insertMessage then getMessages returns inserted message`() = runTest {
        val r = repo()
        r.insertMessage(message(1L))
        val result = r.getMessages(cursor = null, limit = 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(1, result.result.size)
        assertEquals(1L, result.result.first().id)
    }

    @Test
    fun `getMessages with cursor returns only messages before cursor`() = runTest {
        val r = repo()
        r.insertMessage(message(1L))
        r.insertMessage(message(2L))
        r.insertMessage(message(3L))
        val result = r.getMessages(cursor = 3L, limit = 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertTrue(result.result.none { it.id == 3L })
        assertTrue(result.result.all { it.id!! < 3L })
    }

    @Test
    fun `getMessages respects limit`() = runTest {
        val r = repo()
        repeat(5) { r.insertMessage(message(it.toLong() + 1)) }
        val result = r.getMessages(cursor = null, limit = 3)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(3, result.result.size)
    }

    @Test
    fun `updateMessage replaces correct entry by id`() = runTest {
        val r = repo()
        r.insertMessage(message(1L, "original"))
        r.updateMessage(message(1L, "updated"))
        val result = r.getMessages(cursor = null, limit = 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals("updated", result.result.first { it.id == 1L }.content)
    }

    @Test
    fun `updateMessage returns Error when id not found`() = runTest {
        val r = repo()
        val result = r.updateMessage(message(99L))
        assertIs<Result.Error<*>>(result)
    }

    @Test
    fun `updateMessage returns Error when id is null`() = runTest {
        val r = repo()
        val nullIdMessage = ChatMessage(
            id = null,
            role = MessageRole.USER,
            type = MessageType.Text,
            status = MessageStatus.SENT,
            content = "no id",
        )
        val result = r.updateMessage(nullIdMessage)
        assertIs<Result.Error<*>>(result)
    }

    @Test
    fun `insertMessages inserts all messages and updates flow`() = runTest {
        val r = repo()
        r.insertMessages(listOf(message(1L, "A"), message(2L, "B"), message(3L, "C")))
        val result = r.getMessages(cursor = null, limit = 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(3, result.result.size)
        val emitted = r.observeMessages().first()
        assertEquals(3, emitted.size)
    }

    @Test
    fun `observeMessages emits updated list after insertMessage`() = runTest {
        val r = repo()
        r.insertMessage(message(1L))
        val emitted = r.observeMessages().first()
        assertEquals(1, emitted.size)
        assertEquals(1L, emitted.first().id)
    }

    @Test
    fun `observeMessages emits updated list after updateMessage`() = runTest {
        val r = repo()
        r.insertMessage(message(1L, "before"))
        r.updateMessage(message(1L, "after"))
        val emitted = r.observeMessages().first()
        assertEquals("after", emitted.first().content)
    }
}
