// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.compose.foundation.Canvas
import androidx.compose.material3.LocalContentColor
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import kotlin.math.max
import kotlin.math.pow

// Renders amplitude bars on a Canvas. Amplitudes are DBFS values (negative, down to -160.0).
// Converted to linear 0..1 via pow(10, amplitude / 20).
// Bar height is at least 5% of container height — prevents zero-height bars on silence.
@Composable
internal fun Waveform(
    amplitudes: List<Double>,
    modifier: Modifier = Modifier,
    // Defaults to LocalContentColor so bars automatically contrast with the enclosing Surface
    // (onPrimary inside user message bubbles, onSurfaceVariant inside agent bubbles).
    barColor: Color = LocalContentColor.current,
) {
    Canvas(modifier = modifier) {
        if (amplitudes.isEmpty()) return@Canvas
        val barWidth = size.width / amplitudes.size
        amplitudes.forEachIndexed { i, amplitude ->
            // DBFS → linear 0..1.
            val linear = 10.0.pow(amplitude / 20.0).toFloat()
            val barHeight = max(0.05f * size.height, linear * size.height)
            val x = i * barWidth
            drawRoundRect(
                color = barColor,
                topLeft = Offset(x + barWidth * 0.1f, (size.height - barHeight) / 2f),
                size = Size(barWidth * 0.8f, barHeight),
                cornerRadius = CornerRadius(barWidth * 0.4f),
            )
        }
    }
}
