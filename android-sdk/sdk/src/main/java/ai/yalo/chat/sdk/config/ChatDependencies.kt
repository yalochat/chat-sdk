// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.config

import ai.yalo.chat.sdk.BuildConfig
import ai.yalo.chat.sdk.SessionMode
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.common.session.ChatSession
import ai.yalo.chat.sdk.data.datasources.auth.YaloMessageAuthRemoteDataSource
import ai.yalo.chat.sdk.data.datasources.chatmessage.ChatMessageDatabaseDataSource
import ai.yalo.chat.sdk.data.datasources.image.ImageDeviceDataSource
import ai.yalo.chat.sdk.data.datasources.media.YaloMediaRemoteDataSource
import ai.yalo.chat.sdk.data.datasources.message.YaloMessageDataSource
import ai.yalo.chat.sdk.data.datasources.message.YaloMessageWebsocketDataSource
import ai.yalo.chat.sdk.data.datasources.voice.VoicePlayerDeviceDataSource
import ai.yalo.chat.sdk.data.datasources.voice.VoiceRecorderDeviceDataSource
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepository
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepositoryLocal
import ai.yalo.chat.sdk.data.repositories.image.ImageRepository
import ai.yalo.chat.sdk.data.repositories.image.ImageRepositoryLocal
import ai.yalo.chat.sdk.data.repositories.media.MediaRepository
import ai.yalo.chat.sdk.data.repositories.media.MediaRepositoryRemote
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import ai.yalo.chat.sdk.data.repositories.token.TokenRepositoryLocal
import ai.yalo.chat.sdk.data.repositories.voice.VoiceRepository
import ai.yalo.chat.sdk.data.repositories.voice.VoiceRepositoryLocal
import ai.yalo.chat.sdk.data.repositories.yalomessage.YaloMessageRepository
import ai.yalo.chat.sdk.data.repositories.yalomessage.YaloMessageRepositoryRemote
import android.content.Context
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.OkHttpClient
import java.io.File
import java.util.concurrent.TimeUnit

/**
 * Everything one conversation needs, built the first time it is asked for.
 *
 * This is put together where a [Context] already exists rather than inside
 * `YaloChatClient`, which leaves a client a plain value an app can create as
 * often as it likes.
 *
 * What is per conversation lives here. The database underneath does not: every
 * chat in an app reads and writes the same one, scoped by session.
 *
 */
internal class ChatDependencies(
    context: Context,
    private val config: YaloChatClientConfig,
    private val session: ChatSession,
    /**
     * Where everything built here runs its background work, and where tidying
     * up after a conversation runs too. Never cancelled: that tidying up
     * starts as the view model is being cleared, so a scope that died with the
     * chat would drop it.
     */
    val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.IO),
) {

    private val applicationContext: Context = context.applicationContext

    /**
     * Everything one conversation keeps on disk, under a directory of its own
     * so a session that must leave nothing behind can be deleted whole.
     */
    private val sessionsDir: File by lazy { File(applicationContext.filesDir, SESSIONS) }
    private val sessionDir: File by lazy { File(sessionsDir, session.id) }

    /** Where any session keeps what it put on disk, so it can be forgotten whole. */
    val sessionFiles: (String) -> File = { sessionId -> File(sessionsDir, sessionId) }

    val chatMessages: ChatMessageRepository by lazy {
        ChatMessageRepositoryLocal(
            database = ChatMessageDatabaseDataSource.of(applicationContext, config.logLevel),
            sessionId = session.id,
        )
    }

    private val baseUrl: HttpUrl = "https://${BuildConfig.YALO_API_BASE_URL}".toHttpUrl()
    private val client: OkHttpClient by lazy { OkHttpClient() }

    val auth: TokenRepository by lazy {
        TokenRepositoryLocal.of(
            context = applicationContext,
            dataSource = YaloMessageAuthRemoteDataSource(
                config = config,
                authUserId = session.authUserId,
                baseUrl = baseUrl,
                client = client,
                logLevel = config.logLevel,
            ),
            sessionId = session.id,
            ephemeral = config.sessionMode == SessionMode.Ephemeral,
            logLevel = config.logLevel,
        )
    }

    val media: MediaRepository by lazy {
        MediaRepositoryRemote(
            source = YaloMediaRemoteDataSource(
                baseUrl = baseUrl,
                cacheDir = File(applicationContext.cacheDir, MEDIA_CACHE),
                client = client,
                logLevel = config.logLevel,
            ),
            auth = auth,
        )
    }

    /**
     * The microphone and the speaker.
     *
     * Recordings are kept in the app's files rather than in the cache. For a
     * note the person recorded it is the only copy that can be played back, and
     * the system is free to throw the cache away whenever it wants the room.
     */
    val voice: VoiceRepository by lazy {
        VoiceRepositoryLocal(
            recorder = VoiceRecorderDeviceDataSource(applicationContext, config.logLevel),
            player = VoicePlayerDeviceDataSource(config.logLevel),
            recordingsDir = File(sessionDir, VOICE_RECORDINGS),
            scope = scope,
            logLevel = config.logLevel,
        )
    }

    /**
     * The gallery.
     *
     * Pictures are copied into the app's files for the same reason recordings
     * are: what the backend was told is the id of an upload, which is not
     * something to download from, and the gallery stops answering for a picked
     * file once the app has been restarted.
     */
    val images: ImageRepository by lazy {
        ImageRepositoryLocal(
            source = ImageDeviceDataSource(applicationContext),
            imagesDir = File(sessionDir, IMAGES),
            logLevel = config.logLevel,
        )
    }

    private val messages: YaloMessageDataSource by lazy {
        YaloMessageWebsocketDataSource(
            baseUrl = baseUrl,
            sockets = client.newBuilder()
                .pingInterval(PING_INTERVAL_SECONDS, TimeUnit.SECONDS)
                .build(),
            logLevel = config.logLevel,
        )
    }

    val yaloMessages: YaloMessageRepository by lazy {
        YaloMessageRepositoryRemote(
            source = messages,
            auth = auth,
            scope = scope,
            logLevel = config.logLevel,
        )
    }

    private companion object {

        private const val MEDIA_CACHE = "yalo-chat-media"
        private const val SESSIONS = "yalo-chat-sessions"
        private const val VOICE_RECORDINGS = "voice"
        private const val IMAGES = "images"
        private const val PING_INTERVAL_SECONDS = 20L
    }
}
