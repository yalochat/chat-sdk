// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.repository.fake.FakeChatMessageRepository
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs

// FDE-56: MessageSyncService tests.
@OptIn(ExperimentalCoroutinesApi::class)
class MessageSyncServiceTest {

    private val dispatcher = UnconfinedTestDispatcher()

    private fun yaloRepo(vararg batches: List<ChatMessage>): YaloMessageRepository =
        object : YaloMessageRepository {
            override suspend fun sendMessage(message: ChatMessage) = Result.Ok(Unit)
            override suspend fun fetchMessages(since: Long) = Result.Ok(emptyList<ChatMessage>())
            override fun pollIncomingMessages(): Flow<List<ChatMessage>> = flowOf(*batches)
        }

    private fun msg(id: Long, content: String = "msg $id") = ChatMessage(
        id = id,
        role = MessageRole.AGENT,
        type = MessageType.Text,
        status = MessageStatus.DELIVERED,
        content = content,
    )

    // ── core FDE-56 test: batch of 3 messages → insertMessages called ─────────

    @Test
    fun `mock remote returns 3 messages — all inserted into local repo`() = runTest {
        val batch = listOf(msg(1L, "A"), msg(2L, "B"), msg(3L, "C"))
        val localRepo = FakeChatMessageRepository()
        val service = MessageSyncService(yaloRepo(batch), localRepo)

        service.start(this)
        testScheduler.advanceUntilIdle()

        val result = localRepo.getMessages(cursor = null, limit = 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(3, result.result.size)
        assertEquals(setOf("A", "B", "C"), result.result.map { it.content }.toSet())
    }

    @Test
    fun `multiple poll batches are all inserted`() = runTest {
        val batch1 = listOf(msg(1L), msg(2L))
        val batch2 = listOf(msg(3L), msg(4L))
        val localRepo = FakeChatMessageRepository()
        val service = MessageSyncService(yaloRepo(batch1, batch2), localRepo)

        service.start(this)
        testScheduler.advanceUntilIdle()

        val result = localRepo.getMessages(cursor = null, limit = 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(4, result.result.size)
    }

    @Test
    fun `start is idempotent — calling twice does not duplicate messages`() = runTest {
        val batch = listOf(msg(1L))
        val localRepo = FakeChatMessageRepository()
        val service = MessageSyncService(yaloRepo(batch), localRepo)

        service.start(this)
        service.start(this) // second call should be a no-op

        testScheduler.advanceUntilIdle()

        val result = localRepo.getMessages(cursor = null, limit = 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(1, result.result.size)
    }

    @Test
    fun `stop cancels polling`() = runTest {
        // Repo that tracks whether insertMessages was called after stop
        var insertCallCount = 0
        val trackingRepo = object : ChatMessageRepository {
            override suspend fun getMessages(cursor: Long?, limit: Int) = Result.Ok(emptyList<ChatMessage>())
            override suspend fun insertMessage(message: ChatMessage) = Result.Ok(Unit)
            override suspend fun insertMessages(messages: List<ChatMessage>): Result<Unit> {
                insertCallCount++
                return Result.Ok(Unit)
            }
            override suspend fun updateMessage(message: ChatMessage) = Result.Ok(Unit)
            override fun observeMessages() = kotlinx.coroutines.flow.MutableStateFlow(emptyList<ChatMessage>())
        }
        val batch = listOf(msg(1L))
        val service = MessageSyncService(yaloRepo(batch), trackingRepo)

        service.start(this)
        service.stop()
        testScheduler.advanceUntilIdle()

        // After stop, no further inserts should happen from the cancelled flow
        assertEquals(0, insertCallCount)
    }
}
