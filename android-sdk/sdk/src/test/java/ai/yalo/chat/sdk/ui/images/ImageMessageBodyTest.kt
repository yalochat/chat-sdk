// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.images

import ai.yalo.chat.sdk.domain.models.ChatMessage
import ai.yalo.chat.sdk.domain.models.ImageAttachment
import ai.yalo.chat.sdk.domain.models.MessageRole
import ai.yalo.chat.sdk.domain.models.MessageType
import ai.yalo.chat.sdk.ui.messages.CHAT_UNSUPPORTED_MESSAGE_TAG
import android.graphics.Bitmap
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import org.junit.Assert.assertEquals
import kotlinx.coroutines.CompletableDeferred
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ImageMessageBodyTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun showsAPictureOnceItHasBeenRead() {
        val picture = picture()

        composeRule.setContent {
            ImageMessageBody(message = imageMessage(), loadImage = { picture })
        }

        composeRule.onNodeWithTag(CHAT_IMAGE_MESSAGE_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_IMAGE_LOADING_TAG).assertDoesNotExist()
    }

    @Test
    fun holdsRoomForAPictureThatIsStillOnItsWay() {
        val arriving = CompletableDeferred<ImageBitmap?>()

        composeRule.setContent {
            ImageMessageBody(message = imageMessage(), loadImage = { arriving.await() })
        }

        composeRule.onNodeWithTag(CHAT_IMAGE_LOADING_TAG).assertIsDisplayed()
    }

    @Test
    fun standsInForAPictureThatIsNowhereToBeRead() {
        composeRule.setContent {
            ImageMessageBody(message = imageMessage(), loadImage = { null })
        }

        composeRule.onNodeWithTag(CHAT_UNSUPPORTED_MESSAGE_TAG).assertIsDisplayed()
    }

    @Test
    fun standsInForAnImageMessageCarryingNoPicture() {
        composeRule.setContent {
            ImageMessageBody(
                message = imageMessage().copy(image = null),
                loadImage = { picture() },
            )
        }

        composeRule.onNodeWithTag(CHAT_UNSUPPORTED_MESSAGE_TAG).assertIsDisplayed()
        composeRule.onNodeWithTag(CHAT_IMAGE_MESSAGE_TAG).assertDoesNotExist()
    }

    @Test
    fun showsTheCaptionWrittenWithAPicture() {
        val picture = picture()

        composeRule.setContent {
            ImageMessageBody(
                message = imageMessage(caption = "Look at this"),
                loadImage = { picture },
            )
        }

        composeRule.onNodeWithText("Look at this").assertIsDisplayed()
    }

    @Test
    fun showsNothingUnderAPictureThatCameWithNoCaption() {
        val picture = picture()

        composeRule.setContent {
            ImageMessageBody(message = imageMessage(caption = "   "), loadImage = { picture })
        }

        composeRule.onNodeWithText("   ").assertDoesNotExist()
    }

    @Test
    fun drawsAPictureAsWideAsItReallyIs() {
        assertEquals(1.5f, aspectRatioOf(picture(width = 120, height = 80)), TOLERANCE)
    }

    // A picture taller than the screen would push the conversation out of it.
    @Test
    fun keepsAVeryTallPictureFromTakingOverTheConversation() {
        assertEquals(0.75f, aspectRatioOf(picture(width = 100, height = 400)), TOLERANCE)
    }

    private fun picture(width: Int = 120, height: Int = 80): ImageBitmap =
        Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).asImageBitmap()

    private fun imageMessage(caption: String = "") = ChatMessage(
        role = MessageRole.User,
        type = MessageType.Image,
        timestamp = 1_000L,
        id = 1L,
        content = caption,
        image = ImageAttachment(fileName = "holiday.jpg", mediaType = "image/jpeg"),
    )

    private companion object {
        const val TOLERANCE = 0.001f
    }
}
