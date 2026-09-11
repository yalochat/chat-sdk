// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.ui.messages.ChatMessageItem
import ai.yalo.chat.sdk.ui.messages.TypingIndicator
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

internal const val CHAT_MESSAGE_LIST_TAG: String = "yalo-chat-message-list"

private const val TYPING_INDICATOR_KEY = "yalo-chat-typing-indicator-item"

@Composable
internal fun ChatMessageList(
    messages: List<ChatMessage>,
    modifier: Modifier = Modifier,
    isWaitingForReply: Boolean = false,
    listState: LazyListState = rememberLazyListState(),
) {
    val theme = currentChatTheme

    // Index 0 is the newest message, since the layout is reversed. Keying on it
    // means the jump happens when the conversation actually gains a message,
    // not on every recomposition.
    val newest: Long? = messages.firstOrNull()?.id
    LaunchedEffect(newest) {
        if (messages.isNotEmpty()) {
            listState.animateScrollToItem(0)
        }
    }

    Surface(
        modifier = modifier.testTag(CHAT_MESSAGE_LIST_TAG),
        color = theme.background,
        contentColor = theme.onBackground,
    ) {
        // The newest message comes first and the layout is reversed, so the
        // conversation sits at the bottom and stays there as it grows.
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            state = listState,
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            reverseLayout = true,
        ) {
            if (isWaitingForReply) {
                item(key = TYPING_INDICATOR_KEY) {
                    TypingIndicator()
                }
            }
            items(items = messages, key = { message -> message.id ?: message.timestamp }) { message ->
                ChatMessageItem(message)
            }
        }
    }
}
