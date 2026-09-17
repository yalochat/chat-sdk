// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.R
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontStyle

internal const val CHAT_UNSUPPORTED_MESSAGE_TAG: String = "yalo-chat-unsupported-message"

/**
 * What stands in for a kind of message the SDK cannot draw yet.
 *
 * Every kind the backend can send lands here rather than disappearing, so a
 * conversation never has a silent hole in it. Voice, images and products each
 * get their own branch as they arrive.
 */
@Composable
internal fun UnsupportedMessageBody(modifier: Modifier = Modifier) {
    Text(
        text = stringResource(R.string.yalo_chat_unsupported_message),
        modifier = modifier.testTag(CHAT_UNSUPPORTED_MESSAGE_TAG),
        style = MaterialTheme.typography.bodyMedium,
        fontStyle = FontStyle.Italic,
    )
}
