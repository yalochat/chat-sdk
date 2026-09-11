// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.repositories.chatmessage

import ai.yalo.chat.sdk.data.services.chatmessage.ChatMessageDatabaseService
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageStatus
import ai.yalo.chat.sdk.domain.models.MessageType
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment

@RunWith(RobolectricTestRunner::class)
class ChatMessageRepositoryLocalTest {

    private val database = ChatMessageDatabaseService(RuntimeEnvironment.getApplication(), name = null)

    @After
    fun closeDatabase() {
        database.close()
    }

    @Test
    fun givesAStoredMessageAnIdItDidNotHaveBefore() = runBlocking {
        val stored = repository().insert(userMessage("Hello")).getOrThrow()

        assertNotNull(stored.id)
        assertEquals("Hello", stored.content)
    }

    @Test
    fun readsBackEverythingItWasGiven() = runBlocking {
        val repository = repository()
        repository.insert(
            ChatMessage(
                role = MessageRole.Agent,
                type = MessageType.Text,
                timestamp = 1_000L,
                wiId = "wi-1",
                content = "How can I help?",
                status = MessageStatus.Delivered,
                header = "Support",
                footer = "Powered by Yalo",
            ),
        )

        val read = repository.messages().getOrThrow().single()

        assertEquals(
            listOf(
                MessageRole.Agent,
                MessageType.Text,
                1_000L,
                "wi-1",
                "How can I help?",
                MessageStatus.Delivered,
                "Support",
                "Powered by Yalo",
            ),
            listOf(
                read.role,
                read.type,
                read.timestamp,
                read.wiId,
                read.content,
                read.status,
                read.header,
                read.footer,
            ),
        )
    }

    @Test
    fun leavesOutWhatTheMessageNeverHad() = runBlocking {
        val read = repository().insert(userMessage("Hi")).let { repository().messages().getOrThrow().single() }

        assertNull(read.wiId)
        assertNull(read.header)
        assertNull(read.footer)
    }

    @Test
    fun showsTheNewestMessageFirst() = runBlocking {
        val repository = repository()
        repository.insert(userMessage("First", timestamp = 1_000L))
        repository.insert(userMessage("Second", timestamp = 2_000L))
        repository.insert(userMessage("Third", timestamp = 3_000L))

        val read = repository.messages().getOrThrow()

        assertEquals(listOf("Third", "Second", "First"), read.map { it.content })
    }

    @Test
    fun readsNoMoreThanItWasAskedFor() = runBlocking {
        val repository = repository()
        repository.insert(userMessage("First", timestamp = 1_000L))
        repository.insert(userMessage("Second", timestamp = 2_000L))

        val read = repository.messages(limit = 1).getOrThrow()

        assertEquals(listOf("Second"), read.map { it.content })
    }

    @Test
    fun storesAMessageFromTheBackendOnlyOnce() = runBlocking {
        val repository = repository()
        val first = repository.insert(agentMessage("Hello", wiId = "wi-1")).getOrThrow()

        val second = repository.insert(agentMessage("Hello", wiId = "wi-1")).getOrThrow()

        assertEquals(first.id, second.id)
        assertEquals(1, repository.messages().getOrThrow().size)
    }

    @Test
    fun storesEveryMessageTheUserWritesEvenWhenTheyReadTheSame() = runBlocking {
        val repository = repository()
        repository.insert(userMessage("Hello"))
        repository.insert(userMessage("Hello"))

        assertEquals(2, repository.messages().getOrThrow().size)
    }

    @Test
    fun keepsTheSameBackendIdApartAcrossConversations() = runBlocking {
        val support = repository("support-session")
        val sales = repository("sales-session")

        support.insert(agentMessage("Support says hi", wiId = "wi-1"))
        sales.insert(agentMessage("Sales says hi", wiId = "wi-1"))

        assertEquals(listOf("Support says hi"), support.messages().getOrThrow().map { it.content })
        assertEquals(listOf("Sales says hi"), sales.messages().getOrThrow().map { it.content })
    }

    @Test
    fun forgetsOnlyTheConversationItWasAskedAbout() = runBlocking {
        val support = repository("support-session")
        val sales = repository("sales-session")
        support.insert(userMessage("Support draft"))
        sales.insert(userMessage("Sales draft"))

        support.clearSession()

        assertEquals(emptyList<String>(), support.messages().getOrThrow().map { it.content })
        assertEquals(listOf("Sales draft"), sales.messages().getOrThrow().map { it.content })
    }

    @Test
    fun readsBackATypeItDoesNotKnowAsUnknown() = runBlocking {
        val repository = repository()
        repository.insert(
            userMessage("Hi").copy(type = MessageType.Promotion),
        )

        assertEquals(MessageType.Promotion, repository.messages().getOrThrow().single().type)
    }

    @Test
    fun reportsStorageBreakingInsteadOfThrowing() = runBlocking {
        val repository = repository()
        database.writableDatabase.execSQL("DROP TABLE ${ChatMessageDatabaseService.MESSAGE_TABLE}")

        val inserted = repository.insert(userMessage("Hello"))
        val read = repository.messages()

        assertTrue(inserted.isFailure)
        assertTrue(read.isFailure)
    }

    private fun repository(sessionId: String = "session-id") = ChatMessageRepositoryLocal(
        database = database,
        sessionId = sessionId,
        dispatcher = Dispatchers.Unconfined,
    )

    private fun userMessage(content: String, timestamp: Long = 1_000L) = ChatMessage(
        role = MessageRole.User,
        type = MessageType.Text,
        timestamp = timestamp,
        content = content,
    )

    private fun agentMessage(content: String, wiId: String) = ChatMessage(
        role = MessageRole.Agent,
        type = MessageType.Text,
        timestamp = 1_000L,
        wiId = wiId,
        content = content,
    )
}
