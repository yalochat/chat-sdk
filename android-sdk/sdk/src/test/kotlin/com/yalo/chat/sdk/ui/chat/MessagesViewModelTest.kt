// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.data.repository.fake.FakeChatMessageRepository
import com.yalo.chat.sdk.data.repository.fake.FakeYaloMessageRepository
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.repository.ChatMessageRepository
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flowOf
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
import kotlin.test.assertIs
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class MessagesViewModelTest {

    private val dispatcher = UnconfinedTestDispatcher()

    @BeforeTest
    fun setup() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterTest
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun viewModel(
        yaloRepo: YaloMessageRepository = FakeYaloMessageRepository(),
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
            override suspend fun updateMessage(message: ChatMessage) = Result.Ok(Unit)
            override fun observeMessages(): Flow<List<ChatMessage>> = MutableStateFlow(emptyList())
        }
        val vm = MessagesViewModel(FakeYaloMessageRepository(), failingChatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)
        assertIs<ChatStatus.Failure>(vm.state.value.chatStatus)
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
    fun `SendTextMessage on send error marks message as ERROR`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val failingSendRepo = object : YaloMessageRepository {
            override suspend fun sendMessage(message: ChatMessage) =
                Result.Error<Unit>(RuntimeException("send failed"))
            override suspend fun fetchMessages(since: Long) =
                Result.Ok(emptyList<ChatMessage>())
            override fun pollIncomingMessages() = emptyFlow<ChatMessage>()
        }
        val vm = viewModel(yaloRepo = failingSendRepo, chatRepo = chatRepo)
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
    fun `SubscribeToMessages updates state when messages are inserted`() = runTest {
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

    // ── Phase 2 — Remote polling ───────────────────────────────────────────────

    @Test
    fun `SubscribeToMessages inserts polled remote messages into state`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        val pollingYaloRepo = object : YaloMessageRepository {
            override suspend fun sendMessage(message: ChatMessage) = Result.Ok(Unit)
            override suspend fun fetchMessages(since: Long) = Result.Ok(emptyList<ChatMessage>())
            override fun pollIncomingMessages() = flowOf(
                ChatMessage(
                    role = MessageRole.AGENT, type = MessageType.Text,
                    status = MessageStatus.DELIVERED, content = "from server",
                )
            )
        }
        val vm = MessagesViewModel(pollingYaloRepo, chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)
        assertEquals(1, vm.state.value.messages.size)
        assertEquals("from server", vm.state.value.messages.first().content)
        vm.viewModelScope.cancel()
    }
}
