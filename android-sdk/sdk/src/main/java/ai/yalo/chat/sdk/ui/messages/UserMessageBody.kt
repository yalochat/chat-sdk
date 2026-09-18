// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageType
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

/**
 * What the person using the app wrote.
 *
 * Shown exactly as they typed it. Markdown is left alone here on purpose, the
 * way the web SDK only runs what the assistant says through its renderer:
 * asterisks someone typed are asterisks they meant.
 */
@Composable
internal fun UserMessageBody(message: ChatMessage, modifier: Modifier = Modifier) {
    when (message.type) {
        MessageType.Text -> Text(
            text = message.content,
            modifier = modifier,
            style = MaterialTheme.typography.bodyLarge,
        )

        else -> UnsupportedMessageBody(modifier = modifier)
    }
}
