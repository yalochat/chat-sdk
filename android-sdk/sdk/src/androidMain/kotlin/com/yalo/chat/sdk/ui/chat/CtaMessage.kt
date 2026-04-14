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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
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

// Port of flutter-sdk cta_message.dart — CtaMessage widget.
// Renders optional header + body text + CTA buttons that open URLs in the browser.
// Uses an Android Intent (ACTION_VIEW) — no url_launcher dependency needed.
@Composable
internal fun CtaMessage(message: ChatMessage) {
    val theme = LocalChatTheme.current
    val context = LocalContext.current
    val textStyle = MaterialTheme.typography.bodyMedium.merge(theme.assistantMessageTextStyle)

    Column(modifier = Modifier.fillMaxWidth()) {
        if (!message.header.isNullOrEmpty()) {
            Text(
                text = message.header,
                style = MaterialTheme.typography.titleSmall.merge(theme.assistantMessageTextStyle),
                modifier = Modifier.padding(bottom = 4.dp),
            )
        }
        if (message.content.isNotEmpty()) {
            Text(
                text = message.content,
                style = textStyle,
                modifier = Modifier.padding(bottom = 4.dp),
            )
        }
        if (!message.footer.isNullOrEmpty()) {
            Text(
                text = message.footer,
                style = MaterialTheme.typography.bodySmall.merge(theme.assistantMessageTextStyle),
                modifier = Modifier.padding(bottom = 8.dp),
            )
        }
        message.ctaButtons.forEach { button ->
            OutlinedButton(
                onClick = {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(button.url))
                    context.startActivity(intent)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 6.dp),
                shape = RoundedCornerShape(8.dp),
                border = BorderStroke(1.dp, theme.actionIconColor),
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = theme.actionIconColor,
                ),
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text(
                        text = button.text,
                        style = textStyle,
                        modifier = Modifier.weight(1f),
                    )
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                        contentDescription = null,
                        modifier = Modifier.size(16.dp),
                    )
                }
            }
        }
    }
}
