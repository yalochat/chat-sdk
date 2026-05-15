// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

// Each chip is a bordered button with:
//   - max width = 50% of screen width
//   - background = theme.quickReplyColor
//   - border    = theme.quickReplyBorderColor
//   - text      = theme.quickReplyStyle
@Composable
internal fun QuickReplyChip(
    text: String,
    onClick: () -> Unit,
) {
    val theme = LocalChatTheme.current
    // Mirror Flutter's BoxConstraints(maxWidth: size.width * 0.5).
    val maxChipWidth = (LocalConfiguration.current.screenWidthDp * 0.5).dp

    OutlinedButton(
        onClick = onClick,
        modifier = Modifier.widthIn(max = maxChipWidth),
        colors = ButtonDefaults.outlinedButtonColors(
            containerColor = theme.quickReplyColor,
            contentColor = theme.quickReplyStyle.color,
        ),
        border = BorderStroke(width = 1.dp, color = theme.quickReplyBorderColor),
    ) {
        Text(text = text, style = theme.quickReplyStyle)
    }
}
