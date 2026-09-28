// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

internal const val CHAT_POSTBACK_BUTTON_TAG: String = "yalo-chat-postback-button"

/**
 * The buttons a message keeps, stacked under it.
 *
 * One per line and the full width of the message, because the channel writes
 * them and a button whose text does not fit would otherwise be cut short.
 */
@Composable
internal fun PostbackButtons(
    buttons: List<MessageButton>,
    onButtonClick: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    val theme = currentChatTheme
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        buttons.forEach { button ->
            Surface(
                onClick = { onButtonClick(button.text) },
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag(CHAT_POSTBACK_BUTTON_TAG),
                shape = theme.postbackShape,
                color = theme.postbackBackground,
                contentColor = theme.onPostbackBackground,
                border = BorderStroke(1.dp, theme.postbackBorderColor),
            ) {
                Text(
                    text = button.text,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 8.dp),
                    style = MaterialTheme.typography.labelLarge,
                    textAlign = TextAlign.Center,
                )
            }
        }
    }
}
