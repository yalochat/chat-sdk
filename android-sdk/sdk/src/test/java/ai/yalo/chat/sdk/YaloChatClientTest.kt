// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk

import ai.yalo.chat.sdk.common.session.sessionOf
import ai.yalo.chat.sdk.config.ChatDependencies
import ai.yalo.chat.sdk.data.datasources.chatmessage.ChatMessageDatabaseDataSource
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepository
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import java.io.File

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
    fun clearingDeletesTheMessagesOfEveryConversationWithNoChatOpen() = runBlocking {
        val context = RuntimeEnvironment.getApplication()
        val sales = config.copy(channelId = "sales")
        val support = storedMessages(config)
        val other = storedMessages(sales)

        client.clearMessages(context)

        assertEquals(emptyList<ChatMessage>(), support.messages().getOrThrow())
        assertEquals(emptyList<ChatMessage>(), other.messages().getOrThrow())
    }

    @Test
    fun clearingDeletesAnEphemeralConversationToo() = runBlocking {
        val ephemeral = config.copy(sessionMode = SessionMode.Ephemeral)
        val messages = storedMessages(ephemeral)

        YaloChatClient(ephemeral).clearMessages(RuntimeEnvironment.getApplication())

        assertEquals(emptyList<ChatMessage>(), messages.messages().getOrThrow())
    }

    @Test
    fun clearingDeletesTheFilesTheConversationsKept() = runBlocking {
        val context = RuntimeEnvironment.getApplication()
        val sessionsDir = ChatDependencies(context, config, sessionOf(config)).sessionsDir
        val picture = File(sessionsDir, "some-session/images/picture.jpg")
        picture.parentFile?.mkdirs()
        picture.writeText("picture")

        client.clearMessages(context)

        assertFalse(sessionsDir.exists())
    }

    @Test
    fun clearingTellsEveryOpenChat() = runBlocking {
        val asked = async(start = CoroutineStart.UNDISPATCHED) {
            YaloChatClient(config.copy(channelId = "sales")).clearRequests.first()
        }

        client.clearMessages(RuntimeEnvironment.getApplication())

        assertEquals(ClearRequest.Messages, asked.await())
    }

    @Test
    fun loggingOutDeletesTheMessagesOfEveryConversation() = runBlocking {
        val messages = storedMessages(config)

        client.logout(RuntimeEnvironment.getApplication())

        assertEquals(emptyList<ChatMessage>(), messages.messages().getOrThrow())
    }

    @Test
    fun loggingOutTellsEveryOpenChatToStartOver() = runBlocking {
        val asked = async(start = CoroutineStart.UNDISPATCHED) { client.clearRequests.first() }

        client.logout(RuntimeEnvironment.getApplication())

        assertEquals(ClearRequest.Logout, asked.await())
    }

    private suspend fun storedMessages(config: YaloChatClientConfig): ChatMessageRepository {
        val messages = ChatDependencies(RuntimeEnvironment.getApplication(), config, sessionOf(config)).chatMessages
        messages.insert(ChatMessage(role = MessageRole.Agent, type = MessageType.Text, timestamp = 0L, content = "Hi"))
        return messages
    }
}
