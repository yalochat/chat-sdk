// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.data.repositories.voice.VoiceRecording
import ai.yalo.chat.sdk.ui.voice.CHAT_CANCEL_RECORDING_TAG
import ai.yalo.chat.sdk.ui.voice.CHAT_RECORDING_BAR_TAG
import ai.yalo.chat.sdk.ui.voice.CHAT_RECORDING_TIMER_TAG
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.getUnclippedBoundsInRoot
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment

@RunWith(RobolectricTestRunner::class)
class ChatFooterTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun showsAnInputAndASendButton() {
        setFooter(text = "")

        composeRule.onNodeWithTag(CHAT_INPUT_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsDisplayed()
    }

    @Test
    fun reportsWhatTheUserTypes() {
        val typed = mutableListOf<String>()
        setFooter(text = "", onTextChange = { value -> typed.add(value) })

        composeRule.onNodeWithTag(CHAT_INPUT_TAG).performTextInput("Hi")

        assertEquals(listOf("Hi"), typed)
    }

    @Test
    fun offersToRecordWhileThereIsNothingToSend() {
        setFooter(text = "")

        composeRule.onNodeWithContentDescription(micDescription()).assertIsDisplayed()
        composeRule.onNodeWithContentDescription(sendDescription()).assertDoesNotExist()
    }

    @Test
    fun turnsIntoTheSendButtonOnceThereIsSomethingToSend() {
        setFooter(text = "Hello")

        composeRule.onNodeWithContentDescription(sendDescription()).assertIsDisplayed()
        composeRule.onNodeWithContentDescription(micDescription()).assertDoesNotExist()
    }

    @Test
    fun keepsTheMicrophoneTappableWhileTheInputIsBlank() {
        setFooter(text = "   ")

        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsEnabled()
    }

    @Test
    fun sendsWhenTheButtonIsClickedWithText() {
        var sendCount = 0
        setFooter(text = "Hello", onSend = { sendCount++ })

        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsEnabled().performClick()

        assertEquals(1, sendCount)
    }

    @Test
    fun startsRecordingWhenTheMicrophoneIsClicked() {
        var recordCount = 0
        setFooter(text = "", onStartRecording = { recordCount++ })

        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).performClick()

        assertEquals(1, recordCount)
    }

    @Test
    fun leavesTheMicrophoneOutWhenVoiceMessagesAreOff() {
        setFooter(text = "", hideVoiceButton = true)

        composeRule.onNodeWithContentDescription(sendDescription()).assertIsDisplayed()
        composeRule.onNodeWithContentDescription(micDescription()).assertDoesNotExist()
    }

    @Test
    fun keepsSendDisabledWithNothingTypedAndNoMicrophone() {
        setFooter(text = "   ", hideVoiceButton = true)

        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsNotEnabled()
    }

    @Test
    fun replacesTheInputWithAWaveformAndATimerWhileRecording() {
        setFooter(text = "", recording = { VoiceRecording(elapsedMillis = 7_200, amplitudes = listOf(0.5f)) })

        composeRule.onNodeWithTag(CHAT_RECORDING_BAR_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_RECORDING_TIMER_TAG).assertTextEquals("0:07")
        composeRule.onNodeWithTag(CHAT_INPUT_TAG).assertDoesNotExist()
    }

    @Test
    fun offersToSendWhileRecording() {
        var sendCount = 0
        setFooter(
            text = "",
            onSend = { sendCount++ },
            recording = { VoiceRecording(elapsedMillis = 0, amplitudes = listOf(0f)) },
        )

        composeRule.onNodeWithContentDescription(sendDescription()).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_SEND_BUTTON_TAG).assertIsEnabled().performClick()

        assertEquals(1, sendCount)
    }

    @Test
    fun throwsTheRecordingAwayWhenTheCrossIsClicked() {
        var cancelCount = 0
        setFooter(
            text = "",
            recording = { VoiceRecording(elapsedMillis = 0, amplitudes = listOf(0f)) },
            onCancelRecording = { cancelCount++ },
        )

        composeRule.onNodeWithTag(CHAT_CANCEL_RECORDING_TAG).performClick()

        assertEquals(1, cancelCount)
    }

    @Test
    fun putsTheInputBackOnceTheRecordingIsOver() {
        var current by mutableStateOf<VoiceRecording?>(
            VoiceRecording(elapsedMillis = 0, amplitudes = listOf(0f)),
        )
        composeRule.setContent {
            ChatFooter(text = "", onTextChange = {}, onSend = {}, recording = { current })
        }

        composeRule.onNodeWithTag(CHAT_RECORDING_BAR_TAG).assertIsDisplayed()
        current = null

        composeRule.onNodeWithTag(CHAT_INPUT_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_RECORDING_BAR_TAG).assertDoesNotExist()
    }

    @Test
    fun offersToPickAPicture() {
        var pickCount = 0
        setFooter(text = "", onPickImage = { pickCount++ })

        composeRule.onNodeWithTag(CHAT_ATTACHMENT_BUTTON_TAG).assertIsDisplayed().performClick()

        assertEquals(1, pickCount)
    }

    // The plus shares the outline with the place text is typed, so the two read
    // as one input rather than as a button parked next to a field.
    @Test
    fun keepsThePlusInsideTheOutlineAroundTheInput() {
        setFooter(text = "")

        val outline = composeRule.onNodeWithTag(CHAT_INPUT_BOX_TAG).getUnclippedBoundsInRoot()
        val plus = composeRule.onNodeWithTag(CHAT_ATTACHMENT_BUTTON_TAG).getUnclippedBoundsInRoot()

        assertTrue(
            "the plus at $plus sits outside the input at $outline",
            plus.left >= outline.left &&
                plus.right <= outline.right &&
                plus.top >= outline.top &&
                plus.bottom <= outline.bottom,
        )
    }

    @Test
    fun leavesThePlusOutWhenPicturesAreOff() {
        setFooter(text = "", hideAttachmentButton = true)

        composeRule.onNodeWithTag(CHAT_ATTACHMENT_BUTTON_TAG).assertDoesNotExist()
        composeRule.onNodeWithTag(CHAT_INPUT_TAG).assertIsDisplayed()
    }

    @Test
    fun takesTheWholeInputAwayWhileARecordingIsRunning() {
        setFooter(
            text = "",
            recording = { VoiceRecording(elapsedMillis = 0, amplitudes = listOf(0f)) },
        )

        composeRule.onNodeWithTag(CHAT_ATTACHMENT_BUTTON_TAG).assertDoesNotExist()
        composeRule.onNodeWithTag(CHAT_INPUT_BOX_TAG).assertDoesNotExist()
    }

    private fun micDescription(): String =
        RuntimeEnvironment.getApplication().getString(R.string.yalo_chat_mic_button_description)

    private fun sendDescription(): String =
        RuntimeEnvironment.getApplication().getString(R.string.yalo_chat_send_button_description)

    private fun setFooter(
        text: String,
        onTextChange: (String) -> Unit = {},
        onSend: () -> Unit = {},
        hideVoiceButton: Boolean = false,
        hideAttachmentButton: Boolean = false,
        onPickImage: () -> Unit = {},
        recording: () -> VoiceRecording? = { null },
        onStartRecording: () -> Unit = {},
        onCancelRecording: () -> Unit = {},
    ) {
        composeRule.setContent {
            ChatFooter(
                text = text,
                onTextChange = onTextChange,
                onSend = onSend,
                hideVoiceButton = hideVoiceButton,
                hideAttachmentButton = hideAttachmentButton,
                onPickImage = onPickImage,
                recording = recording,
                onStartRecording = onStartRecording,
                onCancelRecording = onCancelRecording,
            )
        }
    }
}
