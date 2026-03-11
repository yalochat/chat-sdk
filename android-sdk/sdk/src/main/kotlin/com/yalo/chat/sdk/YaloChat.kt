// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.android.AndroidSqliteDriver
import com.yalo.chat.sdk.data.MessageSyncService
import com.yalo.chat.sdk.data.local.ImageRepositoryLocal
import com.yalo.chat.sdk.domain.repository.ImagePickerRepository
import com.yalo.chat.sdk.data.local.LocalChatMessageRepository
import com.yalo.chat.sdk.data.local.createDatabase
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.buildHttpClient
import com.yalo.chat.sdk.data.repository.remote.YaloMessageRepositoryRemote
import com.yalo.chat.sdk.database.ChatDatabase
import com.yalo.chat.sdk.ui.chat.ImageViewModel
import com.yalo.chat.sdk.ui.chat.MessagesViewModel
import io.ktor.client.HttpClient
import io.ktor.client.engine.android.Android

// Port of flutter-sdk YaloChat entry point.
// Phase 2 M3: adds ImageRepositoryLocal and ImageViewModel to the factory.
object YaloChat {

    private var _config: YaloChatConfig? = null
    private var _viewModelFactory: ViewModelProvider.Factory? = null
    private var _httpClient: HttpClient? = null
    private var _driver: SqlDriver? = null
    private var _syncService: MessageSyncService? = null

    val config: YaloChatConfig
        get() = _config ?: error("YaloChat.init() must be called before accessing config")

    // context: needed to construct AndroidSqliteDriver for the local SQLite database,
    // and ImageRepositoryLocal for the FileProvider / content resolver.
    // KMP note: when splitting to KMP, YaloChat.kt moves to androidMain; iosMain
    // counterpart will provide NativeSqliteDriver without a Context.
    fun init(config: YaloChatConfig, context: Context) {
        // Tear down any previous instance before re-initialising (idempotent re-init).
        _syncService?.stop()
        _httpClient?.close()
        _driver?.close()

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
        _driver = driver
        val db = createDatabase(driver)
        val localRepo = LocalChatMessageRepository(db.chatMessageQueries)

        // Sync service is started lazily by MessagesViewModel.subscribeToMessages() so that
        // background polling only runs while the chat UI is active, not for the entire
        // process lifetime. The ViewModel scope governs the polling lifecycle.
        val syncService = MessageSyncService(
            yaloRepo = yaloRepo,
            localRepo = localRepo,
            onSyncError = { e -> android.util.Log.e("MessageSyncService", "insertMessages failed", e) },
        )
        _syncService = syncService

        val imageRepo: ImagePickerRepository = ImageRepositoryLocal(context.applicationContext)

        _viewModelFactory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T = when {
                modelClass.isAssignableFrom(MessagesViewModel::class.java) ->
                    MessagesViewModel(yaloRepo, localRepo, syncService) as T
                modelClass.isAssignableFrom(ImageViewModel::class.java) ->
                    ImageViewModel(imageRepo) as T
                else -> error("Unsupported ViewModel class: $modelClass")
            }
        }
    }

    fun getViewModelFactory(): ViewModelProvider.Factory =
        _viewModelFactory ?: error("YaloChat.init() must be called before rendering ChatScreen")
}
