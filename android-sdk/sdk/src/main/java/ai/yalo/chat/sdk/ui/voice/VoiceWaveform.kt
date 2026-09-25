// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.voice

import androidx.compose.foundation.Canvas
import androidx.compose.material3.LocalContentColor
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt

/** The widest a bar is drawn, however much room the bars are given. */
private val BAR_WIDTH = 3.dp

/** What a bar is drawn as when there was no sound at all, so the line stays whole. */
private val BAR_MINIMUM_HEIGHT = 2.dp

/** How much of a bar's share of the width the bar itself takes. */
private const val BAR_SHARE = 0.6f

/** How visible the part of a note that has not been listened to yet is. */
private const val TRACK_ALPHA = 0.35f

/**
 * A voice note drawn as bars, one per amplitude.
 *
 * [amplitudes] and [progress] are read while the waveform is painted rather
 * than while it is composed, so a recording that moves sixteen times a second
 * repaints without any of the chat around it being rebuilt.
 *
 * [progress] runs from zero to one and says how much of the note has been
 * listened to. The bars behind it are solid and the ones ahead are faded, which
 * is how a note being played reads as going somewhere. A recording passes one,
 * because all of it has been made.
 *
 * The colors come from whatever the waveform is drawn on, so the same waveform
 * is legible in the footer, in the person's own bubble and in the channel's.
 */
@Composable
internal fun VoiceWaveform(
    amplitudes: () -> List<Float>,
    modifier: Modifier = Modifier,
    progress: () -> Float = { 1f },
    color: Color = LocalContentColor.current,
) {
    val maximumWidth = BAR_WIDTH
    val minimumHeight = BAR_MINIMUM_HEIGHT
    Canvas(modifier = modifier) {
        val bars = waveformBars(
            amplitudes = amplitudes(),
            width = size.width,
            height = size.height,
            maximumBarWidth = maximumWidth.toPx(),
            minimumBarHeight = minimumHeight.toPx(),
            progress = progress(),
        )
        bars.forEach { bar ->
            drawRoundRect(
                color = if (bar.isPlayed) color else color.copy(alpha = TRACK_ALPHA),
                topLeft = Offset(x = bar.left, y = bar.top),
                size = Size(width = bar.width, height = bar.height),
                cornerRadius = CornerRadius(bar.width / 2),
            )
        }
    }
}

/** One bar of a waveform, placed in the box the waveform was given. */
internal data class WaveformBar(
    val left: Float,
    val top: Float,
    val width: Float,
    val height: Float,
    val isPlayed: Boolean,
)

/**
 * Where every bar of a waveform goes.
 *
 * Worked out apart from the painting because it is the whole of what a waveform
 * is: the bars share the width evenly whatever their number, each one is
 * centred in its share, and every bar keeps [minimumBarHeight] so a silence is
 * still a line rather than a gap. A box with no room to draw in has no bars.
 */
internal fun waveformBars(
    amplitudes: List<Float>,
    width: Float,
    height: Float,
    maximumBarWidth: Float,
    minimumBarHeight: Float,
    progress: Float,
): List<WaveformBar> {
    if (amplitudes.isEmpty() || width <= 0f || height <= 0f) {
        return emptyList()
    }
    val slot = width / amplitudes.size
    val barWidth = minOf(maximumBarWidth, slot * BAR_SHARE)
    val floor = minOf(minimumBarHeight, height)
    val played = (amplitudes.size * progress.coerceIn(0f, 1f)).roundToInt()
    return amplitudes.mapIndexed { index, level ->
        val barHeight = floor + (height - floor) * level.coerceIn(0f, 1f)
        WaveformBar(
            left = index * slot + (slot - barWidth) / 2,
            top = (height - barHeight) / 2,
            width = barWidth,
            height = barHeight,
            isPlayed = index < played,
        )
    }
}

/** A length in milliseconds as minutes and seconds, the way a chat writes it. */
internal fun formatDuration(millis: Long): String {
    val totalSeconds = (millis / MILLIS_PER_SECOND).coerceAtLeast(0)
    val minutes = totalSeconds / SECONDS_PER_MINUTE
    val seconds = totalSeconds % SECONDS_PER_MINUTE
    return "$minutes:${seconds.toString().padStart(2, '0')}"
}

private const val MILLIS_PER_SECOND = 1_000L
private const val SECONDS_PER_MINUTE = 60L
