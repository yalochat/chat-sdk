// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.native.NativeSqliteDriver
import com.yalo.chat.sdk.data.MessageSyncService
import com.yalo.chat.sdk.data.local.LocalChatMessageRepository
import com.yalo.chat.sdk.data.local.createDatabase
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.YaloMessageServiceWebSocket
import com.yalo.chat.sdk.data.remote.buildHttpClient
import com.yalo.chat.sdk.data.repository.fake.FakeYaloMessageRepository
import com.yalo.chat.sdk.data.repository.remote.YaloMessageRepositoryWebSocket
import com.yalo.chat.sdk.database.ChatDatabase
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import io.ktor.client.HttpClient
import io.ktor.client.engine.darwin.Darwin
import kotlin.native.Platform
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import platform.Foundation.NSCachesDirectory
import platform.Foundation.NSFileManager
import platform.Foundation.NSURL
import platform.Foundation.NSUserDomainMask

// iOS entry point — mirrors YaloChat.kt in androidMain.
// Wires the shared commonMain business logic with iOS platform drivers:
//   - Darwin HTTP engine (URLSession) via ktor-client-darwin
//   - NativeSqliteDriver via sqldelight-native-driver
// Called from Swift by YaloChat.initialize() — see ios-sdk/YaloChatDemo/YaloChat.swift.
object YaloChatSdk {

    private var _syncService: MessageSyncService? = null
    private var _httpClient: HttpClient? = null
    private var _driver: SqlDriver? = null
    private var _wsScope: CoroutineScope? = null

    internal var yaloRepo: YaloMessageRepository? = null
        private set

    internal var localRepo: LocalChatMessageRepository? = null
        private set

    var messagesController: MessagesController? = null
        private set

    var config: YaloChatConfig? = null
        private set

    @OptIn(kotlin.experimental.ExperimentalNativeApi::class)
    fun initialize(config: YaloChatConfig) {
        // Tear down any previous instance before re-initialising (idempotent re-init).
        messagesController?.stop()
        messagesController = null
        _syncService?.stop()
        _wsScope?.cancel()
        _wsScope = null
        _httpClient?.close()
        _driver?.close()

        this.config = config

        val yaloRepo: YaloMessageRepository
        if (config.useFakeRepository) {
            yaloRepo = FakeYaloMessageRepository()
        } else {
            val httpClient = buildHttpClient(Darwin.create(), debug = Platform.isDebugBinary)
            _httpClient = httpClient

            val apiService = YaloChatApiService(
                apiBaseUrl = config.environment.apiBaseUrl,
                channelId = config.channelId,
                organizationId = config.organizationId,
                httpClient = httpClient,
            )
            // Use app-specific caches directory — mirrors Android's context.cacheDir.
            // NSTemporaryDirectory() is purged aggressively by the OS between app launches;
            // NSCachesDirectory is only cleared under storage pressure, so downloaded media
            // (images, audio, video) survives cold restarts.
            val cacheDir = (NSFileManager.defaultManager
                .URLsForDirectory(NSCachesDirectory, NSUserDomainMask)
                .firstOrNull() as? NSURL)
                ?.path
                ?.let { "$it/ChatSdk" }

            val wsUrl = "${config.environment.wsBaseUrl}$WS_CONNECT_PATH"
            val wsService = YaloMessageServiceWebSocket(
                wsUrl = wsUrl,
                apiService = apiService,
                httpClient = httpClient,
            )
            val wsRepo = YaloMessageRepositoryWebSocket(
                wsService = wsService,
                apiService = apiService,
                tempDir = cacheDir,
            )
            val wsScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
            _wsScope = wsScope
            wsRepo.start(wsScope)
            yaloRepo = wsRepo
        }
        this.yaloRepo = yaloRepo

        // NativeSqliteDriver stores the database in the app's Documents/databases/ directory.
        val driver = NativeSqliteDriver(ChatDatabase.Schema, "chat.db")
        _driver = driver
        val db = createDatabase(driver)
        val local = LocalChatMessageRepository(db.chatMessageQueries, Dispatchers.Default)
        localRepo = local

        // Sync service is started lazily by MessagesController (via MessagesObservable.onAppear),
        // mirroring how MessagesViewModel governs the polling lifecycle on Android.
        val syncSvc = MessageSyncService(
            yaloRepo = yaloRepo,
            localRepo = local,
            onSyncError = { e -> println("[YaloChatSdk] sync error: $e") },
        )
        _syncService = syncSvc

        messagesController = MessagesController(
            yaloRepo = yaloRepo,
            localRepo = local,
            syncService = syncSvc,
        )
    }

    fun stop() {
        messagesController?.stop()
        messagesController = null
        _syncService = null
        _wsScope?.cancel()
        _wsScope = null
        _httpClient?.close()
        _httpClient = null
        _driver?.close()
        _driver = null
        yaloRepo = null
        localRepo = null
        config = null
    }
}
