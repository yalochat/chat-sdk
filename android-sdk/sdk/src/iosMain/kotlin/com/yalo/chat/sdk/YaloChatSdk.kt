// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import app.cash.sqldelight.driver.native.NativeSqliteDriver
import com.yalo.chat.sdk.data.MessageSyncService
import com.yalo.chat.sdk.data.local.LocalChatMessageRepository
import com.yalo.chat.sdk.data.local.createDatabase
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.buildHttpClient
import com.yalo.chat.sdk.data.repository.remote.YaloMessageRepositoryRemote
import com.yalo.chat.sdk.database.ChatDatabase
import io.ktor.client.engine.darwin.Darwin
import kotlinx.coroutines.Dispatchers
import platform.Foundation.NSTemporaryDirectory

// iOS entry point — mirrors YaloChat.kt in androidMain.
// Wires the shared commonMain business logic with iOS platform drivers:
//   - Darwin HTTP engine (URLSession) via ktor-client-darwin
//   - NativeSqliteDriver via sqldelight-native-driver
// Called from Swift by YaloChat.initialize() — see ios-sdk/YaloChatDemo/YaloChat.swift.
object YaloChatSdk {

    private var syncService: MessageSyncService? = null

    internal var yaloRepo: YaloMessageRepositoryRemote? = null
        private set

    internal var localRepo: LocalChatMessageRepository? = null
        private set

    val config: YaloChatConfig?
        get() = _config

    private var _config: YaloChatConfig? = null

    fun initialize(config: YaloChatConfig) {
        // Tear down any previous instance before re-initialising (idempotent re-init).
        syncService?.stop()

        _config = config

        val httpClient = buildHttpClient(Darwin.create(), debug = false)
        val apiService = YaloChatApiService(
            apiBaseUrl = config.apiBaseUrl,
            channelId = config.channelId,
            organizationId = config.organizationId,
            httpClient = httpClient,
        )
        val repo = YaloMessageRepositoryRemote(
            apiService = apiService,
            tempDir = NSTemporaryDirectory(),
        )
        yaloRepo = repo

        // NativeSqliteDriver stores the database in the app's Documents/databases/ directory.
        val driver = NativeSqliteDriver(ChatDatabase.Schema, "chat.db")
        val db = createDatabase(driver)
        val local = LocalChatMessageRepository(db.chatMessageQueries, Dispatchers.Default)
        localRepo = local

        // Sync service is started lazily by the Swift presentation layer, mirroring how
        // MessagesViewModel governs the polling lifecycle on Android.
        syncService = MessageSyncService(
            yaloRepo = repo,
            localRepo = local,
            onSyncError = { e -> println("[YaloChatSdk] sync error: $e") },
        )
    }

    fun stop() {
        syncService?.stop()
        syncService = null
        yaloRepo = null
        localRepo = null
        _config = null
    }
}
