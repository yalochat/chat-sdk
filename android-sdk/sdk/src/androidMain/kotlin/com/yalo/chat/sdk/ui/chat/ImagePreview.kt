// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import androidx.compose.ui.res.stringResource
import com.yalo.chat.sdk.R
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

// Full-screen overlay that shows the picked image with Cancel (X) and Send buttons.
// Shown above the chat scaffold when ImageState.isPreviewVisible == true.
@Composable
internal fun ImagePreview(
    imagePath: String,
    onSend: () -> Unit,
    onCancel: () -> Unit,
) {
    val theme = LocalChatTheme.current
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.85f)),
    ) {
        AsyncImage(
            model = imagePath,
            contentDescription = stringResource(R.string.chat_image_preview_content_description),
            contentScale = ContentScale.Fit,
            modifier = Modifier
                .fillMaxSize()
                .padding(bottom = 72.dp),
        )

        // Top-left: close button
        IconButton(
            onClick = onCancel,
            modifier = Modifier
                .align(Alignment.TopStart)
                .padding(8.dp),
        ) {
            Icon(
                imageVector = theme.closeModalIcon,
                contentDescription = stringResource(R.string.chat_cancel_content_description),
                tint = theme.closeModalIconColor,
            )
        }

        // Bottom bar: label + send button
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.BottomCenter)
                .background(theme.backgroundColor.copy(alpha = 0.8f))
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(
                text = stringResource(R.string.chat_send_image_label),
                style = MaterialTheme.typography.bodyMedium.merge(theme.modalHeaderStyle),
            )
            IconButton(onClick = onSend) {
                Icon(
                    imageVector = theme.sendButtonIcon,
                    contentDescription = stringResource(R.string.chat_send_image_content_description),
                    tint = theme.sendButtonForegroundColor,
                )
            }
        }
    }
}
