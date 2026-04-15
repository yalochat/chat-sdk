// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Column
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
import com.yalo.chat.sdk.domain.model.ChatMessage
import com.yalo.chat.sdk.ui.theme.LocalChatTheme

// Renders optional header + body text + optional footer + CTA buttons that open URLs.
// Button layout: text on the left, arrow icon on the right.
// URL opening uses Intent.ACTION_VIEW.
@Composable
internal fun CtaMessage(message: ChatMessage) {
    val theme = LocalChatTheme.current
    val context = LocalContext.current

    Column(modifier = Modifier.fillMaxWidth()) {
        if (!message.header.isNullOrEmpty()) {
            Text(
                text = message.header,
                style = MaterialTheme.typography.bodyMedium.merge(theme.messageHeaderStyle),
                modifier = Modifier.padding(bottom = 4.dp),
            )
        }
        if (message.content.isNotEmpty()) {
            Text(
                text = message.content,
                style = MaterialTheme.typography.bodyMedium.merge(theme.assistantMessageTextStyle),
                modifier = Modifier.padding(bottom = 4.dp),
            )
        }
        if (!message.footer.isNullOrEmpty()) {
            Text(
                text = message.footer,
                style = MaterialTheme.typography.bodyMedium.merge(theme.messageFooterStyle),
                modifier = Modifier.padding(bottom = 8.dp),
            )
        }
        message.ctaButtons.forEach { button ->
            OutlinedButton(
                onClick = {
                    val uri = Uri.parse(button.url)
                    if (uri.scheme == "https" || uri.scheme == "http") {
                        runCatching { context.startActivity(Intent(Intent.ACTION_VIEW, uri)) }
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
                // Text left-aligned, arrow icon on the right.
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
        }
    }
}
