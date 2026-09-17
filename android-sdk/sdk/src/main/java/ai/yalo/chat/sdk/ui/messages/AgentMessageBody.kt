// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.ui.messages.markdown.MarkdownText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

/**
 * What the channel answered.
 *
 * The body is markdown, because that is what the assistant writes and what the
 * web SDK renders. Anything the SDK cannot draw yet falls through to the
 * placeholder rather than disappearing.
 */
@Composable
internal fun AgentMessageBody(message: ChatMessage, modifier: Modifier = Modifier) {
    when (message.type) {
        MessageType.Text -> MarkdownText(text = message.content, modifier = modifier)
        else -> UnsupportedMessageBody(modifier = modifier)
    }
}
