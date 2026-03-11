// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import app.cash.sqldelight.driver.android.AndroidSqliteDriver
import com.yalo.chat.sdk.data.MessageSyncService
import com.yalo.chat.sdk.data.local.LocalChatMessageRepository
import com.yalo.chat.sdk.data.local.createDatabase
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.buildHttpClient
import com.yalo.chat.sdk.data.repository.remote.YaloMessageRepositoryRemote
import com.yalo.chat.sdk.database.ChatDatabase
import com.yalo.chat.sdk.ui.chat.MessagesViewModel
import io.ktor.client.HttpClient
import io.ktor.client.engine.android.Android
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel

// Port of flutter-sdk YaloChat entry point.
// Phase 2 M2: wires SQLDelight persistence via LocalChatMessageRepository and
// MessageSyncService, replacing FakeChatMessageRepository.
object YaloChat {

    private var _config: YaloChatConfig? = null
    private var _viewModelFactory: ViewModelProvider.Factory? = null
    private var _httpClient: HttpClient? = null
    private var _sdkScope: CoroutineScope? = null
    private var _syncService: MessageSyncService? = null

    val config: YaloChatConfig
        get() = _config ?: error("YaloChat.init() must be called before accessing config")

    // context: needed to construct AndroidSqliteDriver for the local SQLite database.
    // KMP note: when splitting to KMP, YaloChat.kt moves to androidMain; iosMain
    // counterpart will provide NativeSqliteDriver without a Context.
    fun init(config: YaloChatConfig, context: Context) {
        // Tear down any previous instance before re-initialising (idempotent re-init).
        _syncService?.stop()
        _sdkScope?.cancel()
        _httpClient?.close()

        _config = config

        val httpClient = buildHttpClient(Android.create(), debug = BuildConfig.DEBUG)
        _httpClient = httpClient

        val apiService = YaloChatApiService(
            apiBaseUrl = config.apiBaseUrl,
            authToken = config.authToken,
            userToken = config.userToken,
            flowKey = config.flowKey,
            httpClient = httpClient,
        )
        val yaloRepo = YaloMessageRepositoryRemote(apiService)

        val driver = AndroidSqliteDriver(ChatDatabase.Schema, context.applicationContext, "chat.db")
        val db = createDatabase(driver)
        val localRepo = LocalChatMessageRepository(db.chatMessageQueries)

        // SDK-owned scope: lives for the duration of the SDK session.
        // SupervisorJob so MessageSyncService failure doesn't cancel the whole scope.
        val sdkScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        _sdkScope = sdkScope

        val syncService = MessageSyncService(yaloRepo, localRepo)
        _syncService = syncService
        syncService.start(sdkScope)

        _viewModelFactory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                require(modelClass.isAssignableFrom(MessagesViewModel::class.java)) {
                    "Unsupported ViewModel class: $modelClass"
                }
                return MessagesViewModel(yaloRepo, localRepo) as T
            }
        }
    }

    fun getViewModelFactory(): ViewModelProvider.Factory =
        _viewModelFactory ?: error("YaloChat.init() must be called before rendering ChatScreen")
}
