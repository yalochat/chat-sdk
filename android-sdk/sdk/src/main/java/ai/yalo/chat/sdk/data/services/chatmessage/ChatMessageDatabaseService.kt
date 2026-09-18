// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.data.services.chatmessage

import ai.yalo.chat.sdk.LogLevel
import ai.yalo.chat.sdk.log.YaloLog
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

/**
 * Stores messages, however many chats an app shows. Rows carry the session they
 * belong to, so there is one schema to migrate and one connection to open.
 *
 * The columns follow the web SDK's message model, minus the collection valued
 * fields it keeps for richer messages, which have no model here yet. The one
 * exception is [COLUMN_BUTTONS], which holds a message's options as JSON
 * because they are read and written whole and are never searched on.
 */
internal class ChatMessageDatabaseService(
    context: Context,
    name: String? = NAME,
    logLevel: LogLevel = LogLevel.Warn,
) : SQLiteOpenHelper(context.applicationContext, name, null, VERSION) {

    private val log = YaloLog(LOG_NAME, logLevel)

    override fun onCreate(db: SQLiteDatabase) {
        log.info { "creating the message store at version $VERSION" }
        db.execSQL(CREATE_MESSAGE_TABLE)
        db.execSQL(CREATE_SESSION_WI_ID_INDEX)
        db.execSQL(CREATE_SESSION_TIMESTAMP_INDEX)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        log.info { "migrating the message store from version $oldVersion to $newVersion" }
        if (oldVersion < 2) {
            db.execSQL("ALTER TABLE $MESSAGE_TABLE ADD COLUMN $COLUMN_BUTTONS TEXT")
        }
    }

    companion object {

        @Volatile
        private var shared: ChatMessageDatabaseService? = null

        /**
         * The one instance every chat writes through. Several helpers on the
         * same file would each hold their own connection and their own idea of
         * the schema version.
         *
         * Because it is shared, [logLevel] is the one the first chat asked for.
         */
        fun of(context: Context, logLevel: LogLevel = LogLevel.Warn): ChatMessageDatabaseService =
            shared ?: synchronized(this) {
                shared ?: ChatMessageDatabaseService(
                    context.applicationContext,
                    logLevel = logLevel,
                ).also { shared = it }
            }

        /** Closes the shared instance and forgets it, so a test starts clean. */
        fun reset() {
            synchronized(this) {
                shared?.close()
                shared = null
            }
        }

        private const val LOG_NAME = "Database"

        const val NAME: String = "yalo_chat.db"
        const val VERSION: Int = 2

        const val MESSAGE_TABLE: String = "chat_message"

        const val COLUMN_ID: String = "id"
        const val COLUMN_SESSION_ID: String = "session_id"
        const val COLUMN_WI_ID: String = "wi_id"
        const val COLUMN_ROLE: String = "role"
        const val COLUMN_CONTENT: String = "content"
        const val COLUMN_TYPE: String = "type"
        const val COLUMN_STATUS: String = "status"
        const val COLUMN_TIMESTAMP: String = "timestamp"
        const val COLUMN_HEADER: String = "header"
        const val COLUMN_FOOTER: String = "footer"
        const val COLUMN_BUTTONS: String = "buttons"

        private const val CREATE_MESSAGE_TABLE = """
            CREATE TABLE $MESSAGE_TABLE (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_SESSION_ID TEXT NOT NULL,
                $COLUMN_WI_ID TEXT,
                $COLUMN_ROLE TEXT NOT NULL,
                $COLUMN_CONTENT TEXT NOT NULL DEFAULT '',
                $COLUMN_TYPE TEXT NOT NULL,
                $COLUMN_STATUS TEXT NOT NULL,
                $COLUMN_TIMESTAMP INTEGER NOT NULL,
                $COLUMN_HEADER TEXT,
                $COLUMN_FOOTER TEXT,
                $COLUMN_BUTTONS TEXT
            )
        """

        // Backend ids repeat across sessions, so the pair is what has to be
        // unique. SQLite treats nulls as distinct, so a message with no backend
        // id yet is free to be stored as many times as it is sent.
        private const val CREATE_SESSION_WI_ID_INDEX = """
            CREATE UNIQUE INDEX index_${MESSAGE_TABLE}_session_wi_id
            ON $MESSAGE_TABLE ($COLUMN_SESSION_ID, $COLUMN_WI_ID)
        """

        private const val CREATE_SESSION_TIMESTAMP_INDEX = """
            CREATE INDEX index_${MESSAGE_TABLE}_session_timestamp
            ON $MESSAGE_TABLE ($COLUMN_SESSION_ID, $COLUMN_TIMESTAMP)
        """
    }
}
