// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.chatmessage

import ai.yalo.chat.sdk.LogLevel
import android.content.ContentValues
import android.database.sqlite.SQLiteDatabase
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment

@RunWith(RobolectricTestRunner::class)
class ChatMessageDatabaseServiceTest {

    private val service = ChatMessageDatabaseService(
        RuntimeEnvironment.getApplication(),
        name = null,
        logLevel = LogLevel.Debug,
    )

    @After
    fun closeDatabase() {
        service.close()
    }

    @Test
    fun keepsTheMessagesAnOlderVersionStored() {
        val database = versionOneDatabase()

        service.onUpgrade(database, 1, ChatMessageDatabaseService.VERSION)

        assertEquals(listOf("Hello"), storedContent(database))
        database.close()
    }

    @Test
    fun givesAnOlderConversationSomewhereToKeepItsButtons() {
        val database = versionOneDatabase()

        service.onUpgrade(database, 1, ChatMessageDatabaseService.VERSION)

        database.insertOrThrow(
            ChatMessageDatabaseService.MESSAGE_TABLE,
            null,
            row("Anything else?").apply {
                put(ChatMessageDatabaseService.COLUMN_BUTTONS, """[{"text":"Yes"}]""")
            },
        )
        assertEquals(listOf("Hello", "Anything else?"), storedContent(database))
        database.close()
    }

    /** The schema as it was before messages could carry buttons. */
    private fun versionOneDatabase(): SQLiteDatabase = SQLiteDatabase.create(null).apply {
        execSQL(
            """
            CREATE TABLE ${ChatMessageDatabaseService.MESSAGE_TABLE} (
                ${ChatMessageDatabaseService.COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
                ${ChatMessageDatabaseService.COLUMN_SESSION_ID} TEXT NOT NULL,
                ${ChatMessageDatabaseService.COLUMN_WI_ID} TEXT,
                ${ChatMessageDatabaseService.COLUMN_ROLE} TEXT NOT NULL,
                ${ChatMessageDatabaseService.COLUMN_CONTENT} TEXT NOT NULL DEFAULT '',
                ${ChatMessageDatabaseService.COLUMN_TYPE} TEXT NOT NULL,
                ${ChatMessageDatabaseService.COLUMN_STATUS} TEXT NOT NULL,
                ${ChatMessageDatabaseService.COLUMN_TIMESTAMP} INTEGER NOT NULL,
                ${ChatMessageDatabaseService.COLUMN_HEADER} TEXT,
                ${ChatMessageDatabaseService.COLUMN_FOOTER} TEXT
            )
            """,
        )
        insertOrThrow(ChatMessageDatabaseService.MESSAGE_TABLE, null, row("Hello"))
    }

    private fun row(content: String): ContentValues = ContentValues().apply {
        put(ChatMessageDatabaseService.COLUMN_SESSION_ID, "session-id")
        put(ChatMessageDatabaseService.COLUMN_ROLE, "USER")
        put(ChatMessageDatabaseService.COLUMN_CONTENT, content)
        put(ChatMessageDatabaseService.COLUMN_TYPE, "text")
        put(ChatMessageDatabaseService.COLUMN_STATUS, "SENT")
        put(ChatMessageDatabaseService.COLUMN_TIMESTAMP, 1_000L)
    }

    private fun storedContent(database: SQLiteDatabase): List<String> = database.query(
        ChatMessageDatabaseService.MESSAGE_TABLE,
        arrayOf(ChatMessageDatabaseService.COLUMN_CONTENT),
        null,
        null,
        null,
        null,
        ChatMessageDatabaseService.COLUMN_ID,
    ).use { cursor ->
        buildList {
            while (cursor.moveToNext()) {
                add(cursor.getString(0))
            }
        }
    }
}
