// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.ImageSource
import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.YaloChatTexts
import ai.yalo.chat.sdk.data.datasources.chatmessage.ChatMessageDatabaseDataSource
import android.app.Activity
import android.content.Intent
import android.provider.DocumentsContract
import androidx.activity.ComponentActivity
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.shadows.ShadowLooper

@RunWith(RobolectricTestRunner::class)
class ChatImageSourceTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @After
    fun forgetTheSharedDatabase() {
        ChatMessageDatabaseDataSource.reset()
    }

    @Test
    fun opensTheFilePickerInTheScreenshotsFolder() {
        val picker = openPicker(client(ImageSource.Screenshots))

        assertEquals(Intent.ACTION_OPEN_DOCUMENT, picker.action)
        assertTrue(picker.hasExtra(DocumentsContract.EXTRA_INITIAL_URI))
    }

    @Test
    fun opensTheFilePickerWhenNamesAreChecked() {
        val picker = openPicker(client(ImageSource.All, allowedImageNames = listOf("SCR_.*")))

        assertEquals(Intent.ACTION_OPEN_DOCUMENT, picker.action)
        assertFalse(picker.hasExtra(DocumentsContract.EXTRA_INITIAL_URI))
    }

    @Test
    fun tellsThePersonWhenAPictureNameIsNotAllowed() {
        pick(fromFolder = "DCIM/Camera", client = client(ImageSource.All, allowedImageNames = listOf("SCR_.*")))

        composeRule.onNodeWithText("This image can't be sent").assertIsDisplayed()
    }

    @Test
    fun opensThePhotoPickerByDefault() {
        val picker = openPicker(client(ImageSource.All))

        assertFalse(picker.hasExtra(DocumentsContract.EXTRA_INITIAL_URI))
    }

    @Test
    fun tellsThePersonWhenAPictureIsNotAScreenshot() {
        pick(fromFolder = "DCIM/Camera", client = client(ImageSource.Screenshots))

        composeRule.onNodeWithText("This image can't be sent").assertIsDisplayed()
    }

    @Test
    fun showsTheAppsOwnTextsWhenAPictureIsNotAScreenshot() {
        val texts = YaloChatTexts(imageNotAllowed = "Solo capturas", invalidImageAlertButtonText = "Entendido")

        pick(fromFolder = "DCIM/Camera", client = client(ImageSource.Screenshots, texts))

        composeRule.onNodeWithText("Solo capturas").assertIsDisplayed()
        composeRule.onNodeWithText("Entendido").assertIsDisplayed()
    }

    @Test
    fun closesTheAlertWithItsButton() {
        pick(fromFolder = "DCIM/Camera", client = client(ImageSource.Screenshots))

        composeRule.onNodeWithText("OK").performClick()

        composeRule.onNodeWithText("This image can't be sent").assertDoesNotExist()
    }

    private fun pick(fromFolder: String, client: YaloChatClient) {
        val picker = openPicker(client)
        val picked = DocumentsContract.buildDocumentUri(EXTERNAL_STORAGE, "primary:$fromFolder/picture.png")
        shadowOf(composeRule.activity).receiveResult(picker, Activity.RESULT_OK, Intent().setData(picked))
        // The folder is read off the main thread, so the alert comes a moment later.
        composeRule.waitUntil(timeoutMillis = 5_000) {
            ShadowLooper.idleMainLooper()
            composeRule.onAllNodesWithText("OK").fetchSemanticsNodes().isNotEmpty() ||
                composeRule.onAllNodesWithText("Entendido").fetchSemanticsNodes().isNotEmpty()
        }
    }

    private fun openPicker(client: YaloChatClient): Intent {
        composeRule.setContent {
            Chat(client)
        }
        composeRule.onNodeWithTag(CHAT_ATTACHMENT_BUTTON_TAG).performClick()
        return shadowOf(composeRule.activity).nextStartedActivityForResult.intent
    }

    private fun client(
        source: ImageSource,
        texts: YaloChatTexts = YaloChatTexts(),
        allowedImageNames: List<String> = emptyList(),
    ) = YaloChatClient(
        YaloChatClientConfig(
            channelId = "channel-id",
            organizationId = "organization-id",
            channelName = "Support",
            userId = "user-id",
            imageSource = source,
            texts = texts,
            allowedImageNames = allowedImageNames,
        ),
    )

    private companion object {
        const val EXTERNAL_STORAGE = "com.android.externalstorage.documents"
    }
}
