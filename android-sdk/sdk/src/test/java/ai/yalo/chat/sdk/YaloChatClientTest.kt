// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

import ai.yalo.chat.sdk.common.session.sessionOf
import ai.yalo.chat.sdk.config.ChatDependencies
import ai.yalo.chat.sdk.data.datasources.chatmessage.ChatMessageDatabaseDataSource
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment

@RunWith(RobolectricTestRunner::class)
class YaloChatClientTest {

    private val config = YaloChatClientConfig(channelId = "channel", organizationId = "organization", channelName = "Support")
    private val client = YaloChatClient(config)

    @After
    fun forgetTheDatabase() {
        ChatMessageDatabaseDataSource.reset()
    }

    @Test
    fun handsBackTheHandlerRegisteredForACommand() = runBlocking {
        client.registerCommand("getStore") { payload -> "store $payload" }

        assertEquals("store 42", client.commandHandler("getStore")?.invoke("42"))
    }

    @Test
    fun keepsTheLatestHandlerForACommandRegisteredTwice() = runBlocking {
        client.registerCommand("getStore") { _ -> "first" }
        client.registerCommand("getStore") { _ -> "second" }

        assertEquals("second", client.commandHandler("getStore")?.invoke(""))
    }

    @Test
    fun hasNoHandlerForACommandNeverRegistered() {
        assertNull(client.commandHandler("getStore"))
    }

    @Test
    fun clearingDeletesTheStoredMessagesWithNoChatOpen() = runBlocking {
        val context = RuntimeEnvironment.getApplication()
        val messages = ChatDependencies(context, config, sessionOf(config)).chatMessages
        messages.insert(ChatMessage(role = MessageRole.Agent, type = MessageType.Text, timestamp = 0L, content = "Hi"))

        client.clearMessages(context)

        assertEquals(emptyList<ChatMessage>(), messages.messages().getOrThrow())
    }

    @Test
    fun clearingAnEphemeralConversationLeavesItToItsChat() = runBlocking {
        val context = RuntimeEnvironment.getApplication()
        val ephemeral = config.copy(sessionMode = SessionMode.Ephemeral)
        val messages = ChatDependencies(context, ephemeral, sessionOf(config)).chatMessages
        messages.insert(ChatMessage(role = MessageRole.Agent, type = MessageType.Text, timestamp = 0L, content = "Hi"))

        YaloChatClient(ephemeral).clearMessages(context)

        assertEquals(listOf("Hi"), messages.messages().getOrThrow().map { it.content })
    }

    @Test
    fun clearingTellsAnOpenChat() = runBlocking {
        val asked = async(start = CoroutineStart.UNDISPATCHED) { client.clearRequests.first() }

        client.clearMessages(RuntimeEnvironment.getApplication())

        assertEquals(Unit, asked.await())
    }
}
