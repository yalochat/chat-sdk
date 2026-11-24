// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.animation.core.Animatable
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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import kotlin.math.PI
import kotlin.math.sin

internal const val CHAT_TYPING_INDICATOR_TAG: String = "yalo-chat-typing-indicator"

/**
 * The "Writing..." text at the foot of the conversation while a reply is
 * expected. [text] replaces the built-in translation when given.
 *
 * Each character fades in a little after the one before it, the way a reply
 * streams in token by token.
 */
@Composable
internal fun TypingText(modifier: Modifier = Modifier, text: String? = null) {
    val shown = text ?: stringResource(R.string.yalo_chat_writing_indicator)
    val color = currentChatTheme.typingIndicatorDotColor
    val totalMillis = shown.length * TOKEN_STAGGER_MILLIS + TOKEN_FADE_MILLIS
    val elapsed = remember(shown) { Animatable(0f) }
    LaunchedEffect(shown) {
        elapsed.animateTo(
            targetValue = totalMillis.toFloat(),
            animationSpec = tween(durationMillis = totalMillis, easing = LinearEasing),
        )
    }
    val tokens = buildAnnotatedString {
        shown.forEachIndexed { index, token ->
            val alpha = ((elapsed.value - index * TOKEN_STAGGER_MILLIS) / TOKEN_FADE_MILLIS).coerceIn(0f, 1f)
            withStyle(SpanStyle(color = color.copy(alpha = color.alpha * alpha))) {
                append(token)
            }
        }
    }
    Text(
        text = tokens,
        modifier = modifier
            .testTag(CHAT_TYPING_INDICATOR_TAG)
            .semantics { liveRegion = LiveRegionMode.Polite }
            .padding(horizontal = 4.dp, vertical = 8.dp),
        style = MaterialTheme.typography.bodyMedium,
    )
}

/**
 * Three dots at the foot of the conversation while a reply is expected.
 *
 * Each dot runs the same cycle a fifth of a turn behind the one before it, so
 * they ripple rather than pulse together. The timings follow the Flutter SDK's
 * indicator so the two platforms move the same way.
 */
@Composable
internal fun TypingIndicator(modifier: Modifier = Modifier) {
    val dotColor = currentChatTheme.typingIndicatorDotColor
    val transition = rememberInfiniteTransition(label = "yalo-chat-typing")
    val progress by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = CYCLE_MILLIS, easing = LinearEasing),
            repeatMode = RepeatMode.Restart,
        ),
        label = "yalo-chat-typing-cycle",
    )

    Row(
        modifier = modifier
            .testTag(CHAT_TYPING_INDICATOR_TAG)
            .padding(horizontal = 4.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(DOT_SPACING),
        verticalAlignment = Alignment.Bottom,
    ) {
        repeat(DOT_COUNT) { index ->
            // Peaks halfway through this dot's turn of the cycle, then settles.
            val turn = (progress - index * PHASE_STEP + 1f) % 1f
            val lift = sin(turn * PI).toFloat().coerceAtLeast(0f)
            Box(
                modifier = Modifier
                    .size(DOT_SIZE)
                    .graphicsLayer {
                        translationY = -MAX_LIFT.toPx() * lift
                        alpha = RESTING_ALPHA + (1f - RESTING_ALPHA) * lift
                    }
                    .background(color = dotColor, shape = CircleShape),
            )
        }
    }
}

private const val CYCLE_MILLIS = 1_200
private const val TOKEN_STAGGER_MILLIS = 25
private const val TOKEN_FADE_MILLIS = 180
private const val DOT_COUNT = 3
private const val PHASE_STEP = 0.2f
private const val RESTING_ALPHA = 0.4f
private val DOT_SIZE = 8.dp
private val DOT_SPACING = 4.dp
private val MAX_LIFT = 4.dp
