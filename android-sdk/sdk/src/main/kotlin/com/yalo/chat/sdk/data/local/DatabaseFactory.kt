// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.local

import app.cash.sqldelight.db.SqlDriver
import com.yalo.chat.sdk.database.ChatDatabase

// Factory: constructs ChatDatabase with the given platform SqlDriver.
//   Android → AndroidSqliteDriver(ChatDatabase.Schema, context, "chat.db") — wired in YaloChat.kt
//   Tests   → JdbcSqliteDriver(JdbcSqliteDriver.IN_MEMORY) with ChatDatabase.Schema.create(driver)
// JSON columns (amplitudes, products, quick_replies) are stored as TEXT and decoded
// manually in LocalChatMessageRepository using kotlinx.serialization — no ColumnAdapters needed.
// KMP note: when splitting to KMP, iosMain will provide NativeSqliteDriver.
fun createDatabase(driver: SqlDriver): ChatDatabase = ChatDatabase(driver)
