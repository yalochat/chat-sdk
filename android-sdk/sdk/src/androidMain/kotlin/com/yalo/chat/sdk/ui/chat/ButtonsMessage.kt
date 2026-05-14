// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

// Renders optional header + body text + optional footer + inline buttons inside the agent bubble.
// Handles all proto 2.0 button types via MessageButton: POSTBACK fires SendTextMessage,
// LINK opens the URL, REPLY is skipped (shown as quick-reply chips above ChatInput).
@Composable
internal fun ButtonsMessage(
    message: ChatMessage,
    onEvent: (MessagesEvent) -> Unit,
) {
    val theme = LocalChatTheme.current

    Column(modifier = Modifier.fillMaxWidth()) {
        if (!message.header.isNullOrEmpty()) {
            Text(
                text = message.header,
                style = MaterialTheme.typography.bodyMedium.merge(theme.messageHeaderStyle),
                modifier = Modifier.padding(bottom = 4.dp),
            )
        }
        if (message.content.isNotEmpty()) {
            Text(
                text = message.content,
                style = MaterialTheme.typography.bodyMedium.merge(theme.assistantMessageTextStyle),
                modifier = Modifier.padding(bottom = 4.dp),
            )
        }
        if (!message.footer.isNullOrEmpty()) {
            Text(
                text = message.footer,
                style = MaterialTheme.typography.bodyMedium.merge(theme.messageFooterStyle),
                modifier = Modifier.padding(bottom = 8.dp),
            )
        }
        message.buttons.forEach { button ->
            MessageButton(button = button, onEvent = onEvent)
        }
    }
}
