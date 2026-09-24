// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.config

import ai.yalo.chat.sdk.BuildConfig
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepository
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepositoryLocal
import ai.yalo.chat.sdk.data.repositories.token.TokenRepository
import ai.yalo.chat.sdk.data.repositories.token.TokenRepositoryLocal
import ai.yalo.chat.sdk.data.repositories.yalomessage.YaloMessageRepository
import ai.yalo.chat.sdk.data.repositories.yalomessage.YaloMessageRepositoryRemote
import ai.yalo.chat.sdk.data.services.auth.YaloMessageAuthServiceRemote
import ai.yalo.chat.sdk.data.services.chatmessage.ChatMessageDatabaseService
import ai.yalo.chat.sdk.data.services.media.YaloMediaService
import ai.yalo.chat.sdk.data.services.media.YaloMediaServiceRemote
import ai.yalo.chat.sdk.data.services.message.YaloMessageService
import ai.yalo.chat.sdk.data.services.message.YaloMessageServiceWebsocket
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
            database = ChatMessageDatabaseService.of(applicationContext, config.logLevel),
            sessionId = config.sessionId,
        )
    }

    // The configured host carries no scheme, so the scheme is put on here
    // rather than inside the services. The socket will ask the same field for
    // wss, and neither should have to strip the other's prefix off.
    private val baseUrl: HttpUrl = "https://${BuildConfig.YALO_API_BASE_URL}".toHttpUrl()

    // One client for everything that talks to the backend. Each of these
    // defaults to its own, and a second one would mean a second connection pool
    // and a second set of threads for the same host.
    private val client: OkHttpClient by lazy { OkHttpClient() }

    // One scope for everything in this conversation that outlives a single call,
    // so closing the chat has one thing to cancel rather than several.
    private val scope: CoroutineScope by lazy { CoroutineScope(SupervisorJob() + Dispatchers.IO) }

    val auth: TokenRepository by lazy {
        TokenRepositoryLocal.of(
            context = applicationContext,
            service = YaloMessageAuthServiceRemote(
                config = config,
                baseUrl = baseUrl,
                client = client,
                logLevel = config.logLevel,
            ),
            sessionId = config.sessionId,
            logLevel = config.logLevel,
        )
    }

    val media: YaloMediaService by lazy {
        YaloMediaServiceRemote(
            auth = auth,
            baseUrl = baseUrl,
            cacheDir = File(applicationContext.cacheDir, MEDIA_CACHE),
            client = client,
            logLevel = config.logLevel,
        )
    }

    val messages: YaloMessageService by lazy {
        YaloMessageServiceWebsocket(
            auth = auth,
            scope = scope,
            baseUrl = baseUrl,
            // Built from the shared client so the socket keeps the same
            // connection pool and threads, with pings added. OkHttp sends none
            // by default, and a mobile network drops an idle socket without
            // telling either end, which leaves a chat that looks connected and
            // receives nothing. A ping turns that into a failure the connection
            // already knows how to answer.
            sockets = client.newBuilder()
                .pingInterval(PING_INTERVAL_SECONDS, TimeUnit.SECONDS)
                .build(),
            logLevel = config.logLevel,
        )
    }

    val yaloMessages: YaloMessageRepository by lazy {
        YaloMessageRepositoryRemote(service = messages, scope = scope)
    }

    private companion object {

        // Its own directory, so clearing what the chat downloaded never reaches
        // anything else the app cached.
        private const val MEDIA_CACHE = "yalo-chat-media"

        // Short enough to sit under the shortest carrier NAT window, and on
        // the same order as the ten seconds the socket waits to be
        // acknowledged, so a link broken either way is noticed in a
        // comparable time.
        private const val PING_INTERVAL_SECONDS = 20L
    }
}
