// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.domain.models.MessageButton
import ai.yalo.chat.sdk.domain.models.MessageButtonType
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

internal const val CHAT_MESSAGE_BUTTON_TAG: String = "yalo-chat-message-button"
internal const val CHAT_LINK_ICON_TAG: String = "yalo-chat-link-icon"

/**
 * The buttons a message keeps, stacked under it.
 *
 * One per line and the full width of the message, because the channel writes
 * them and a button whose text does not fit would otherwise be cut short.
 *
 * A link opens its address outside the chat and carries an arrow to say so.
 * Every other button, a link with no address included, says its text back to
 * the channel through [onButtonClick]. The one the person picked last is drawn
 * highlighted.
 */
@Composable
internal fun MessageButtons(
    buttons: List<MessageButton>,
    onButtonClick: (MessageButton) -> Unit,
    modifier: Modifier = Modifier,
) {
    val theme = currentChatTheme
    val uriHandler = LocalUriHandler.current
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        buttons.forEach { button ->
            val url: String? = button.url.takeIf { button.type == MessageButtonType.Link }
            val isSelected = url == null && button.selected
            Surface(
                onClick = {
                    if (url != null) {
                        try {
                            uriHandler.openUri(url)
                        } catch (_: IllegalArgumentException) {
                            // Nothing on the device can open it.
                        }
                    } else {
                        onButtonClick(button)
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .semantics { this.selected = isSelected }
                    .testTag(CHAT_MESSAGE_BUTTON_TAG),
                shape = theme.postbackShape,
                color = if (isSelected) theme.selectedPostbackBackground else theme.postbackBackground,
                contentColor = if (isSelected) theme.onSelectedPostbackBackground else theme.onPostbackBackground,
                border = BorderStroke(1.dp, theme.postbackBorderColor),
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        text = button.text,
                        modifier = Modifier.weight(1f, fill = false),
                        style = MaterialTheme.typography.labelLarge,
                        textAlign = TextAlign.Center,
                    )
                    if (url != null) {
                        Icon(
                            painter = painterResource(R.drawable.yalo_chat_ic_arrow_forward),
                            contentDescription = null,
                            modifier = Modifier
                                .size(16.dp)
                                .testTag(CHAT_LINK_ICON_TAG),
                        )
                    }
                }
            }
        }
    }
}
