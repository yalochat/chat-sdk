// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.config

import ai.yalo.chat.sdk.BuildConfig
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepository
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepositoryLocal
import ai.yalo.chat.sdk.data.services.auth.YaloMessageAuthService
import ai.yalo.chat.sdk.data.services.auth.YaloMessageAuthServiceRemote
import ai.yalo.chat.sdk.data.services.auth.AuthTokenStorageLocal
import ai.yalo.chat.sdk.data.services.chatmessage.ChatMessageDatabaseService
import ai.yalo.chat.sdk.data.services.media.YaloMediaService
import ai.yalo.chat.sdk.data.services.media.YaloMediaServiceRemote
import android.content.Context
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.OkHttpClient
import java.io.File

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
            database = ChatMessageDatabaseService.of(applicationContext),
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

    val auth: YaloMessageAuthService by lazy {
        YaloMessageAuthServiceRemote(
            config = config,
            storage = AuthTokenStorageLocal.of(applicationContext, config.sessionId),
            scope = CoroutineScope(SupervisorJob() + Dispatchers.IO),
            baseUrl = baseUrl,
            client = client,
        )
    }

    val media: YaloMediaService by lazy {
        YaloMediaServiceRemote(
            auth = auth,
            baseUrl = baseUrl,
            cacheDir = File(applicationContext.cacheDir, MEDIA_CACHE),
            client = client,
        )
    }

    private companion object {

        // Its own directory, so clearing what the chat downloaded never reaches
        // anything else the app cached.
        private const val MEDIA_CACHE = "yalo-chat-media"
    }
}
