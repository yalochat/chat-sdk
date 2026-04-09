// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.theme

import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.sp
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertSame
import org.junit.Test

// Unit tests for ChatTheme.fromMaterialTheme — verifies every Material color-slot mapping
// so that missing or incorrect mappings are caught immediately rather than at runtime.
class ChatThemeTest {

    // A distinguishable sentinel color used to verify a specific slot was mapped.
    private val sentinel = Color(0xFFDEADBE)

    @Test
    fun `Default is a stable singleton`() {
        // Same reference — not a new allocation each time.
        assertSame(ChatTheme.Default, ChatTheme.Default)
    }

    @Test
    fun `fromMaterialTheme maps surface to backgroundColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(surface = sentinel))
        assertEquals(sentinel, theme.backgroundColor)
    }

    @Test
    fun `fromMaterialTheme maps surface to inputTextFieldColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(surface = sentinel))
        assertEquals(sentinel, theme.inputTextFieldColor)
    }

    @Test
    fun `fromMaterialTheme maps surfaceContainer to appBarBackgroundColor`() {
        val scheme = lightColorScheme().copy(surfaceContainer = sentinel)
        val theme = ChatTheme.fromMaterialTheme(scheme)
        assertEquals(sentinel, theme.appBarBackgroundColor)
    }

    @Test
    fun `fromMaterialTheme maps primary to sendButtonColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(primary = sentinel))
        assertEquals(sentinel, theme.sendButtonColor)
    }

    @Test
    fun `fromMaterialTheme maps primary to waveColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(primary = sentinel))
        assertEquals(sentinel, theme.waveColor)
    }

    @Test
    fun `fromMaterialTheme maps onSurface to actionIconColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onSurface = sentinel))
        assertEquals(sentinel, theme.actionIconColor)
    }

    @Test
    fun `fromMaterialTheme maps onSurface to userMessageTextStyle color`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onSurface = sentinel))
        assertEquals(sentinel, theme.userMessageTextStyle.color)
    }

    @Test
    fun `fromMaterialTheme maps onSurface to assistantMessageTextStyle color`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onSurface = sentinel))
        assertEquals(sentinel, theme.assistantMessageTextStyle.color)
    }

    @Test
    fun `fromMaterialTheme preserves fontSize on userMessageTextStyle`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme())
        assertEquals(16.sp, theme.userMessageTextStyle.fontSize)
    }

    @Test
    fun `fromMaterialTheme preserves fontSize on assistantMessageTextStyle`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme())
        assertEquals(16.sp, theme.assistantMessageTextStyle.fontSize)
    }

    @Test
    fun `fromMaterialTheme maps outline to inputTextFieldBorderColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(outline = sentinel))
        assertEquals(sentinel, theme.inputTextFieldBorderColor)
    }

    @Test
    fun `fromMaterialTheme maps onSurfaceVariant to cancelRecordingIconColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onSurfaceVariant = sentinel))
        assertEquals(sentinel, theme.cancelRecordingIconColor)
    }

    @Test
    fun `fromMaterialTheme maps onSurfaceVariant to attachIconColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onSurfaceVariant = sentinel))
        assertEquals(sentinel, theme.attachIconColor)
    }

    @Test
    fun `fromMaterialTheme maps onSurfaceVariant to playAudioIconColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onSurfaceVariant = sentinel))
        assertEquals(sentinel, theme.playAudioIconColor)
    }

    @Test
    fun `fromMaterialTheme maps onSurfaceVariant to pauseAudioIconColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onSurfaceVariant = sentinel))
        assertEquals(sentinel, theme.pauseAudioIconColor)
    }

    @Test
    fun `fromMaterialTheme maps surfaceVariant to userBubbleColor`() {
        val scheme = lightColorScheme().copy(surfaceVariant = sentinel)
        val theme = ChatTheme.fromMaterialTheme(scheme)
        assertEquals(sentinel, theme.userBubbleColor)
    }

    @Test
    fun `fromMaterialTheme maps surfaceContainerHighest to agentBubbleColor`() {
        val scheme = lightColorScheme().copy(surfaceContainerHighest = sentinel)
        val theme = ChatTheme.fromMaterialTheme(scheme)
        assertEquals(sentinel, theme.agentBubbleColor)
    }

    @Test
    fun `fromMaterialTheme maps surfaceVariant to imagePlaceholderBackgroundColor`() {
        val scheme = lightColorScheme().copy(surfaceVariant = sentinel)
        val theme = ChatTheme.fromMaterialTheme(scheme)
        assertEquals(sentinel, theme.imagePlaceholderBackgroundColor)
    }

    @Test
    fun `fromMaterialTheme does not override closeModalIconColor — stays white for dark scrim`() {
        // closeModalIconColor is intentionally not mapped: it is always shown on an 85% black
        // scrim in ImagePreview where onSurfaceVariant (dark in light themes) would be invisible.
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onSurfaceVariant = sentinel))
        assertEquals(Color.White, theme.closeModalIconColor)
    }

    @Test
    fun `fromMaterialTheme produces same result with equivalent schemes`() {
        val scheme = lightColorScheme(primary = Color.Red)
        assertEquals(ChatTheme.fromMaterialTheme(scheme), ChatTheme.fromMaterialTheme(scheme))
    }

    @Test
    fun `fromMaterialTheme maps onPrimary to sendButtonForegroundColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onPrimary = sentinel))
        assertEquals(sentinel, theme.sendButtonForegroundColor)
    }

    @Test
    fun `fromMaterialTheme maps surface to cardBackgroundColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(surface = sentinel))
        assertEquals(sentinel, theme.cardBackgroundColor)
    }

    @Test
    fun `fromMaterialTheme maps outlineVariant to cardBorderColor`() {
        val scheme = lightColorScheme().copy(outlineVariant = sentinel)
        val theme = ChatTheme.fromMaterialTheme(scheme)
        assertEquals(sentinel, theme.cardBorderColor)
    }

    @Test
    fun `fromMaterialTheme maps surfaceContainerHigh to attachmentPickerBackgroundColor`() {
        val scheme = lightColorScheme().copy(surfaceContainerHigh = sentinel)
        val theme = ChatTheme.fromMaterialTheme(scheme)
        assertEquals(sentinel, theme.attachmentPickerBackgroundColor)
    }

    @Test
    fun `fromMaterialTheme maps surfaceVariant to quickReplyColor`() {
        val scheme = lightColorScheme().copy(surfaceVariant = sentinel)
        val theme = ChatTheme.fromMaterialTheme(scheme)
        assertEquals(sentinel, theme.quickReplyColor)
    }

    @Test
    fun `fromMaterialTheme maps outline to quickReplyBorderColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(outline = sentinel))
        assertEquals(sentinel, theme.quickReplyBorderColor)
    }

    @Test
    fun `fromMaterialTheme maps onSurfaceVariant to cameraIconColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onSurfaceVariant = sentinel))
        assertEquals(sentinel, theme.cameraIconColor)
    }

    @Test
    fun `fromMaterialTheme maps onSurfaceVariant to galleryIconColor`() {
        val theme = ChatTheme.fromMaterialTheme(lightColorScheme(onSurfaceVariant = sentinel))
        assertEquals(sentinel, theme.galleryIconColor)
    }

    @Test
    fun `fromMaterialTheme works with dark color scheme`() {
        val theme = ChatTheme.fromMaterialTheme(darkColorScheme())
        // Verify it doesn't throw and produces a non-default theme.
        assertNotEquals(ChatTheme.Default, theme)
    }
}
