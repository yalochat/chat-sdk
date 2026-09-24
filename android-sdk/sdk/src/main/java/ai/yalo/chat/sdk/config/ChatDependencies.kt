// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.config

import ai.yalo.chat.sdk.BuildConfig
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.data.datasources.auth.YaloMessageAuthRemoteDataSource
import ai.yalo.chat.sdk.data.datasources.chatmessage.ChatMessageDatabaseDataSource
import ai.yalo.chat.sdk.data.datasources.media.YaloMediaRemoteDataSource
import ai.yalo.chat.sdk.data.datasources.message.YaloMessageDataSource
import ai.yalo.chat.sdk.data.datasources.message.YaloMessageWebsocketDataSource
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepository
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepositoryLocal
import ai.yalo.chat.sdk.data.repositories.media.MediaRepository
import ai.yalo.chat.sdk.data.repositories.media.MediaRepositoryRemote
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import ai.yalo.chat.sdk.data.repositories.token.TokenRepositoryLocal
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
 */
internal class ChatDependencies(
    context: Context,
    private val config: YaloChatClientConfig,
) {

    private val applicationContext: Context = context.applicationContext

    val chatMessages: ChatMessageRepository by lazy {
        ChatMessageRepositoryLocal(
            database = ChatMessageDatabaseDataSource.of(applicationContext, config.logLevel),
            sessionId = config.sessionId,
        )
    }

    private val baseUrl: HttpUrl = "https://${BuildConfig.YALO_API_BASE_URL}".toHttpUrl()
    private val client: OkHttpClient by lazy { OkHttpClient() }
    private val scope: CoroutineScope by lazy { CoroutineScope(SupervisorJob() + Dispatchers.IO) }

    val auth: TokenRepository by lazy {
        TokenRepositoryLocal.of(
            context = applicationContext,
            dataSource = YaloMessageAuthRemoteDataSource(
                config = config,
                baseUrl = baseUrl,
                client = client,
                logLevel = config.logLevel,
            ),
            sessionId = config.sessionId,
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
        private const val PING_INTERVAL_SECONDS = 20L
    }
}
