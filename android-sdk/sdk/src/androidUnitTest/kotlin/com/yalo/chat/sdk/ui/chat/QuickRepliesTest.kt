// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.lifecycle.viewModelScope
import com.yalo.chat.sdk.data.repository.fake.FakeChatMessageRepository
import com.yalo.chat.sdk.data.repository.fake.FakeYaloMessageRepository
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import kotlinx.coroutines.cancel
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
import kotlin.test.assertTrue

// Unit tests for the QuickReplies composable contract at the ViewModel layer.
// The composable itself (QuickReplies.kt) shows/hides based on MessagesState.quickReplies
// and delegates chip tap to two events: SendTextMessage then ClearQuickReplies.
// These tests verify that contract without a Compose test harness.
@OptIn(ExperimentalCoroutinesApi::class)
class QuickRepliesTest {

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
        chatRepo: FakeChatMessageRepository = FakeChatMessageRepository(),
    ) = MessagesViewModel(FakeYaloMessageRepository(), chatRepo).also { trackedVms.add(it) }

    // ── Visibility contract ───────────────────────────────────────────────────

    @Test
    fun `quickReplies is empty by default — chip row is hidden`() = runTest {
        val vm = viewModel()
        assertTrue(vm.state.value.quickReplies.isEmpty())
    }

    @Test
    fun `quickReplies is non-empty after loading a QuickReply message — chip row is visible`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(
                id = 1L, wiId = "qr-wi-1", role = MessageRole.AGENT, type = MessageType.QuickReply,
                status = MessageStatus.DELIVERED, content = "Pick an option:",
                quickReplies = listOf("Yes", "No", "Maybe"),
            )
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)
        assertEquals(listOf("Yes", "No", "Maybe"), vm.state.value.quickReplies)
    }

    // ── Chip tap contract ─────────────────────────────────────────────────────

    // Mirrors the ChatScreen chip tap handler:
    //   viewModel.handleEvent(MessagesEvent.SendTextMessage(text))
    //   viewModel.handleEvent(MessagesEvent.ClearQuickReplies)
    @Test
    fun `chip tap — SendTextMessage then ClearQuickReplies sends the text and clears the row`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(
                id = 1L, wiId = "qr-wi-1", role = MessageRole.AGENT, type = MessageType.QuickReply,
                status = MessageStatus.DELIVERED, content = "Pick:",
                quickReplies = listOf("Track order", "Cancel order"),
            )
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.SubscribeToMessages)
        vm.handleEvent(MessagesEvent.LoadMessages)

        // Simulate chip tap: same event sequence as ChatScreen.
        vm.handleEvent(MessagesEvent.SendTextMessage("Track order"))
        vm.handleEvent(MessagesEvent.ClearQuickReplies)

        val state = vm.state.value
        // Text message was sent.
        val userMessage = state.messages.firstOrNull { it.role == MessageRole.USER }
        assertEquals("Track order", userMessage?.content)
        assertEquals(MessageType.Text, userMessage?.type)
        // Chip row is now hidden.
        assertTrue(state.quickReplies.isEmpty())
    }

    @Test
    fun `chip tap — quickReplies is empty after ClearQuickReplies regardless of which chip was tapped`() = runTest {
        val chatRepo = FakeChatMessageRepository()
        chatRepo.insertMessage(
            ChatMessage(
                id = 1L, wiId = "qr-wi-1", role = MessageRole.AGENT, type = MessageType.QuickReply,
                status = MessageStatus.DELIVERED, content = "How can I help?",
                quickReplies = listOf("Option A", "Option B", "Option C"),
            )
        )
        val vm = viewModel(chatRepo = chatRepo)
        vm.handleEvent(MessagesEvent.LoadMessages)
        assertEquals(3, vm.state.value.quickReplies.size)

        vm.handleEvent(MessagesEvent.SendTextMessage("Option B"))
        vm.handleEvent(MessagesEvent.ClearQuickReplies)

        assertTrue(vm.state.value.quickReplies.isEmpty())
    }
}
