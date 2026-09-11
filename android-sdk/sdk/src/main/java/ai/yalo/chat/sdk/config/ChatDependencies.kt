// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.config

import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepository
import ai.yalo.chat.sdk.data.repositories.chatmessage.ChatMessageRepositoryLocal
import ai.yalo.chat.sdk.data.services.chatmessage.ChatMessageDatabaseService
import android.content.Context

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
}
