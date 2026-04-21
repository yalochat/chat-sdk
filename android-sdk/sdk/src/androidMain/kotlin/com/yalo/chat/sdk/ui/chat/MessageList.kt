// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.domain.model.ChatMessage

// reverseLayout puts the newest message at the bottom, matching chat convention.
// Items are sorted newest-first so item[0] lands at the bottom of the reversed column.
// Audio callbacks are optional — only wired for screens that have an AudioViewModel.
@Composable
internal fun MessageList(
    messages: List<ChatMessage>,
    modifier: Modifier = Modifier,
    playingMessage: ChatMessage? = null,
    onPlayAudio: (ChatMessage) -> Unit = {},
    onStopAudio: () -> Unit = {},
    onEvent: (MessagesEvent) -> Unit = {},
) {
    if (messages.isEmpty()) {
        Box(
            modifier = modifier.fillMaxSize(),
            contentAlignment = Alignment.Center,
        ) {
            Text(text = "No messages yet")
        }
        return
    }
    val sorted = remember(messages) { messages.sortedByDescending { it.timestamp } }
    val listState = rememberLazyListState()
    LaunchedEffect(sorted.size) {
        listState.animateScrollToItem(0)
    }
    LazyColumn(
        state = listState,
        reverseLayout = true,
        modifier = modifier
            .fillMaxSize()
            .padding(bottom = 4.dp),
    ) {
        items(items = sorted, key = { it.id ?: it.wiId ?: it.timestamp }) { message ->
            MessageItem(
                message = message,
                playingMessage = playingMessage,
                onPlayAudio = onPlayAudio,
                onStopAudio = onStopAudio,
                onEvent = onEvent,
            )
        }
    }
}
