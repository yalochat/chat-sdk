// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.repository.fake.FakeChatMessageRepository
import com.yalo.chat.sdk.data.repository.fake.FakeYaloMessageRepository
import com.yalo.chat.sdk.domain.model.ChatEvent
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.AudioData
import com.yalo.chat.sdk.domain.model.ImageData
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.model.Product
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertIs
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class MessagesViewModelTest {

    private val dispatcher = UnconfinedTestDispatcher()
    private val trackedVms = mutableListOf<MessagesViewModel>()

    @BeforeTest
    fun setup() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterTest
    fun tearDown() {
        trackedVms.forEach { it.viewModelScope.cancel() }
        trackedVms.clear()
        Dispatchers.resetMain()
    }

    private fun viewModel(
        yaloRepo: com.yalo.chat.sdk.domain.repository.YaloMessageRepository = FakeYaloMessageRepository(),
        chatRepo: FakeChatMessageRepository = FakeChatMessageRepository(),
    ) = MessagesViewModel(yaloRepo, chatRepo)

    // ── LoadMessages ─────────────────────────────────────────────────────────

    @Test
    fun `LoadMessages sets messages and Success status`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(id = 1L, role = MessageRole.AGENT, type = MessageType.Text,
                status = MessageStatus.DELIVERED, content = "hi")
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)
        val state = vm.state.value
        assertIs<ChatStatus.Success>(state.chatStatus)
        assertEquals(1, state.messages.size)
    }

    @Test
    fun `LoadMessages when repo returns error emits Failure and no crash`() = runTest {
        val failingChatRepo = object : ChatMessageRepository {
            override suspend fun getMessages(cursor: Long?, limit: Int) =
                Result.Error<List<ChatMessage>>(RuntimeException("db error"))
            override suspend fun insertMessage(message: ChatMessage) = Result.Ok(Unit)
            override suspend fun insertMessages(messages: List<ChatMessage>) = Result.Ok(Unit)
            override suspend fun updateMessage(message: ChatMessage) = Result.Ok(Unit)
            override fun observeMessages(): Flow<List<ChatMessage>> = MutableStateFlow(emptyList())
        }
        val vm = MessagesViewModel(FakeYaloMessageRepository(), failingChatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)
        assertIs<ChatStatus.Failure>(vm.state.value.chatStatus)
    }

    // ── SubscribeToEvents / Typing Indicators ─────────────────────────────────

    // Returns a ViewModel backed by a controllable events flow, already subscribed.
    // Mirrors the production path: SubscribeToEvents dispatched in LaunchedEffect(Unit).
    private fun viewModelWithEvents(
        eventsFlow: MutableSharedFlow<ChatEvent> = MutableSharedFlow(extraBufferCapacity = Channel.UNLIMITED),
    ): Pair<MessagesViewModel, MutableSharedFlow<ChatEvent>> {
        val yaloRepo = object : YaloMessageRepository {
            override suspend fun sendMessage(message: ChatMessage) = Result.Ok(Unit)
            override suspend fun fetchMessages(since: Long) = Result.Ok(emptyList<ChatMessage>())
            override fun pollIncomingMessages(): Flow<List<ChatMessage>> = emptyFlow()
            override fun events(): Flow<ChatEvent> = eventsFlow
        }
        val vm = viewModel(yaloRepo = yaloRepo).also { trackedVms.add(it) }
        vm.handleEvent(MessagesEvent.SubscribeToEvents)
        return vm to eventsFlow
    }

    @Test
    fun `SubscribeToEvents on TypingStart sets isSystemTypingMessage true and chatStatusText`() = runTest {
        val (vm, events) = viewModelWithEvents()

        events.emit(ChatEvent.TypingStart("Writing message..."))

        assertTrue(vm.state.value.isSystemTypingMessage)
        assertEquals("Writing message...", vm.state.value.chatStatusText)
    }

    @Test
    fun `SubscribeToEvents on TypingStop resets isSystemTypingMessage and chatStatusText`() = runTest {
        val (vm, events) = viewModelWithEvents()

        events.emit(ChatEvent.TypingStart("Writing message..."))
        events.emit(ChatEvent.TypingStop)

        assertFalse(vm.state.value.isSystemTypingMessage)
        assertEquals("", vm.state.value.chatStatusText)
    }

    @Test
    fun `SubscribeToEvents is idempotent — second job does not survive ClearMessages`() = runTest {
        val (vm, events) = viewModelWithEvents()
        vm.handleEvent(MessagesEvent.SubscribeToEvents) // second call must be a no-op

        events.emit(ChatEvent.TypingStart("Writing message..."))
        assertTrue(vm.state.value.isSystemTypingMessage)

        // ClearMessages should cancel the single tracked eventsJob.
        // If idempotency is broken, a second uncancelled job survives here
        // and the next TypingStart would still update state.
        vm.handleEvent(MessagesEvent.ClearMessages)
        assertFalse(vm.state.value.isSystemTypingMessage)

        events.emit(ChatEvent.TypingStart("Writing message..."))

        // State must NOT update — no active subscriber should remain.
        assertFalse(vm.state.value.isSystemTypingMessage)
        vm.viewModelScope.cancel()
    }

    @Test
    fun `ClearMessages resets typing indicator state`() = runTest {
        val (vm, events) = viewModelWithEvents()
        events.emit(ChatEvent.TypingStart("Writing message..."))
        assertTrue(vm.state.value.isSystemTypingMessage)

        vm.handleEvent(MessagesEvent.ClearMessages)

        assertFalse(vm.state.value.isSystemTypingMessage)
        assertEquals("", vm.state.value.chatStatusText)
    }

    // ── UpdateUserMessage ─────────────────────────────────────────────────────

    @Test
    fun `UpdateUserMessage updates userMessage in state`() = runTest {
        val vm = viewModel()
        vm.handleEvent(MessagesEvent.UpdateUserMessage("hi"))
        assertEquals("hi", vm.state.value.userMessage)
    }

    // ── SendTextMessage ───────────────────────────────────────────────────────

    @Test
    fun `SendTextMessage with blank text does not insert a message`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SendTextMessage("   "))
        val result = chatRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertTrue(result.result.isEmpty())
    }

    @Test
    fun `SendTextMessage inserts optimistic message and clears userMessage`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.UpdateUserMessage("hello"))
        vm.handleEvent(MessagesEvent.SendTextMessage("hello"))
        assertEquals("", vm.state.value.userMessage)
        val result = chatRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(1, result.result.size)
        assertEquals("hello", result.result.first().content)
    }

    @Test
    fun `SendTextMessage marks optimistic message as ERROR when remote send fails`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val failingYaloRepo = object : YaloMessageRepository {
            override suspend fun sendMessage(message: ChatMessage) =
                Result.Error<Unit>(RuntimeException("network error"))
            override suspend fun fetchMessages(since: Long) = Result.Ok(emptyList<ChatMessage>())
            override fun pollIncomingMessages(): Flow<List<ChatMessage>> = emptyFlow()
            override fun events(): Flow<ChatEvent> = emptyFlow()
        }
        val vm = viewModel(yaloRepo = failingYaloRepo, chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SendTextMessage("hello"))
        val result = chatRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(MessageStatus.ERROR, result.result.first().status)
    }

    // ── ClearMessages ─────────────────────────────────────────────────────────

    @Test
    fun `ClearMessages resets state to defaults`() = runTest {
        val vm = viewModel()
        vm.handleEvent(MessagesEvent.UpdateUserMessage("typing..."))
        vm.handleEvent(MessagesEvent.ClearMessages)
        val state = vm.state.value
        assertTrue(state.messages.isEmpty())
        assertEquals("", state.userMessage)
        assertIs<ChatStatus.Initial>(state.chatStatus)
    }

    // ── ClearQuickReplies ─────────────────────────────────────────────────────

    @Test
    fun `ClearQuickReplies empties quickReplies list`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(id = 1L, role = MessageRole.AGENT, type = MessageType.QuickReply,
                status = MessageStatus.DELIVERED, content = "Pick:",
                quickReplies = listOf("A", "B"))
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)
        assertTrue(vm.state.value.quickReplies.isNotEmpty())
        vm.handleEvent(MessagesEvent.ClearQuickReplies)
        assertTrue(vm.state.value.quickReplies.isEmpty())
    }

    // ── Rapid emission ────────────────────────────────────────────────────────

    @Test
    fun `rapid event emission does not crash`() = runTest {
        val vm = viewModel()
        repeat(100) { i ->
            vm.handleEvent(MessagesEvent.UpdateUserMessage("msg $i"))
        }
        assertEquals("msg 99", vm.state.value.userMessage)
    }

    // ── SubscribeToMessages ───────────────────────────────────────────────────

    @Test
    fun `SubscribeToMessages updates state when messages are inserted into local repo`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)
        chatRepo.insertMessage(
            ChatMessage(id = 1L, role = MessageRole.USER, type = MessageType.Text,
                status = MessageStatus.SENT, content = "subscribed")
        )
        assertEquals(1, vm.state.value.messages.size)
        vm.viewModelScope.cancel()
    }

    @Test
    fun `SubscribeToMessages is idempotent — calling twice does not duplicate updates`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)
        chatRepo.insertMessage(
            ChatMessage(id = 1L, role = MessageRole.USER, type = MessageType.Text,
                status = MessageStatus.SENT, content = "hello")
        )
        assertEquals(1, vm.state.value.messages.size)
        vm.viewModelScope.cancel()
    }

    // ── QuickReplies extraction ───────────────────────────────────────────────

    @Test
    fun `LoadMessages extracts quickReplies from QuickReply message`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(id = 1L, role = MessageRole.AGENT, type = MessageType.QuickReply,
                status = MessageStatus.DELIVERED, content = "Choose:",
                quickReplies = listOf("Yes", "No"))
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)
        assertEquals(listOf("Yes", "No"), vm.state.value.quickReplies)
    }

    @Test
    fun `SubscribeToMessages extracts quickReplies when QuickReply message arrives`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)
        chatRepo.insertMessage(
            ChatMessage(id = 1L, role = MessageRole.AGENT, type = MessageType.QuickReply,
                status = MessageStatus.DELIVERED, content = "Pick one:",
                quickReplies = listOf("Option A", "Option B"))
        )
        assertEquals(listOf("Option A", "Option B"), vm.state.value.quickReplies)
        vm.viewModelScope.cancel()
    }

    // ── SendImageMessage ──────────────────────────────────────────────────────

    @Test
    fun `SendImageMessage inserts image message into local repo`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)

        vm.handleEvent(MessagesEvent.SendImageMessage(ImageData(path = "/storage/img.jpg")))

        val messages = vm.state.value.messages
        assertEquals(1, messages.size)
        assertEquals(MessageType.Image, messages.first().type)
        assertEquals("/storage/img.jpg", messages.first().fileName)
        assertEquals(MessageRole.USER, messages.first().role)
        assertEquals(MessageStatus.SENT, messages.first().status)
        vm.viewModelScope.cancel()
    }

    @Test
    fun `SendImageMessage with null path is a no-op`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)

        vm.handleEvent(MessagesEvent.SendImageMessage(ImageData(path = null)))

        assertTrue(vm.state.value.messages.isEmpty())
        vm.viewModelScope.cancel()
    }

    @Test
    fun `SendImageMessage updates chatStatus to Failure when insert fails`() = runTest {
        val failingChatRepo = object : ChatMessageRepository {
            override suspend fun getMessages(cursor: Long?, limit: Int) =
                Result.Ok(emptyList<ChatMessage>())
            override suspend fun insertMessage(message: ChatMessage) =
                Result.Error<Unit>(RuntimeException("disk full"))
            override suspend fun insertMessages(messages: List<ChatMessage>) = Result.Ok(Unit)
            override suspend fun updateMessage(message: ChatMessage) = Result.Ok(Unit)
            override fun observeMessages(): Flow<List<ChatMessage>> = MutableStateFlow(emptyList())
        }
        val vm = MessagesViewModel(FakeYaloMessageRepository(), failingChatRepo)

        vm.handleEvent(MessagesEvent.SendImageMessage(ImageData(path = "/storage/img.jpg")))

        assertIs<ChatStatus.Failure>(vm.state.value.chatStatus)
    }

    @Test
    fun `SendImageMessage marks optimistic message as ERROR when remote send fails`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val failingYaloRepo = object : YaloMessageRepository {
            override suspend fun sendMessage(message: ChatMessage) =
                Result.Error<Unit>(RuntimeException("upload failed"))
            override suspend fun fetchMessages(since: Long) = Result.Ok(emptyList<ChatMessage>())
            override fun pollIncomingMessages(): Flow<List<ChatMessage>> = emptyFlow()
            override fun events(): Flow<ChatEvent> = emptyFlow()
        }
        val vm = viewModel(yaloRepo = failingYaloRepo, chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)

        vm.handleEvent(MessagesEvent.SendImageMessage(ImageData(path = "/storage/img.jpg")))

        val result = chatRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(MessageStatus.ERROR, result.result.first().status)
        vm.viewModelScope.cancel()
    }

    // ── SendVoiceMessage ──────────────────────────────────────────────────────

    @Test
    fun `SendVoiceMessage inserts voice message into local repo`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)

        vm.handleEvent(MessagesEvent.SendVoiceMessage(AudioData(fileName = "voice.m4a", durationMs = 3000L)))

        val messages = vm.state.value.messages
        assertEquals(1, messages.size)
        assertEquals(MessageType.Voice, messages.first().type)
        assertEquals("voice.m4a", messages.first().fileName)
        assertEquals(MessageRole.USER, messages.first().role)
        assertEquals(MessageStatus.SENT, messages.first().status)
        vm.viewModelScope.cancel()
    }

    @Test
    fun `SendVoiceMessage with empty fileName is a no-op`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)

        vm.handleEvent(MessagesEvent.SendVoiceMessage(AudioData(fileName = "")))

        assertTrue(vm.state.value.messages.isEmpty())
        vm.viewModelScope.cancel()
    }

    @Test
    fun `SendVoiceMessage updates chatStatus to Failure when insert fails`() = runTest {
        val failingChatRepo = object : ChatMessageRepository {
            override suspend fun getMessages(cursor: Long?, limit: Int) =
                Result.Ok(emptyList<ChatMessage>())
            override suspend fun insertMessage(message: ChatMessage) =
                Result.Error<Unit>(RuntimeException("disk full"))
            override suspend fun insertMessages(messages: List<ChatMessage>) = Result.Ok(Unit)
            override suspend fun updateMessage(message: ChatMessage) = Result.Ok(Unit)
            override fun observeMessages(): Flow<List<ChatMessage>> = MutableStateFlow(emptyList())
        }
        val vm = MessagesViewModel(FakeYaloMessageRepository(), failingChatRepo)

        vm.handleEvent(MessagesEvent.SendVoiceMessage(AudioData(fileName = "voice.m4a", durationMs = 1000L)))

        assertIs<ChatStatus.Failure>(vm.state.value.chatStatus)
    }

    @Test
    fun `SendVoiceMessage marks optimistic message as ERROR when remote send fails`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val failingYaloRepo = object : YaloMessageRepository {
            override suspend fun sendMessage(message: ChatMessage) =
                Result.Error<Unit>(RuntimeException("upload failed"))
            override suspend fun fetchMessages(since: Long) = Result.Ok(emptyList<ChatMessage>())
            override fun pollIncomingMessages(): Flow<List<ChatMessage>> = emptyFlow()
            override fun events(): Flow<ChatEvent> = emptyFlow()
        }
        val vm = viewModel(yaloRepo = failingYaloRepo, chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)

        vm.handleEvent(MessagesEvent.SendVoiceMessage(AudioData(fileName = "voice.m4a", durationMs = 3000L)))

        val result = chatRepo.getMessages(null, 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(MessageStatus.ERROR, result.result.first().status)
        vm.viewModelScope.cancel()
    }

    // ── ChatToggleMessageExpand ───────────────────────────────────────────────

    @Test
    fun `ChatToggleMessageExpand toggles expand from false to true`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(id = 1L, role = MessageRole.AGENT, type = MessageType.Product,
                status = MessageStatus.DELIVERED, products = listOf(
                    Product(sku = "sku-1", name = "Apple", price = 1.0),
                ))
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)

        assertFalse(vm.state.value.messages.first().expand)

        vm.handleEvent(MessagesEvent.ChatToggleMessageExpand(messageId = 1L))

        assertTrue(vm.state.value.messages.first().expand)
    }

    @Test
    fun `ChatToggleMessageExpand toggles expand back to false on second call`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(id = 2L, role = MessageRole.AGENT, type = MessageType.Product,
                status = MessageStatus.DELIVERED, products = listOf(
                    Product(sku = "sku-1", name = "Apple", price = 1.0),
                ))
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)

        vm.handleEvent(MessagesEvent.ChatToggleMessageExpand(messageId = 2L))
        assertTrue(vm.state.value.messages.first().expand)

        vm.handleEvent(MessagesEvent.ChatToggleMessageExpand(messageId = 2L))
        assertFalse(vm.state.value.messages.first().expand)
    }

    @Test
    fun `ChatToggleMessageExpand does not affect other messages`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(id = 10L, role = MessageRole.AGENT, type = MessageType.Product,
                status = MessageStatus.DELIVERED)
        )
        chatRepo.insertMessage(
            ChatMessage(id = 11L, role = MessageRole.AGENT, type = MessageType.Product,
                status = MessageStatus.DELIVERED)
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)

        vm.handleEvent(MessagesEvent.ChatToggleMessageExpand(messageId = 10L))

        val messages = vm.state.value.messages.sortedBy { it.id }
        assertTrue(messages.first { it.id == 10L }.expand)
        assertFalse(messages.first { it.id == 11L }.expand)
    }

    // ── ChatUpdateProductQuantity ─────────────────────────────────────────────

    @Test
    fun `ChatUpdateProductQuantity updates unitsAdded on matching product`() = runTest {
        val product = Product(sku = "sku-1", name = "Apple", price = 1.0, unitsAdded = 0.0, unitStep = 1.0)
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(id = 5L, role = MessageRole.AGENT, type = MessageType.Product,
                status = MessageStatus.DELIVERED, products = listOf(product))
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)

        vm.handleEvent(
            MessagesEvent.ChatUpdateProductQuantity(
                messageId = 5L,
                productSku = "sku-1",
                unitType = UnitType.UNIT,
                quantity = 3.0,
            )
        )

        val updatedProduct = vm.state.value.messages.first().products.first()
        assertEquals(3.0, updatedProduct.unitsAdded)
    }

    @Test
    fun `ChatUpdateProductQuantity updates subunitsAdded on matching product`() = runTest {
        val product = Product(sku = "sku-2", name = "Milk", price = 2.0, subunitsAdded = 0.0, subunitStep = 0.5)
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(id = 6L, role = MessageRole.AGENT, type = MessageType.Product,
                status = MessageStatus.DELIVERED, products = listOf(product))
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)

        vm.handleEvent(
            MessagesEvent.ChatUpdateProductQuantity(
                messageId = 6L,
                productSku = "sku-2",
                unitType = UnitType.SUBUNIT,
                quantity = 1.5,
            )
        )

        val updatedProduct = vm.state.value.messages.first().products.first()
        assertEquals(1.5, updatedProduct.subunitsAdded)
        assertEquals(0.0, updatedProduct.unitsAdded)
    }

    @Test
    fun `ChatUpdateProductQuantity does not affect other products in same message`() = runTest {
        val p1 = Product(sku = "a", name = "A", price = 1.0, unitsAdded = 0.0)
        val p2 = Product(sku = "b", name = "B", price = 2.0, unitsAdded = 0.0)
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(id = 7L, role = MessageRole.AGENT, type = MessageType.Product,
                status = MessageStatus.DELIVERED, products = listOf(p1, p2))
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)

        vm.handleEvent(
            MessagesEvent.ChatUpdateProductQuantity(
                messageId = 7L,
                productSku = "a",
                unitType = UnitType.UNIT,
                quantity = 5.0,
            )
        )

        val products = vm.state.value.messages.first().products
        assertEquals(5.0, products.first { it.sku == "a" }.unitsAdded)
        assertEquals(0.0, products.first { it.sku == "b" }.unitsAdded)
    }

    @Test
    fun `ChatUpdateProductQuantity does not affect other messages`() = runTest {
        val product = Product(sku = "x", name = "X", price = 1.0, unitsAdded = 0.0)
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(id = 8L, role = MessageRole.AGENT, type = MessageType.Product,
                status = MessageStatus.DELIVERED, products = listOf(product))
        )
        chatRepo.insertMessage(
            ChatMessage(id = 9L, role = MessageRole.AGENT, type = MessageType.Product,
                status = MessageStatus.DELIVERED, products = listOf(product.copy()))
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)

        vm.handleEvent(
            MessagesEvent.ChatUpdateProductQuantity(
                messageId = 8L,
                productSku = "x",
                unitType = UnitType.UNIT,
                quantity = 10.0,
            )
        )

        val messages = vm.state.value.messages.sortedBy { it.id }
        assertEquals(10.0, messages.first { it.id == 8L }.products.first().unitsAdded)
        assertEquals(0.0, messages.first { it.id == 9L }.products.first().unitsAdded)
    }
}
