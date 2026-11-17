// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.videos

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.domain.models.VideoAttachment
import ai.yalo.chat.sdk.ui.messages.CHAT_UNSUPPORTED_MESSAGE_TAG
import android.graphics.Bitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import kotlinx.coroutines.CompletableDeferred
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class VideoMessageBodyTest {

    @get:Rule
    val composeRule = createComposeRule()

    @get:Rule
    val folder = TemporaryFolder()

    @Test
    fun showsTheFirstFrameWithAPlayButtonAndTheLength() {
        val preview = preview(durationMillis = 42_500)

        composeRule.setContent {
            VideoMessageBody(message = videoMessage(), loadVideo = { preview })
        }

        composeRule.onNodeWithContentDescription("Play video").assertIsDisplayed()
        composeRule.onNodeWithText("0:42").assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_VIDEO_LOADING_TAG).assertDoesNotExist()
    }

    @Test
    fun leavesTheLengthOutWhenItIsNotKnown() {
        val preview = preview(durationMillis = 0)

        composeRule.setContent {
            VideoMessageBody(message = videoMessage(), loadVideo = { preview })
        }

        composeRule.onNodeWithText("0:00").assertDoesNotExist()
    }

    @Test
    fun holdsRoomForAVideoThatIsStillOnItsWay() {
        val arriving = CompletableDeferred<VideoPreview?>()

        composeRule.setContent {
            VideoMessageBody(message = videoMessage(), loadVideo = { arriving.await() })
        }

        composeRule.onNodeWithTag(CHAT_VIDEO_LOADING_TAG).assertIsDisplayed()
    }

    @Test
    fun saysWhenAVideoCannotBePlayed() {
        composeRule.setContent {
            VideoMessageBody(message = videoMessage(caption = "How to set it up"), loadVideo = { null })
        }

        composeRule.onNodeWithText("This video can't be played").assertIsDisplayed()
        composeRule.onNodeWithText("How to set it up").assertIsDisplayed()
    }

    @Test
    fun standsInForAVideoMessageCarryingNoVideo() {
        composeRule.setContent {
            VideoMessageBody(message = videoMessage().copy(video = null), loadVideo = { preview() })
        }

        composeRule.onNodeWithTag(CHAT_UNSUPPORTED_MESSAGE_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_VIDEO_MESSAGE_TAG).assertDoesNotExist()
    }

    @Test
    fun showsTheCaptionWrittenWithAVideo() {
        val preview = preview()

        composeRule.setContent {
            VideoMessageBody(message = videoMessage(caption = "How to set it up"), loadVideo = { preview })
        }

        composeRule.onNodeWithText("How to set it up").assertIsDisplayed()
    }

    @Test
    fun playsTheVideoFullScreenWhenTapped() {
        val preview = preview()
        composeRule.setContent {
            VideoMessageBody(message = videoMessage(), loadVideo = { preview })
        }

        composeRule.onNodeWithContentDescription("Play video").performClick()

        composeRule.onNodeWithTag(CHAT_VIDEO_PLAYER_TAG).assertIsDisplayed()
    }

    @Test
    fun closesThePlayer() {
        val preview = preview()
        composeRule.setContent {
            VideoMessageBody(message = videoMessage(), loadVideo = { preview })
        }
        composeRule.onNodeWithContentDescription("Play video").performClick()

        composeRule.onNodeWithContentDescription("Close").performClick()

        composeRule.onNodeWithTag(CHAT_VIDEO_PLAYER_TAG).assertDoesNotExist()
    }

    private fun preview(durationMillis: Long = 42_500): VideoPreview = VideoPreview(
        file = folder.newFile(),
        poster = Bitmap.createBitmap(160, 90, Bitmap.Config.ARGB_8888).asImageBitmap(),
        durationMillis = durationMillis,
    )

    private fun videoMessage(caption: String = "") = ChatMessage(
        role = MessageRole.Agent,
        type = MessageType.Video,
        timestamp = 1_000L,
        id = 1L,
        content = caption,
        video = VideoAttachment(mediaUrl = "https://media.example.com/setup.mp4", mediaType = "video/mp4"),
    )
}
