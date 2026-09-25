// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.voice

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.data.repositories.voice.VoicePlayback
import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.domain.models.VoiceNote
import ai.yalo.chat.sdk.ui.messages.CHAT_UNSUPPORTED_MESSAGE_TAG
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment

@RunWith(RobolectricTestRunner::class)
class VoiceMessageBodyTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun offersToPlayANoteNobodyHasListenedToYet() {
        setBody(message = voiceMessage())

        composeRule.onNodeWithContentDescription(playDescription()).assertIsDisplayed()
        composeRule.onNodeWithText("0:04").assertIsDisplayed()
    }

    @Test
    fun offersToPauseTheNoteThatIsPlaying() {
        setBody(
            message = voiceMessage(),
            playback = { playing(positionMillis = 1_000) },
        )

        composeRule.onNodeWithContentDescription(pauseDescription()).assertIsDisplayed()
    }

    @Test
    fun countsUpWhileTheNoteIsPlaying() {
        setBody(
            message = voiceMessage(),
            playback = { playing(positionMillis = 2_000) },
        )

        composeRule.onNodeWithText("0:02").assertIsDisplayed()
    }

    @Test
    fun goesBackToTheWholeLengthOnceTheNoteIsPaused() {
        setBody(
            message = voiceMessage(),
            playback = { playing(positionMillis = 2_000).copy(isPlaying = false) },
        )

        composeRule.onNodeWithText("0:04").assertIsDisplayed()
    }

    @Test
    fun ignoresAnotherNoteBeingPlayed() {
        setBody(
            message = voiceMessage(),
            playback = { playing(positionMillis = 2_000).copy(messageId = 99) },
        )

        composeRule.onNodeWithContentDescription(playDescription()).assertIsDisplayed()
        composeRule.onNodeWithText("0:04").assertIsDisplayed()
    }

    @Test
    fun reportsTheNoteBeingTapped() {
        var toggleCount = 0
        setBody(message = voiceMessage(), onToggle = { toggleCount++ })

        composeRule.onNodeWithTag(CHAT_VOICE_PLAY_BUTTON_TAG).performClick()

        assertEquals(1, toggleCount)
    }

    @Test
    fun standsInForAVoiceMessageWithNothingToPlay() {
        setBody(message = voiceMessage(note = null))

        composeRule.onNodeWithTag(CHAT_UNSUPPORTED_MESSAGE_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_VOICE_MESSAGE_TAG).assertDoesNotExist()
    }

    @Test
    fun fillsTheWaveformAsFarAsTheNoteHasBeenListenedTo() {
        assertEquals(0.5f, playedShare(playing(positionMillis = 2_000), MESSAGE_ID, 4_000), TOLERANCE)
    }

    @Test
    fun leavesTheWaveformEmptyWhenNothingIsPlaying() {
        assertEquals(0f, playedShare(null, MESSAGE_ID, 4_000), TOLERANCE)
    }

    @Test
    fun leavesTheWaveformEmptyWhenAnotherNoteIsPlaying() {
        val other = playing(positionMillis = 2_000).copy(messageId = 99)

        assertEquals(0f, playedShare(other, MESSAGE_ID, 4_000), TOLERANCE)
    }

    @Test
    fun leavesTheWaveformEmptyForANoteOfNoLength() {
        assertEquals(0f, playedShare(playing(positionMillis = 2_000), MESSAGE_ID, 0), TOLERANCE)
    }

    @Test
    fun neverFillsTheWaveformPastItsEnd() {
        assertEquals(1f, playedShare(playing(positionMillis = 9_000), MESSAGE_ID, 4_000), TOLERANCE)
    }

    private fun playing(positionMillis: Long) = VoicePlayback(
        messageId = MESSAGE_ID,
        positionMillis = positionMillis,
        durationMillis = 4_000,
        isPlaying = true,
    )

    private fun voiceMessage(
        note: VoiceNote? = VoiceNote(durationMillis = 4_000, amplitudes = listOf(0.2f, 0.9f)),
    ) = ChatMessage(
        role = MessageRole.User,
        type = MessageType.Voice,
        timestamp = 1_000L,
        id = MESSAGE_ID,
        voice = note,
    )

    private fun playDescription(): String = RuntimeEnvironment.getApplication()
        .getString(R.string.yalo_chat_play_voice_message_description)

    private fun pauseDescription(): String = RuntimeEnvironment.getApplication()
        .getString(R.string.yalo_chat_pause_voice_message_description)

    private fun setBody(
        message: ChatMessage,
        playback: () -> VoicePlayback? = { null },
        onToggle: () -> Unit = {},
    ) {
        composeRule.setContent {
            VoiceMessageBody(message = message, playback = playback, onToggle = onToggle)
        }
    }

    private companion object {
        const val MESSAGE_ID = 7L
        const val TOLERANCE = 0.0001f
    }
}
