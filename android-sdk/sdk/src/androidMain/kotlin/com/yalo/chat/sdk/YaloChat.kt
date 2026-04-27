// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.android.AndroidSqliteDriver
import com.yalo.chat.sdk.data.MessageSyncService
import com.yalo.chat.sdk.data.local.AudioRepositoryLocal
import com.yalo.chat.sdk.data.local.ImageRepositoryLocal
import com.yalo.chat.sdk.data.local.LocalChatMessageRepository
import com.yalo.chat.sdk.data.local.createDatabase
import com.yalo.chat.sdk.domain.repository.ImagePickerRepository
import com.yalo.chat.sdk.data.remote.YaloChatApiService
import com.yalo.chat.sdk.data.remote.buildHttpClient
import com.yalo.chat.sdk.data.repository.fake.FakeChatMessageRepository
import com.yalo.chat.sdk.data.repository.fake.FakeYaloMessageRepository
import com.yalo.chat.sdk.data.repository.remote.YaloMessageRepositoryRemote
import com.yalo.chat.sdk.domain.model.ChatCommand
import com.yalo.chat.sdk.domain.model.ChatCommandCallback
import com.yalo.chat.sdk.database.ChatDatabase
import com.yalo.chat.sdk.ui.chat.AudioViewModel
import com.yalo.chat.sdk.ui.chat.ImageViewModel
import com.yalo.chat.sdk.ui.chat.MessagesViewModel
import com.yalo.chat.sdk.ui.theme.ChatTheme
import io.ktor.client.HttpClient
import io.ktor.client.engine.android.Android

object YaloChat {

    private var _config: YaloChatConfig? = null
    private var _theme: ChatTheme = ChatTheme.Default
    private var _viewModelFactory: ViewModelProvider.Factory? = null
    private var _httpClient: HttpClient? = null
    private var _driver: SqlDriver? = null
    private var _syncService: MessageSyncService? = null
    private var _yaloRepo: YaloMessageRepositoryRemote? = null

    val config: YaloChatConfig
        get() = _config ?: error("YaloChat.init() must be called before accessing config")

    // Theme is passed separately from config because it is Android/Compose-specific.
    // commonMain YaloChatConfig holds only platform-agnostic fields.
    // Mirrors Flutter's Chat(client:, theme:) where config and theme are separate params.
    val theme: ChatTheme
        get() = _theme

    fun init(config: YaloChatConfig, context: Context, theme: ChatTheme = ChatTheme.Default) {
        // Tear down any previous instance before re-initialising (idempotent re-init).
        _syncService?.stop()
        _httpClient?.close()
        _driver?.close()
        _yaloRepo = null

        _config = config
        _theme = theme

        val imageRepo: ImagePickerRepository = ImageRepositoryLocal(context.applicationContext)
        val audioRepo = AudioRepositoryLocal(context.applicationContext)

        if (config.useFakeRepository) {
            val fakeYaloRepo = FakeYaloMessageRepository()
            val fakeLocalRepo = FakeChatMessageRepository(FakeYaloMessageRepository.SEED_MESSAGES)
            val fakeSyncService = MessageSyncService(
                yaloRepo = fakeYaloRepo,
                localRepo = fakeLocalRepo,
                onSyncError = {},
            )
            _syncService = fakeSyncService
            _viewModelFactory = object : ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T = when {
                    modelClass.isAssignableFrom(MessagesViewModel::class.java) ->
                        MessagesViewModel(fakeYaloRepo, fakeLocalRepo, fakeSyncService) as T
                    modelClass.isAssignableFrom(ImageViewModel::class.java) ->
                        ImageViewModel(imageRepo) as T
                    modelClass.isAssignableFrom(AudioViewModel::class.java) ->
                        AudioViewModel(audioRepo) as T
                    else -> error("Unsupported ViewModel class: $modelClass")
                }
            }
            return
        }

        val httpClient = buildHttpClient(Android.create(), debug = BuildConfig.DEBUG)
        _httpClient = httpClient

        val apiService = YaloChatApiService(
            apiBaseUrl = config.environment.apiBaseUrl,
            channelId = config.channelId,
            organizationId = config.organizationId,
            httpClient = httpClient,
        )
        val yaloRepo = YaloMessageRepositoryRemote(
            apiService = apiService,
            tempDir = context.applicationContext.cacheDir.absolutePath,
        )
        _yaloRepo = yaloRepo

        val driver = AndroidSqliteDriver(
            schema = ChatDatabase.Schema,
            context = context.applicationContext,
            name = "chat.db",
            callback = AndroidSqliteDriver.Callback(ChatDatabase.Schema),
        )
        _driver = driver
        val db = createDatabase(driver)
        val localRepo = LocalChatMessageRepository(db.chatMessageQueries, kotlinx.coroutines.Dispatchers.IO)

        val syncService = MessageSyncService(
            yaloRepo = yaloRepo,
            localRepo = localRepo,
            onSyncError = { e -> android.util.Log.e("MessageSyncService", "insertMessages failed", e) },
        )
        _syncService = syncService

        _viewModelFactory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T = when {
                modelClass.isAssignableFrom(MessagesViewModel::class.java) ->
                    MessagesViewModel(yaloRepo, localRepo, syncService) as T
                modelClass.isAssignableFrom(ImageViewModel::class.java) ->
                    ImageViewModel(imageRepo) as T
                modelClass.isAssignableFrom(AudioViewModel::class.java) ->
                    AudioViewModel(audioRepo) as T
                else -> error("Unsupported ViewModel class: $modelClass")
            }
        }
    }

    fun getViewModelFactory(): ViewModelProvider.Factory =
        _viewModelFactory ?: error("YaloChat.init() must be called before rendering ChatScreen")

    /**
     * Registers a callback for a [ChatCommand]. When the command is triggered by the chat UI,
     * the callback fires instead of the built-in API call. Mirrors Flutter's
     * `YaloChatClient.registerCommand(command, callback)`.
     *
     * Can be called before or after [init]. If called before [init] the registration is
     * silently ignored; call [registerCommand] after [init] to ensure it takes effect.
     *
     * @param command  The command to intercept (e.g. [ChatCommand.AddToCart]).
     * @param callback Receives a payload map or null. See [ChatCommandCallback] for per-command
     *                 payload shapes.
     */
    fun registerCommand(command: ChatCommand, callback: ChatCommandCallback) {
        _yaloRepo?.registerCommand(command, callback)
    }
}
