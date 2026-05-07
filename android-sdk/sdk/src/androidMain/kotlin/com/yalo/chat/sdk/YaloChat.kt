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
import com.yalo.chat.sdk.data.repository.remote.YaloMessageRepositoryWebSocket
import com.yalo.chat.sdk.data.remote.YaloMessageServiceWebSocket
import com.yalo.chat.sdk.domain.model.ChatCommand
import com.yalo.chat.sdk.domain.model.ChatCommandCallback
import com.yalo.chat.sdk.domain.repository.YaloMessageRepository
import com.yalo.chat.sdk.database.ChatDatabase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
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
    private var _yaloRepo: YaloMessageRepository? = null
    private var _wsScope: CoroutineScope? = null
    private val pendingCommands: MutableMap<ChatCommand, ChatCommandCallback> = mutableMapOf()

    val config: YaloChatConfig
        get() = _config ?: error("YaloChat.init() must be called before accessing config")

    // Theme is passed separately from config because it is Android/Compose-specific.
    // commonMain YaloChatConfig holds only platform-agnostic fields.
    // Mirrors Flutter's Chat(client:, theme:) where config and theme are separate params.
    val theme: ChatTheme
        get() = _theme

    fun init(config: YaloChatConfig, context: Context, theme: ChatTheme = ChatTheme.Default) {
        // Snapshot all known commands before teardown so they survive re-init.
        // pendingCommands holds pre-init registrations; _yaloRepo holds post-init registrations.
        // On the very first init() pendingCommands has pre-init commands and _yaloRepo is null.
        // On re-init pendingCommands is empty (cleared at end of previous init) and _yaloRepo
        // holds any callbacks registered during the previous session — we must capture those too
        // or they would be silently lost every time the host re-configures the SDK.
        val savedCommands = pendingCommands + (_yaloRepo?.commandsSnapshot ?: emptyMap())

        // Tear down any previous instance before re-initialising (idempotent re-init).
        _syncService?.stop()
        _wsScope?.cancel()
        _wsScope = null
        _httpClient?.close()
        _driver?.close()
        _yaloRepo = null
        pendingCommands.clear()

        _config = config
        _theme = theme

        val imageRepo: ImagePickerRepository = ImageRepositoryLocal(context.applicationContext)
        val audioRepo = AudioRepositoryLocal(context.applicationContext)

        if (config.useFakeRepository) {
            // Fake mode: the fake repo is a dev/test stub and does not execute real cart ops.
            // Re-buffer savedCommands so they are not lost — they will flush on the next real init().
            pendingCommands.putAll(savedCommands)
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

        val driver = AndroidSqliteDriver(
            schema = ChatDatabase.Schema,
            context = context.applicationContext,
            name = "chat.db",
            callback = AndroidSqliteDriver.Callback(ChatDatabase.Schema),
        )
        _driver = driver
        val db = createDatabase(driver)
        val localRepo = LocalChatMessageRepository(db.chatMessageQueries, kotlinx.coroutines.Dispatchers.IO)

        val yaloRepo: YaloMessageRepository
        if (config.transport == Transport.WEBSOCKET) {
            val wsUrl = "${config.environment.wsBaseUrl}/websocket/v1/connect/inapp"
            val wsService = YaloMessageServiceWebSocket(
                wsUrl = wsUrl,
                apiService = apiService,
                httpClient = httpClient,
            )
            val wsRepo = YaloMessageRepositoryWebSocket(
                wsService = wsService,
                apiService = apiService,
                tempDir = context.applicationContext.cacheDir.absolutePath,
            )
            val wsScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
            _wsScope = wsScope
            wsRepo.start(wsScope)
            _yaloRepo = wsRepo
            savedCommands.forEach { (cmd, cb) -> wsRepo.registerCommand(cmd, cb) }
            yaloRepo = wsRepo
        } else {
            val pollRepo = YaloMessageRepositoryRemote(
                apiService = apiService,
                tempDir = context.applicationContext.cacheDir.absolutePath,
            )
            _yaloRepo = pollRepo
            savedCommands.forEach { (cmd, cb) -> pollRepo.registerCommand(cmd, cb) }
            yaloRepo = pollRepo
        }

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
     * Can be called before or after [init]. Registrations made before [init] are buffered and
     * applied automatically when [init] runs, matching Flutter/web SDK "before or after init"
     * behaviour.
     *
     * @param command  The command to intercept (e.g. [ChatCommand.ADD_TO_CART]).
     * @param callback Receives a payload map or null. See [ChatCommandCallback] for per-command
     *                 payload shapes.
     */
    fun registerCommand(command: ChatCommand, callback: ChatCommandCallback) {
        val repo = _yaloRepo
        if (repo != null) {
            repo.registerCommand(command, callback)
        } else {
            pendingCommands[command] = callback
        }
    }

    /** Visible for testing only — exposes the pending command buffer. */
    internal val pendingCommandsForTest: Map<ChatCommand, ChatCommandCallback>
        get() = pendingCommands.toMap()

    /** Visible for testing only — resets singleton state to pristine. */
    internal fun resetForTest() {
        _syncService?.stop()
        _wsScope?.cancel()
        _wsScope = null
        _httpClient?.close()
        _driver?.close()
        _yaloRepo = null
        _config = null
        _theme = ChatTheme.Default
        _viewModelFactory = null
        pendingCommands.clear()
    }
}
