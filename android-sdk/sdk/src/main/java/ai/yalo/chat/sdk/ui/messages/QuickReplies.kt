// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

internal const val CHAT_QUICK_REPLY_TAG: String = "yalo-chat-quick-reply"

/**
 * The answers a message offers, as chips the person can tap instead of typing.
 *
 * They wrap onto as many lines as they need, because the channel writes them
 * and neither their number nor their length is known here. [vertical] stacks
 * them one per line instead, centered.
 */
@Composable
internal fun QuickReplies(
    replies: List<MessageButton>,
    onReplyClick: (String) -> Unit,
    modifier: Modifier = Modifier,
    vertical: Boolean = false,
) {
    if (vertical) {
        Column(
            modifier = modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            replies.forEach { reply ->
                QuickReply(
                    reply = reply,
                    onReplyClick = onReplyClick,
                    modifier = Modifier
                        .fillMaxWidth()
                        .widthIn(max = VERTICAL_QUICK_REPLY_MAX_WIDTH),
                    textAlign = TextAlign.Center,
                )
            }
        }
    } else {
        FlowRow(
            modifier = modifier,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            replies.forEach { reply ->
                QuickReply(reply = reply, onReplyClick = onReplyClick)
            }
        }
    }
}

@Composable
private fun QuickReply(
    reply: MessageButton,
    onReplyClick: (String) -> Unit,
    modifier: Modifier = Modifier,
    textAlign: TextAlign = TextAlign.Unspecified,
) {
    val theme = currentChatTheme
    Surface(
        onClick = { onReplyClick(reply.text) },
        modifier = modifier.testTag(CHAT_QUICK_REPLY_TAG),
        shape = theme.quickReplyShape,
        color = theme.quickReplyBackground,
        contentColor = theme.onQuickReplyBackground,
        border = BorderStroke(1.dp, theme.quickReplyBorderColor),
    ) {
        Text(
            text = reply.text,
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
            style = MaterialTheme.typography.labelLarge,
            textAlign = textAlign,
        )
    }
}

private val VERTICAL_QUICK_REPLY_MAX_WIDTH = 320.dp
