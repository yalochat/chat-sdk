// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.ui.theme.ChatTheme
import com.yalo.chat.sdk.ui.theme.ChatThemeProvider

// Renders chips in a vertical Column above the chat input.
//
// expandVertically/shrinkVertically animate the height from 0 to full smoothly so
// the transition is not jarring to the user, even though the bottomBar height does
// change and MessageList padding adjusts accordingly.
@Composable
internal fun QuickReplies(
    quickReplies: List<String>,
    onChipClick: (String) -> Unit,
) {
    AnimatedVisibility(
        visible = quickReplies.isNotEmpty(),
        enter = expandVertically() + fadeIn(),
        exit = shrinkVertically() + fadeOut(),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp, vertical = 4.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            quickReplies.forEach { reply ->
                QuickReplyChip(
                    text = reply,
                    onClick = { onChipClick(reply) },
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun QuickRepliesPreview() {
    ChatThemeProvider(theme = ChatTheme()) {
        QuickReplies(
            quickReplies = listOf("Yes, please", "No thanks", "Maybe later"),
            onChipClick = {},
        )
    }
}
