// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.domain.model.ChatMessage

// Port of flutter-sdk MessageList — reverse layout mirrors ListView.builder(reverse: true).
// Items sorted newest-first so item[0] appears at the bottom of the reversed column.
// Audio callbacks are threaded down to MessageItem for Voice messages (FDE-63).
@Composable
internal fun MessageList(
    messages: List<ChatMessage>,
    modifier: Modifier = Modifier,
    playingMessage: ChatMessage? = null,
    onPlayAudio: (ChatMessage) -> Unit = {},
    onStopAudio: () -> Unit = {},
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
    LazyColumn(
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
            )
        }
    }
}
