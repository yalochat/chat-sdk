// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.ui.theme.SdkConstants
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.compose.ui.res.stringResource
import com.yalo.chat.sdk.R
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
                    contentDescription = stringResource(R.string.chat_attach_content_description),
                    tint = theme.attachIconColor,
                )
            }
        }
        OutlinedTextField(
            value = userMessage,
            onValueChange = onUserMessageChange,
            modifier = Modifier.weight(1f),
            placeholder = { Text(stringResource(R.string.chat_input_placeholder), style = theme.hintTextStyle) },
            singleLine = true,
            shape = RoundedCornerShape(SdkConstants.inputBorderRadius.dp),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedContainerColor = theme.inputTextFieldColor,
                focusedContainerColor = theme.inputTextFieldColor,
                unfocusedBorderColor = theme.inputTextFieldBorderColor,
                focusedBorderColor = theme.inputTextFieldBorderColor,
                focusedTextColor = theme.actionIconColor,
                unfocusedTextColor = theme.actionIconColor,
                cursorColor = theme.sendButtonColor,
            ),
        )
        if (userMessage.isBlank()) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(theme.sendButtonColor)
                    .clickable(onClick = onMicClick)
                    .semantics(mergeDescendants = true) { role = Role.Button },
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    imageVector = theme.recordAudioIcon,
                    contentDescription = stringResource(R.string.chat_record_content_description),
                    tint = theme.sendButtonForegroundColor,
                    modifier = Modifier.size(20.dp),
                )
            }
        } else {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(theme.sendButtonColor)
                    .clickable(onClick = onSendMessage)
                    .semantics(mergeDescendants = true) { role = Role.Button },
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    imageVector = theme.sendButtonIcon,
                    contentDescription = stringResource(R.string.chat_send_content_description),
                    tint = theme.sendButtonForegroundColor,
                    modifier = Modifier.size(20.dp),
                )
            }
        }
    }
}
