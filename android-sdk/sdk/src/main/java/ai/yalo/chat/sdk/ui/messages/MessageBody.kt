// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageType
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle

internal const val CHAT_UNSUPPORTED_MESSAGE_TAG: String = "yalo-chat-unsupported-message"

/**
 * What a message says, whoever sent it.
 *
 * Only text is drawn so far. Every other kind the backend can send lands on the
 * placeholder rather than disappearing, so a conversation never has a silent
 * hole in it. Voice, images and products each get their own branch here as
 * they arrive, the way the web SDK switches inside its message components.
 */
@Composable
internal fun MessageBody(message: ChatMessage, modifier: Modifier = Modifier) {
    when (message.type) {
        MessageType.Text -> Text(
            text = message.content,
            modifier = modifier,
            style = MaterialTheme.typography.bodyLarge,
        )

        else -> Text(
            text = stringResource(R.string.yalo_chat_unsupported_message),
            modifier = modifier.testTag(CHAT_UNSUPPORTED_MESSAGE_TAG),
            style = MaterialTheme.typography.bodyMedium,
            fontStyle = FontStyle.Italic,
        )
    }
}
