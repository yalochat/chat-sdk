// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.ui.messages.QuickReplies
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

internal const val CHAT_QUICK_REPLIES_TAG: String = "yalo-chat-quick-replies"

/**
 * The bar of quick replies between the conversation and the message input.
 *
 * It holds only what the channel is offering right now, so it empties as soon
 * as the person answers. The last offer is kept while the bar closes, so the
 * chips do not disappear before it has finished shrinking.
 */
@Composable
internal fun ChatQuickReplies(
    replies: List<MessageButton>,
    onReplyClick: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    val theme = currentChatTheme
    var shown: List<MessageButton> by remember { mutableStateOf(replies) }
    LaunchedEffect(replies) {
        if (replies.isNotEmpty()) {
            shown = replies
        }
    }
    AnimatedVisibility(
        visible = replies.isNotEmpty(),
        modifier = modifier,
        enter = expandVertically() + fadeIn(),
        exit = shrinkVertically() + fadeOut(),
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .testTag(CHAT_QUICK_REPLIES_TAG),
            color = theme.background,
            contentColor = theme.onBackground,
        ) {
            Column {
                HorizontalDivider()
                QuickReplies(
                    replies = shown,
                    onReplyClick = onReplyClick,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                )
            }
        }
    }
}
