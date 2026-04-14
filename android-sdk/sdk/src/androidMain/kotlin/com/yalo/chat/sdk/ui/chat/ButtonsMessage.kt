// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

// Port of flutter-sdk buttons_message.dart — ButtonsMessage widget.
// Renders optional header + body text + outlined reply buttons inside the agent bubble.
// Tapping a button fires SendTextMessage with the button label (same as a quick reply chip).
@Composable
internal fun ButtonsMessage(
    message: ChatMessage,
    onEvent: (MessagesEvent) -> Unit,
) {
    val theme = LocalChatTheme.current
    val textStyle = MaterialTheme.typography.bodyMedium.merge(theme.assistantMessageTextStyle)

    Column(modifier = Modifier.fillMaxWidth()) {
        if (!message.header.isNullOrEmpty()) {
            Text(
                text = message.header,
                style = MaterialTheme.typography.titleSmall.merge(theme.assistantMessageTextStyle),
                modifier = Modifier.padding(bottom = 4.dp),
            )
        }
        if (message.content.isNotEmpty()) {
            Text(
                text = message.content,
                style = textStyle,
                modifier = Modifier.padding(bottom = 4.dp),
            )
        }
        if (!message.footer.isNullOrEmpty()) {
            Text(
                text = message.footer,
                style = MaterialTheme.typography.bodySmall.merge(theme.assistantMessageTextStyle),
                modifier = Modifier.padding(bottom = 8.dp),
            )
        }
        message.buttons.forEach { label ->
            OutlinedButton(
                onClick = { onEvent(MessagesEvent.SendTextMessage(label)) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 6.dp),
                shape = RoundedCornerShape(8.dp),
                border = BorderStroke(1.dp, theme.actionIconColor),
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = theme.actionIconColor,
                ),
            ) {
                Text(text = label, style = textStyle)
            }
        }
    }
}
