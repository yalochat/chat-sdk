// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

// When the text field is blank a mic icon replaces the Send button — tapping it starts
// recording and ChatScreen switches to WaveformRecorder. onMicClick defaults to a no-op.
@Composable
internal fun ChatInput(
    userMessage: String,
    onUserMessageChange: (String) -> Unit,
    onSendMessage: () -> Unit,
    onAttachmentClick: () -> Unit,
    onMicClick: () -> Unit = {},
    showAttachmentButton: Boolean = true,
) {
    val theme = LocalChatTheme.current
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (showAttachmentButton) {
            IconButton(onClick = onAttachmentClick) {
                Icon(
                    imageVector = theme.attachIcon,
                    contentDescription = "Attach image",
                    tint = theme.attachIconColor,
                )
            }
        }
        TextField(
            value = userMessage,
            onValueChange = onUserMessageChange,
            modifier = Modifier.weight(1f),
            placeholder = { Text("Type a message…", style = theme.hintTextStyle) },
            singleLine = true,
            colors = TextFieldDefaults.colors(
                unfocusedContainerColor = theme.inputTextFieldColor,
                focusedContainerColor = theme.inputTextFieldColor,
                unfocusedIndicatorColor = theme.inputTextFieldBorderColor,
                focusedIndicatorColor = theme.sendButtonColor,
                focusedTextColor = theme.actionIconColor,
                unfocusedTextColor = theme.actionIconColor,
                cursorColor = theme.sendButtonColor,
            ),
        )
        if (userMessage.isBlank()) {
            IconButton(onClick = onMicClick) {
                Icon(
                    imageVector = theme.recordAudioIcon,
                    contentDescription = "Record voice message",
                    tint = theme.actionIconColor,
                )
            }
        } else {
            IconButton(onClick = onSendMessage) {
                Icon(
                    imageVector = theme.sendButtonIcon,
                    contentDescription = "Send",
                    tint = theme.sendButtonColor,
                )
            }
        }
    }
}
