// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.local

import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import com.yalo.chat.sdk.database.ChatDatabase
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

// FDE-54: SQLDelight schema and query tests.
// Uses JdbcSqliteDriver (in-memory) — no Android emulator required.
class ChatMessageQueriesTest {

    private lateinit var driver: JdbcSqliteDriver
    private lateinit var db: ChatDatabase

    @BeforeTest
    fun setup() {
        driver = JdbcSqliteDriver(JdbcSqliteDriver.IN_MEMORY)
        ChatDatabase.Schema.create(driver)
        db = createDatabase(driver)
    }

    @AfterTest
    fun tearDown() {
        driver.close()
    }

    private fun insert(
        id: Long,
        role: String = "AGENT",
        content: String = "hello",
        type: String = "text",
        status: String = "DELIVERED",
        timestamp: Long = id * 1000L,
        wiId: String? = null,
    ) = db.chatMessageQueries.insertOrReplace(
        id = id,
        wi_id = wiId,
        role = role,
        content = content,
        type = type,
        status = status,
        file_name = null,
        amplitudes = null,
        duration = null,
        products = null,
        quick_replies = null,
        timestamp = timestamp,
    )

    // ── insertOrReplace + selectFirstPage ─────────────────────────────────────

    @Test
    fun `insertOrReplace then selectFirstPage returns correct row`() {
        insert(id = 1L, content = "Hello")
        val rows = db.chatMessageQueries.selectFirstPage(limit = 10).executeAsList()
        assertEquals(1, rows.size)
        assertEquals("Hello", rows.first().content)
        assertEquals("AGENT", rows.first().role)
    }

    @Test
    fun `insertOrReplace with same id overwrites previous entry`() {
        insert(id = 1L, content = "Original")
        insert(id = 1L, content = "Updated")
        val rows = db.chatMessageQueries.selectFirstPage(limit = 10).executeAsList()
        assertEquals(1, rows.size)
        assertEquals("Updated", rows.first().content)
    }

    @Test
    fun `selectFirstPage respects limit`() {
        (1L..10L).forEach { insert(id = it) }
        val rows = db.chatMessageQueries.selectFirstPage(limit = 3).executeAsList()
        assertEquals(3, rows.size)
    }

    @Test
    fun `selectFirstPage returns rows ordered newest-first`() {
        insert(id = 1L, timestamp = 1000L)
        insert(id = 2L, timestamp = 2000L)
        insert(id = 3L, timestamp = 3000L)
        val rows = db.chatMessageQueries.selectFirstPage(limit = 10).executeAsList()
        assertEquals(listOf(3L, 2L, 1L), rows.map { it.id })
    }

    // ── selectPageBefore ──────────────────────────────────────────────────────

    @Test
    fun `selectPageBefore returns correct cursor-based page`() {
        (1L..10L).forEach { insert(id = it) }
        // cursor = 6: should return ids 5, 4, 3 (3 items before 6)
        val rows = db.chatMessageQueries.selectPageBefore(cursor = 6L, limit = 3L).executeAsList()
        assertEquals(listOf(5L, 4L, 3L), rows.map { it.id })
    }

    @Test
    fun `selectPageBefore with cursor at start returns empty`() {
        (1L..5L).forEach { insert(id = it) }
        val rows = db.chatMessageQueries.selectPageBefore(cursor = 1L, limit = 10L).executeAsList()
        assertEquals(0, rows.size)
    }

    // ── observeConversation ───────────────────────────────────────────────────

    @Test
    fun `observeConversation returns rows ordered oldest-first`() {
        insert(id = 3L); insert(id = 1L); insert(id = 2L)
        val rows = db.chatMessageQueries.observeConversation().executeAsList()
        assertEquals(listOf(1L, 2L, 3L), rows.map { it.id })
    }

    // ── deleteConversation ────────────────────────────────────────────────────

    @Test
    fun `deleteConversation removes all rows`() {
        (1L..5L).forEach { insert(id = it) }
        db.chatMessageQueries.deleteConversation()
        val rows = db.chatMessageQueries.selectFirstPage(limit = 100).executeAsList()
        assertEquals(0, rows.size)
    }

    // ── nullable fields ───────────────────────────────────────────────────────

    @Test
    fun `nullable fields are stored and retrieved correctly`() {
        insert(id = 1L, wiId = "wi-abc")
        val row = db.chatMessageQueries.selectFirstPage(limit = 1).executeAsList().first()
        assertEquals("wi-abc", row.wi_id)
        assertNull(row.amplitudes)
        assertNull(row.products)
        assertNull(row.quick_replies)
    }
}
