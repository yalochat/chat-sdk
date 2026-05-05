// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.MessageSyncService
import com.yalo.chat.sdk.data.repository.fake.FakeChatMessageRepository
import com.yalo.chat.sdk.data.repository.fake.FakeYaloMessageRepository
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.model.Product
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertIs
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class MessagesControllerTest {

    private val dispatcher = UnconfinedTestDispatcher()
    private val tracked = mutableListOf<MessagesController>()

    @AfterTest
    fun tearDown() {
        tracked.forEach { it.stop() }
        tracked.clear()
    }

    private fun controller(
        yaloRepo: YaloMessageRepository = FakeYaloMessageRepository(),
        localRepo: FakeChatMessageRepository = FakeChatMessageRepository(),
    ) = MessagesController(
        yaloRepo, localRepo,
        MessageSyncService(yaloRepo, localRepo),
        dispatcher,
    ).also { tracked.add(it) }

    private fun msg(id: Long, content: String = "msg $id") = ChatMessage(
        id = id,
        role = MessageRole.AGENT,
        type = MessageType.Text,
        status = MessageStatus.DELIVERED,
        content = content,
    )

    // ── start ─────────────────────────────────────────────────────────────────

    @Test
    fun `start delivers existing messages via callback`() = runTest {
        val localRepo = FakeChatMessageRepository(listOf(msg(1L, "hi")))
        val received = mutableListOf<List<ChatMessage>>()
        controller(localRepo = localRepo).start { received.add(it) }
        assertTrue(received.isNotEmpty())
        assertEquals(1, received.last().size)
    }

    @Test
    fun `start delivers new messages inserted after start`() = runTest {
        val localRepo = FakeChatMessageRepository()
        val received = mutableListOf<List<ChatMessage>>()
        controller(localRepo = localRepo).start { received.add(it) }
        localRepo.insertMessage(msg(1L, "new"))
        assertEquals(1, received.last().size)
    }

    @Test
    fun `start is idempotent — second call does not add a second observer`() = runTest {
        val localRepo = FakeChatMessageRepository()
        var observer1Fires = 0
        var observer2Fires = 0
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { observer1Fires++ }
        ctrl.start { observer2Fires++ } // no-op — scope already exists
        localRepo.insertMessage(msg(1L))
        assertEquals(0, observer2Fires)
    }

    // ── stop ──────────────────────────────────────────────────────────────────

    @Test
    fun `stop prevents further callbacks`() = runTest {
        val localRepo = FakeChatMessageRepository()
        var count = 0
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { count++ }
        val countBeforeStop = count
        ctrl.stop()
        localRepo.insertMessage(msg(1L))
        assertEquals(countBeforeStop, count)
    }

    // ── loadMessages ──────────────────────────────────────────────────────────

    @Test
    fun `loadMessages before start is a no-op`() = runTest {
        var completed = false
        controller().loadMessages { completed = true }
        assertFalse(completed)
    }

    @Test
    fun `loadMessages after start reports success`() = runTest {
        var result: Boolean? = null
        val ctrl = controller()
        ctrl.start { }
        ctrl.loadMessages { result = it }
        assertEquals(true, result)
    }

    @Test
    fun `loadMessages reports failure when repo errors`() = runTest {
        val failingLocalRepo = object : ChatMessageRepository {
            override suspend fun getMessages(cursor: Long?, limit: Int) =
                Result.Error<List<ChatMessage>>(RuntimeException("db error"))
            override suspend fun insertMessage(msg: ChatMessage) = Result.Ok(Unit)
            override suspend fun insertMessages(msgs: List<ChatMessage>) = Result.Ok(Unit)
            override suspend fun updateMessage(msg: ChatMessage) = Result.Ok(Unit)
            override fun observeMessages(): Flow<List<ChatMessage>> =
                MutableStateFlow(emptyList<ChatMessage>()).asStateFlow()
        }
        val ctrl = MessagesController(
            FakeYaloMessageRepository(), failingLocalRepo,
            MessageSyncService(FakeYaloMessageRepository(), failingLocalRepo),
            dispatcher,
        ).also { tracked.add(it) }
        ctrl.start { }
        var result: Boolean? = null
        ctrl.loadMessages { result = it }
        assertEquals(false, result)
    }

    // ── sendTextMessage ───────────────────────────────────────────────────────

    @Test
    fun `sendTextMessage with blank text does not insert a message`() = runTest {
        val localRepo = FakeChatMessageRepository()
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { }
        ctrl.sendTextMessage("   ")
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertTrue(result.result.isEmpty())
    }

    @Test
    fun `sendTextMessage before start is a no-op`() = runTest {
        val localRepo = FakeChatMessageRepository()
        controller(localRepo = localRepo).sendTextMessage("hello")
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertTrue(result.result.isEmpty())
    }

    @Test
    fun `sendTextMessage inserts optimistic message with USER role and SENT status`() = runTest {
        val localRepo = FakeChatMessageRepository()
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { }
        ctrl.sendTextMessage("hello")
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val message = result.result.single()
        assertEquals("hello", message.content)
        assertEquals(MessageRole.USER, message.role)
        assertEquals(MessageStatus.SENT, message.status)
        assertEquals(MessageType.Text, message.type)
    }

    @Test
    fun `sendTextMessage updates status to ERROR when remote send fails`() = runTest {
        val failingYaloRepo = object : YaloMessageRepository {
            override suspend fun sendMessage(msg: ChatMessage) =
                Result.Error<Unit>(RuntimeException("network error"))
            override suspend fun fetchMessages(since: Long) = Result.Ok(emptyList<ChatMessage>())
            override fun pollIncomingMessages(): Flow<List<ChatMessage>> = emptyFlow()
            override fun events(): Flow<ChatEvent> = emptyFlow()
        }
        val localRepo = FakeChatMessageRepository()
        val ctrl = MessagesController(
            failingYaloRepo, localRepo,
            MessageSyncService(failingYaloRepo, localRepo),
            dispatcher,
        ).also { tracked.add(it) }
        ctrl.start { }
        ctrl.sendTextMessage("hello")
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(MessageStatus.ERROR, result.result.single().status)
    }

    @Test
    fun `sendTextMessage consecutive sends produce unique message ids`() = runTest {
        val localRepo = FakeChatMessageRepository()
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { }
        ctrl.sendTextMessage("first")
        ctrl.sendTextMessage("second")
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val ids = result.result.mapNotNull { it.id }
        assertEquals(2, ids.distinct().size)
    }

    // ── sendImageMessage ──────────────────────────────────────────────────────

    @Test
    fun `sendImageMessage with empty fileName does not insert a message`() = runTest {
        val localRepo = FakeChatMessageRepository()
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { }
        ctrl.sendImageMessage("", "image/jpeg")
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertTrue(result.result.isEmpty())
    }

    @Test
    fun `sendImageMessage before start is a no-op`() = runTest {
        val localRepo = FakeChatMessageRepository()
        controller(localRepo = localRepo).sendImageMessage("/tmp/photo.jpg", "image/jpeg")
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertTrue(result.result.isEmpty())
    }

    @Test
    fun `sendImageMessage inserts optimistic message with USER role and SENT status`() = runTest {
        val localRepo = FakeChatMessageRepository()
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { }
        ctrl.sendImageMessage("/tmp/photo.jpg", "image/jpeg")
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val message = result.result.single()
        assertEquals(MessageRole.USER, message.role)
        assertEquals(MessageStatus.SENT, message.status)
        assertEquals(MessageType.Image, message.type)
        assertEquals("/tmp/photo.jpg", message.fileName)
        assertEquals("image/jpeg", message.mediaType)
    }

    @Test
    fun `sendImageMessage updates status to ERROR when remote send fails`() = runTest {
        val failingYaloRepo = object : YaloMessageRepository {
            override suspend fun sendMessage(msg: ChatMessage) =
                Result.Error<Unit>(RuntimeException("network error"))
            override suspend fun fetchMessages(since: Long) = Result.Ok(emptyList<ChatMessage>())
            override fun pollIncomingMessages(): Flow<List<ChatMessage>> = emptyFlow()
            override fun events(): Flow<ChatEvent> = emptyFlow()
        }
        val localRepo = FakeChatMessageRepository()
        val ctrl = MessagesController(
            failingYaloRepo, localRepo,
            MessageSyncService(failingYaloRepo, localRepo),
            dispatcher,
        ).also { tracked.add(it) }
        ctrl.start { }
        ctrl.sendImageMessage("/tmp/photo.jpg", "image/jpeg")
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(MessageStatus.ERROR, result.result.single().status)
    }

    // ── sendVoiceMessage ──────────────────────────────────────────────────────

    @Test
    fun `sendVoiceMessage with empty fileName does not insert a message`() = runTest {
        val localRepo = FakeChatMessageRepository()
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { }
        ctrl.sendVoiceMessage("", emptyList(), 1000L)
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertTrue(result.result.isEmpty())
    }

    @Test
    fun `sendVoiceMessage before start is a no-op`() = runTest {
        val localRepo = FakeChatMessageRepository()
        controller(localRepo = localRepo).sendVoiceMessage("/tmp/audio.m4a", emptyList(), 1000L)
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertTrue(result.result.isEmpty())
    }

    @Test
    fun `sendVoiceMessage inserts optimistic message with USER role and SENT status`() = runTest {
        val localRepo = FakeChatMessageRepository()
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { }
        val amps = listOf(-20.0, -15.0, -10.0)
        ctrl.sendVoiceMessage("/tmp/audio.m4a", amps, 2500L)
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val message = result.result.single()
        assertEquals(MessageRole.USER, message.role)
        assertEquals(MessageStatus.SENT, message.status)
        assertEquals(MessageType.Voice, message.type)
        assertEquals("/tmp/audio.m4a", message.fileName)
        assertEquals("audio/mp4", message.mediaType)
        assertEquals(amps, message.amplitudes)
        assertEquals(2500L, message.duration)
    }

    @Test
    fun `sendVoiceMessage updates status to ERROR when remote send fails`() = runTest {
        val failingYaloRepo = object : YaloMessageRepository {
            override suspend fun sendMessage(msg: ChatMessage) =
                Result.Error<Unit>(RuntimeException("network error"))
            override suspend fun fetchMessages(since: Long) = Result.Ok(emptyList<ChatMessage>())
            override fun pollIncomingMessages(): Flow<List<ChatMessage>> = emptyFlow()
            override fun events(): Flow<ChatEvent> = emptyFlow()
        }
        val localRepo = FakeChatMessageRepository()
        val ctrl = MessagesController(
            failingYaloRepo, localRepo,
            MessageSyncService(failingYaloRepo, localRepo),
            dispatcher,
        ).also { tracked.add(it) }
        ctrl.start { }
        ctrl.sendVoiceMessage("/tmp/audio.m4a", emptyList(), 2000L)
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(MessageStatus.ERROR, result.result.single().status)
    }

    @Test
    fun `sendImageMessage consecutive sends produce unique message ids`() = runTest {
        val localRepo = FakeChatMessageRepository()
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { }
        ctrl.sendImageMessage("/tmp/a.jpg", "image/jpeg")
        ctrl.sendImageMessage("/tmp/b.jpg", "image/jpeg")
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val ids = result.result.mapNotNull { it.id }
        assertEquals(2, ids.distinct().size)
    }

    // ── updateProductQuantity ─────────────────────────────────────────────────

    private fun productMsg(
        id: Long,
        sku: String,
        unitsAdded: Double = 0.0,
        subunits: Double = 0.0,
        subunitsAdded: Double = 0.0,
    ) = ChatMessage(
        id = id,
        role = MessageRole.AGENT,
        type = MessageType.Product,
        status = MessageStatus.DELIVERED,
        products = listOf(Product(sku = sku, name = "Test", price = 1.0, subunits = subunits, unitsAdded = unitsAdded, subunitsAdded = subunitsAdded)),
    )

    private fun trackingYaloRepo(
        addToCartCalls: MutableList<Pair<String, Double>> = mutableListOf(),
        removeFromCartCalls: MutableList<Pair<String, Double>> = mutableListOf(),
    ): YaloMessageRepository = object : YaloMessageRepository {
        override suspend fun sendMessage(msg: ChatMessage) = Result.Ok(Unit)
        override suspend fun fetchMessages(since: Long) = Result.Ok(emptyList<ChatMessage>())
        override fun pollIncomingMessages(): Flow<List<ChatMessage>> = emptyFlow()
        override suspend fun addToCart(sku: String, quantity: Double): Result<Unit> {
            addToCartCalls.add(sku to quantity); return Result.Ok(Unit)
        }
        override suspend fun removeFromCart(sku: String, quantity: Double?): Result<Unit> {
            removeFromCartCalls.add(sku to (quantity ?: 0.0)); return Result.Ok(Unit)
        }
    }

    @Test
    fun `updateProductQuantity dispatches addToCart when quantity increases`() = runTest {
        val addCalls = mutableListOf<Pair<String, Double>>()
        val yaloRepo = trackingYaloRepo(addToCartCalls = addCalls)
        val localRepo = FakeChatMessageRepository(listOf(productMsg(10L, "sku-A", unitsAdded = 1.0)))
        val ctrl = MessagesController(yaloRepo, localRepo, MessageSyncService(yaloRepo, localRepo), dispatcher)
            .also { tracked.add(it) }
        ctrl.start { }
        ctrl.updateProductQuantity(10L, "sku-A", isSubunit = false, quantity = 3.0)
        assertEquals(1, addCalls.size, "addToCart should be called once")
        assertEquals("sku-A" to 2.0, addCalls.first(), "delta = 3 - 1 = 2")
    }

    @Test
    fun `updateProductQuantity dispatches removeFromCart when quantity decreases`() = runTest {
        val removeCalls = mutableListOf<Pair<String, Double>>()
        val yaloRepo = trackingYaloRepo(removeFromCartCalls = removeCalls)
        val localRepo = FakeChatMessageRepository(listOf(productMsg(11L, "sku-B", unitsAdded = 4.0)))
        val ctrl = MessagesController(yaloRepo, localRepo, MessageSyncService(yaloRepo, localRepo), dispatcher)
            .also { tracked.add(it) }
        ctrl.start { }
        ctrl.updateProductQuantity(11L, "sku-B", isSubunit = false, quantity = 2.0)
        assertEquals(1, removeCalls.size, "removeFromCart should be called once")
        assertEquals("sku-B" to 2.0, removeCalls.first(), "delta = 2 - 4 = -2, abs = 2")
    }

    @Test
    fun `updateProductQuantity does not dispatch when sku is not found in message`() = runTest {
        val addCalls = mutableListOf<Pair<String, Double>>()
        val removeCalls = mutableListOf<Pair<String, Double>>()
        val yaloRepo = trackingYaloRepo(addCalls, removeCalls)
        val localRepo = FakeChatMessageRepository(listOf(productMsg(12L, "sku-C")))
        val ctrl = MessagesController(yaloRepo, localRepo, MessageSyncService(yaloRepo, localRepo), dispatcher)
            .also { tracked.add(it) }
        ctrl.start { }
        ctrl.updateProductQuantity(12L, "sku-UNKNOWN", isSubunit = false, quantity = 5.0)
        assertTrue(addCalls.isEmpty(), "No addToCart call for unknown SKU")
        assertTrue(removeCalls.isEmpty(), "No removeFromCart call for unknown SKU")
    }

    @Test
    fun `updateProductQuantity does not dispatch when message id is not found`() = runTest {
        val addCalls = mutableListOf<Pair<String, Double>>()
        val yaloRepo = trackingYaloRepo(addToCartCalls = addCalls)
        val localRepo = FakeChatMessageRepository(listOf(productMsg(13L, "sku-D")))
        val ctrl = MessagesController(yaloRepo, localRepo, MessageSyncService(yaloRepo, localRepo), dispatcher)
            .also { tracked.add(it) }
        ctrl.start { }
        ctrl.updateProductQuantity(999L, "sku-D", isSubunit = false, quantity = 2.0)
        assertTrue(addCalls.isEmpty(), "No cart call for unknown message id")
    }

    @Test
    fun `sendVoiceMessage consecutive sends produce unique message ids`() = runTest {
        val localRepo = FakeChatMessageRepository()
        val ctrl = controller(localRepo = localRepo)
        ctrl.start { }
        ctrl.sendVoiceMessage("/tmp/a.m4a", emptyList(), 1000L)
        ctrl.sendVoiceMessage("/tmp/b.m4a", emptyList(), 2000L)
        val result = localRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val ids = result.result.mapNotNull { it.id }
        assertEquals(2, ids.distinct().size)
    }
}
