// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.ui.theme.LocalChatTheme
import kotlin.math.PI
import kotlin.math.sin

@Composable
internal fun TypingIndicator() {
    val theme = LocalChatTheme.current
    val transition = rememberInfiniteTransition()
    val phase by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1200, easing = LinearEasing),
            repeatMode = RepeatMode.Restart,
        ),
    )
    Row(
        horizontalArrangement = Arrangement.spacedBy(4.dp),
        modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
    ) {
        repeat(3) { i ->
            val t = ((phase + i * 0.2f) % 1f)
            val wave = sin(t * PI).toFloat().coerceIn(0f, 1f)
            Box(
                modifier = Modifier
                    .size(8.dp)
                    .offset(y = (-wave * 4).dp)
                    .clip(CircleShape)
                    .background(theme.typingIndicatorDotColor)
                    .alpha(0.3f + 0.7f * wave),
            )
        }
    }
}
