// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Outline
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class TailedShapeTest {

    private val shape = TailedShape(RoundedCornerShape(16.dp), DpSize(48.dp, 24.dp), atEnd = true)

    @Test
    fun hangsTheTailUnderTheBubble() {
        val bounds = boundsOf(Size(200f, 64f))

        assertEquals(64f, bounds.bottom, 0.5f)
        assertEquals(0f, bounds.left, 0.5f)
        assertEquals(200f, bounds.right, 0.5f)
    }

    @Test
    fun keepsTheTailInsideAShortBubble() {
        val bounds = boundsOf(Size(40f, 64f))

        assertEquals(0f, bounds.left, 0.5f)
        assertEquals(40f, bounds.right, 0.5f)
    }

    private fun boundsOf(size: Size) =
        (shape.createOutline(size, LayoutDirection.Ltr, Density(1f)) as Outline.Generic).path.getBounds()
}
