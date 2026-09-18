// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

internal const val CHAT_QUICK_REPLY_TAG: String = "yalo-chat-quick-reply"

/**
 * The answers a message offers, as chips the person can tap instead of typing.
 *
 * They wrap onto as many lines as they need, because the channel writes them
 * and neither their number nor their length is known here.
 */
@Composable
internal fun QuickReplies(
    replies: List<MessageButton>,
    onReplyClick: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    val theme = currentChatTheme
    FlowRow(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        replies.forEach { reply ->
            Surface(
                onClick = { onReplyClick(reply.text) },
                modifier = Modifier.testTag(CHAT_QUICK_REPLY_TAG),
                shape = theme.quickReplyShape,
                color = theme.quickReplyBackground,
                contentColor = theme.onQuickReplyBackground,
                border = BorderStroke(1.dp, theme.quickReplyBorderColor),
            ) {
                Text(
                    text = reply.text,
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                    style = MaterialTheme.typography.labelLarge,
                )
            }
        }
    }
}
