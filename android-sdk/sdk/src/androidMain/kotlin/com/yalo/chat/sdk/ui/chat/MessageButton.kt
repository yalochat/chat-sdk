// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.yalo.chat.sdk.domain.model.ChatButton
import com.yalo.chat.sdk.domain.model.ChatButtonType
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

// Renders a single proto 2.0 ChatButton:
//   POSTBACK → OutlinedButton that fires SendTextMessage(button.text)
//   LINK     → OutlinedButton with arrow icon that opens button.url in the system browser
//   REPLY    → renders nothing (surfaces as quick-reply chips above ChatInput)
@Composable
internal fun MessageButton(
    button: ChatButton,
    onEvent: (MessagesEvent) -> Unit,
) {
    val theme = LocalChatTheme.current
    val context = LocalContext.current

    when (button.type) {
        ChatButtonType.POSTBACK -> OutlinedButton(
            onClick = { onEvent(MessagesEvent.SendTextMessage(button.text)) },
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 6.dp),
            shape = RoundedCornerShape(8.dp),
            border = BorderStroke(1.dp, theme.buttonsMessageButtonBorderColor),
            colors = ButtonDefaults.outlinedButtonColors(
                containerColor = theme.buttonsMessageButtonColor,
                contentColor = theme.buttonsMessageButtonForegroundColor,
            ),
        ) {
            Text(
                text = button.text,
                style = MaterialTheme.typography.bodyMedium.merge(theme.buttonsMessageButtonTextStyle),
            )
        }

        ChatButtonType.LINK -> OutlinedButton(
            onClick = {
                val url = button.url ?: return@OutlinedButton
                val uri = Uri.parse(url)
                if (uri.scheme == "https" || uri.scheme == "http") {
                    runCatching {
                        context.startActivity(
                            Intent(Intent.ACTION_VIEW, uri)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                    }
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 6.dp),
            shape = RoundedCornerShape(8.dp),
            border = BorderStroke(1.dp, theme.ctaButtonBorderColor),
            colors = ButtonDefaults.outlinedButtonColors(
                containerColor = theme.ctaButtonColor,
                contentColor = theme.ctaButtonForegroundColor,
            ),
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(
                    text = button.text,
                    style = MaterialTheme.typography.bodyMedium.merge(theme.ctaButtonTextStyle),
                    modifier = Modifier.weight(1f),
                )
                Icon(
                    imageVector = theme.ctaArrowForwardIcon,
                    contentDescription = null,
                    modifier = Modifier.size(16.dp),
                )
            }
        }

        ChatButtonType.REPLY -> Unit
    }
}
