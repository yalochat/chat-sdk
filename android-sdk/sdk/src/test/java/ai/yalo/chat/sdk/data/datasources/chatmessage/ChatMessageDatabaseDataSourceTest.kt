// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.datasources.chatmessage

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
class ChatMessageDatabaseDataSourceTest {

    private val dataSource = ChatMessageDatabaseDataSource(
        RuntimeEnvironment.getApplication(),
        name = null,
        logLevel = LogLevel.Debug,
    )

    @After
    fun closeDatabase() {
        dataSource.close()
    }

    @Test
    fun keepsTheMessagesAnOlderVersionStored() {
        val database = versionOneDatabase()

        dataSource.onUpgrade(database, 1, ChatMessageDatabaseDataSource.VERSION)

        assertEquals(listOf("Hello"), storedContent(database))
        database.close()
    }

    @Test
    fun givesAnOlderConversationSomewhereToKeepItsButtons() {
        val database = versionOneDatabase()

        dataSource.onUpgrade(database, 1, ChatMessageDatabaseDataSource.VERSION)

        database.insertOrThrow(
            ChatMessageDatabaseDataSource.MESSAGE_TABLE,
            null,
            row("Anything else?").apply {
                put(ChatMessageDatabaseDataSource.COLUMN_BUTTONS, """[{"text":"Yes"}]""")
            },
        )
        assertEquals(listOf("Hello", "Anything else?"), storedContent(database))
        database.close()
    }

    /** The schema as it was before messages could carry buttons. */
    private fun versionOneDatabase(): SQLiteDatabase = SQLiteDatabase.create(null).apply {
        execSQL(
            """
            CREATE TABLE ${ChatMessageDatabaseDataSource.MESSAGE_TABLE} (
                ${ChatMessageDatabaseDataSource.COLUMN_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
                ${ChatMessageDatabaseDataSource.COLUMN_SESSION_ID} TEXT NOT NULL,
                ${ChatMessageDatabaseDataSource.COLUMN_WI_ID} TEXT,
                ${ChatMessageDatabaseDataSource.COLUMN_ROLE} TEXT NOT NULL,
                ${ChatMessageDatabaseDataSource.COLUMN_CONTENT} TEXT NOT NULL DEFAULT '',
                ${ChatMessageDatabaseDataSource.COLUMN_TYPE} TEXT NOT NULL,
                ${ChatMessageDatabaseDataSource.COLUMN_STATUS} TEXT NOT NULL,
                ${ChatMessageDatabaseDataSource.COLUMN_TIMESTAMP} INTEGER NOT NULL,
                ${ChatMessageDatabaseDataSource.COLUMN_HEADER} TEXT,
                ${ChatMessageDatabaseDataSource.COLUMN_FOOTER} TEXT
            )
            """,
        )
        insertOrThrow(ChatMessageDatabaseDataSource.MESSAGE_TABLE, null, row("Hello"))
    }

    private fun row(content: String): ContentValues = ContentValues().apply {
        put(ChatMessageDatabaseDataSource.COLUMN_SESSION_ID, "session-id")
        put(ChatMessageDatabaseDataSource.COLUMN_ROLE, "USER")
        put(ChatMessageDatabaseDataSource.COLUMN_CONTENT, content)
        put(ChatMessageDatabaseDataSource.COLUMN_TYPE, "text")
        put(ChatMessageDatabaseDataSource.COLUMN_STATUS, "SENT")
        put(ChatMessageDatabaseDataSource.COLUMN_TIMESTAMP, 1_000L)
    }

    private fun storedContent(database: SQLiteDatabase): List<String> = database.query(
        ChatMessageDatabaseDataSource.MESSAGE_TABLE,
        arrayOf(ChatMessageDatabaseDataSource.COLUMN_CONTENT),
        null,
        null,
        null,
        null,
        ChatMessageDatabaseDataSource.COLUMN_ID,
    ).use { cursor ->
        buildList {
            while (cursor.moveToNext()) {
                add(cursor.getString(0))
            }
        }
    }
}
