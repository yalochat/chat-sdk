// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

// Port of flutter-sdk ChatInput — Phase 1: text field + send button only.
// Phase 2 will add attachment button, voice recorder, image preview, and quick replies.
@Composable
fun ChatInput(
    userMessage: String,
    onUserMessageChange: (String) -> Unit,
    onSendMessage: () -> Unit,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        TextField(
            value = userMessage,
            onValueChange = onUserMessageChange,
            modifier = Modifier.weight(1f),
            placeholder = { Text("Type a message…") },
            singleLine = true,
        )
        IconButton(
            onClick = onSendMessage,
            enabled = userMessage.isNotBlank(),
        ) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.Send,
                contentDescription = "Send",
            )
        }
    }
}
