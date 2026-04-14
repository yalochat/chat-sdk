// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.local

import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.database.ChatDatabase
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageStatus
import com.yalo.chat.sdk.domain.model.MessageType
import com.yalo.chat.sdk.domain.model.CtaButton
import com.yalo.chat.sdk.domain.model.Product
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs

// FDE-55: LocalChatMessageRepository tests.
// Uses JdbcSqliteDriver (in-memory) — no Android emulator required.
@OptIn(ExperimentalCoroutinesApi::class)
class LocalChatMessageRepositoryTest {

    private val dispatcher = UnconfinedTestDispatcher()
    private lateinit var driver: JdbcSqliteDriver
    private lateinit var repo: LocalChatMessageRepository

    @BeforeTest
    fun setup() {
        Dispatchers.setMain(dispatcher)
        driver = JdbcSqliteDriver(JdbcSqliteDriver.IN_MEMORY)
        ChatDatabase.Schema.create(driver)
        val db = createDatabase(driver)
        repo = LocalChatMessageRepository(db.chatMessageQueries, ioDispatcher = dispatcher)
    }

    @AfterTest
    fun tearDown() {
        Dispatchers.resetMain()
        driver.close()
    }

    private fun msg(id: Long, content: String = "msg $id", timestamp: Long = id * 1000L) =
        ChatMessage(
            id = id,
            role = MessageRole.AGENT,
            type = MessageType.Text,
            status = MessageStatus.DELIVERED,
            content = content,
            timestamp = timestamp,
        )

    // ── insertMessage + getMessages ───────────────────────────────────────────

    @Test
    fun `insertMessage then getMessages returns message`() = runTest {
        assertIs<Result.Ok<Unit>>(repo.insertMessage(msg(1L, "Hello")))
        val result = repo.getMessages(cursor = null, limit = 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(1, result.result.size)
        assertEquals("Hello", result.result.first().content)
    }

    @Test
    fun `getMessages first page returns most recent messages`() = runTest {
        (1L..5L).forEach { repo.insertMessage(msg(it)) }
        val result = repo.getMessages(cursor = null, limit = 3)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        // selectFirstPage orders newest-first; limit 3 returns ids 5, 4, 3
        assertEquals(listOf(5L, 4L, 3L), result.result.map { it.id })
    }

    @Test
    fun `getMessages cursor page returns correct window`() = runTest {
        // Insert 50 messages, request page of 20 before id=31 → ids 30..11
        (1L..50L).forEach { repo.insertMessage(msg(it)) }
        val result = repo.getMessages(cursor = 31L, limit = 20)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(20, result.result.size)
        assertEquals(30L, result.result.first().id)
        assertEquals(11L, result.result.last().id)
    }

    // ── insertMessages (batch) ────────────────────────────────────────────────

    @Test
    fun `insertMessages inserts all messages in one call`() = runTest {
        val batch = (1L..5L).map { msg(it) }
        assertIs<Result.Ok<Unit>>(repo.insertMessages(batch))
        val result = repo.getMessages(cursor = null, limit = 10)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(5, result.result.size)
    }

    // ── observeMessages ───────────────────────────────────────────────────────

    @Test
    fun `observeMessages emits updated list after insert`() = runTest {
        repo.insertMessage(msg(1L, "First"))
        val messages = repo.observeMessages().first()
        assertEquals(1, messages.size)
        assertEquals("First", messages.first().content)
    }

    @Test
    fun `observeMessages returns messages ordered oldest-first`() = runTest {
        repo.insertMessage(msg(3L)); repo.insertMessage(msg(1L)); repo.insertMessage(msg(2L))
        val messages = repo.observeMessages().first()
        assertEquals(listOf(1L, 2L, 3L), messages.map { it.id })
    }

    // ── JSON columns round-trip ───────────────────────────────────────────────

    @Test
    fun `quickReplies round-trip through JSON column`() = runTest {
        val message = ChatMessage(
            id = 1L,
            role = MessageRole.AGENT,
            type = MessageType.QuickReply,
            status = MessageStatus.DELIVERED,
            content = "Pick one:",
            quickReplies = listOf("Yes", "No", "Maybe"),
        )
        repo.insertMessage(message)
        val result = repo.getMessages(cursor = null, limit = 1)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(listOf("Yes", "No", "Maybe"), result.result.first().quickReplies)
    }

    @Test
    fun `products round-trip through JSON column`() = runTest {
        val product = Product(sku = "sku-1", name = "Widget", price = 9.99)
        val message = ChatMessage(
            id = 1L,
            role = MessageRole.AGENT,
            type = MessageType.Product,
            status = MessageStatus.DELIVERED,
            content = "",
            products = listOf(product),
        )
        repo.insertMessage(message)
        val result = repo.getMessages(cursor = null, limit = 1)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val stored = result.result.first().products
        assertEquals(1, stored.size)
        assertEquals("sku-1", stored.first().sku)
        assertEquals("Widget", stored.first().name)
        assertEquals(9.99, stored.first().price)
    }

    @Test
    fun `amplitudes round-trip through JSON column`() = runTest {
        val message = ChatMessage(
            id = 1L,
            role = MessageRole.USER,
            type = MessageType.Voice,
            status = MessageStatus.SENT,
            content = "",
            amplitudes = listOf(0.1, 0.5, 0.9),
            duration = 3000L,
        )
        repo.insertMessage(message)
        val result = repo.getMessages(cursor = null, limit = 1)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(listOf(0.1, 0.5, 0.9), result.result.first().amplitudes)
    }

    // ── updateMessage ─────────────────────────────────────────────────────────

    @Test
    fun `updateMessage changes status of existing message`() = runTest {
        repo.insertMessage(msg(1L))
        repo.updateMessage(msg(1L).copy(status = MessageStatus.READ))
        val result = repo.getMessages(cursor = null, limit = 1)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        assertEquals(MessageStatus.READ, result.result.first().status)
    }

    // ── Buttons message round-trip ────────────────────────────────────────────

    @Test
    fun `buttons message round-trips header, footer and button labels through DB`() = runTest {
        val message = ChatMessage(
            id = 1L,
            wiId = "buttons-wi-1",
            role = MessageRole.AGENT,
            type = MessageType.Buttons,
            status = MessageStatus.DELIVERED,
            content = "Pick an option:",
            header = "Order help",
            footer = "Tap any option",
            buttons = listOf("Track order", "Cancel order", "Contact support"),
            timestamp = 1000L,
        )
        repo.insertMessage(message)
        val result = repo.getMessages(cursor = null, limit = 1)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val loaded = result.result.first()
        assertEquals(MessageType.Buttons, loaded.type)
        assertEquals("Order help", loaded.header)
        assertEquals("Tap any option", loaded.footer)
        assertEquals(listOf("Track order", "Cancel order", "Contact support"), loaded.buttons)
        assertEquals("Pick an option:", loaded.content)
    }

    @Test
    fun `buttons message with null header and footer round-trips without error`() = runTest {
        val message = ChatMessage(
            id = 2L,
            role = MessageRole.AGENT,
            type = MessageType.Buttons,
            status = MessageStatus.DELIVERED,
            content = "Choose:",
            buttons = listOf("Yes", "No"),
            timestamp = 2000L,
        )
        repo.insertMessage(message)
        val result = repo.getMessages(cursor = null, limit = 1)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val loaded = result.result.first()
        assertEquals(null, loaded.header)
        assertEquals(null, loaded.footer)
        assertEquals(listOf("Yes", "No"), loaded.buttons)
    }

    // ── CTA message round-trip ────────────────────────────────────────────────

    @Test
    fun `CTA message round-trips header, footer and ctaButtons through DB`() = runTest {
        val message = ChatMessage(
            id = 3L,
            wiId = "cta-wi-1",
            role = MessageRole.AGENT,
            type = MessageType.CTA,
            status = MessageStatus.DELIVERED,
            content = "Check out our catalog",
            header = "Shop now",
            footer = "Limited time offer",
            ctaButtons = listOf(
                CtaButton(text = "View Catalog", url = "https://example.com/catalog"),
                CtaButton(text = "View Promotions", url = "https://example.com/promos"),
            ),
            timestamp = 3000L,
        )
        repo.insertMessage(message)
        val result = repo.getMessages(cursor = null, limit = 1)
        assertIs<Result.Ok<List<ChatMessage>>>(result)
        val loaded = result.result.first()
        assertEquals(MessageType.CTA, loaded.type)
        assertEquals("Shop now", loaded.header)
        assertEquals("Limited time offer", loaded.footer)
        assertEquals(2, loaded.ctaButtons.size)
        assertEquals("View Catalog", loaded.ctaButtons[0].text)
        assertEquals("https://example.com/catalog", loaded.ctaButtons[0].url)
        assertEquals("View Promotions", loaded.ctaButtons[1].text)
    }
}
