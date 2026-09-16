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
import android.content.Context
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import okhttp3.HttpUrl.Companion.toHttpUrl

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
    // rather than inside the service. The socket will ask the same field for
    // wss, and neither should have to strip the other's prefix off.
    val auth: YaloMessageAuthService by lazy {
        YaloMessageAuthServiceRemote(
            config = config,
            storage = AuthTokenStorageLocal.of(applicationContext, config.sessionId),
            scope = CoroutineScope(SupervisorJob() + Dispatchers.IO),
            baseUrl = "https://${BuildConfig.YALO_API_BASE_URL}".toHttpUrl(),
        )
    }
}
