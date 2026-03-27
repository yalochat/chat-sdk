// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

// Port of flutter-sdk _createQuickReplyOverlay in chat_input.dart.
// Flutter renders chips in a vertical Column floating above ChatInput via an Overlay
// widget anchored to the top-center of the input bar. In Compose we achieve the same
// visual result by placing this composable directly above ChatInput inside the
// Scaffold bottomBar Column — no Overlay machinery needed.
//
// Appearance/disappearance is animated (slide + fade) to avoid layout shifts,
// mirroring the Overlay insert/remove behaviour in Flutter.
@Composable
internal fun QuickReplies(
    quickReplies: List<String>,
    onChipClick: (String) -> Unit,
) {
    AnimatedVisibility(
        visible = quickReplies.isNotEmpty(),
        enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
        exit = slideOutVertically(targetOffsetY = { it }) + fadeOut(),
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
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
