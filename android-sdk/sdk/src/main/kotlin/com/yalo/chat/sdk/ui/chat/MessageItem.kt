// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.domain.model.MessageRole
import com.yalo.chat.sdk.domain.model.MessageType

// Port of flutter-sdk Message + UserMessage + AssistantMessage.
// Phase 2 M3 (FDE-59): Image type rendered via Coil AsyncImage.
// Other non-text types remain as "[type]" placeholders until future milestones.
@Composable
internal fun MessageItem(message: ChatMessage) {
    val isUser = message.role == MessageRole.USER
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 4.dp),
        horizontalArrangement = if (isUser) Arrangement.End else Arrangement.Start,
    ) {
        Surface(
            shape = MaterialTheme.shapes.medium,
            color = if (isUser) MaterialTheme.colorScheme.primary
                    else MaterialTheme.colorScheme.surfaceVariant,
            modifier = Modifier.widthIn(max = 280.dp),
        ) {
            val textColor = if (isUser) MaterialTheme.colorScheme.onPrimary
                            else MaterialTheme.colorScheme.onSurfaceVariant
            Box(modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp)) {
                when (message.type) {
                    MessageType.Text -> Text(
                        text = message.content,
                        color = textColor,
                    )
                    MessageType.Image -> AsyncImage(
                        model = message.fileName,
                        contentDescription = "Image message",
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.size(200.dp),
                    )
                    MessageType.Unknown -> Text(
                        text = "Unsupported message",
                        color = textColor,
                    )
                    else -> Text(
                        text = "[${message.type.value}]",
                        color = textColor,
                    )
                }
            }
        }
    }
}
