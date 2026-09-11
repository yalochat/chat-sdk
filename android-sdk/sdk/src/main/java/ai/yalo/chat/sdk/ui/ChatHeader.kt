// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui

import ai.yalo.chat.sdk.R
import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp

internal const val CHAT_HEADER_TAG: String = "yalo-chat-header"
internal const val CHAT_BACK_BUTTON_TAG: String = "yalo-chat-back-button"
internal const val CHAT_STATUS_TAG: String = "yalo-chat-status"
internal const val CHAT_WATERMARK_TAG: String = "yalo-chat-watermark"

private const val YALO_BRAND: String = "Yalo"

/**
 * The bar above the conversation.
 *
 * [avatar] is a slot rather than an image URL so that the SDK does not force an
 * image loading library on whoever integrates it. The back button only appears
 * when [onBack] is given, which keeps it off by default for a chat embedded in
 * a screen that already has its own way back.
 */
@Composable
internal fun ChatHeader(
    title: String,
    modifier: Modifier = Modifier,
    status: String? = null,
    avatar: (@Composable () -> Unit)? = null,
    onBack: (() -> Unit)? = null,
) {
    val theme = currentChatTheme
    Surface(
        modifier = modifier
            .fillMaxWidth()
            .testTag(CHAT_HEADER_TAG),
        color = theme.headerBackground,
        contentColor = theme.onHeaderBackground,
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            if (onBack != null) {
                IconButton(
                    onClick = onBack,
                    modifier = Modifier.testTag(CHAT_BACK_BUTTON_TAG),
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = stringResource(R.string.yalo_chat_back_button_description),
                    )
                }
            }
            if (avatar != null) {
                avatar()
            }
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    modifier = Modifier.semantics { heading() },
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                if (status != null) {
                    Text(
                        text = status,
                        modifier = Modifier.testTag(CHAT_STATUS_TAG),
                        style = MaterialTheme.typography.bodySmall,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
                Text(
                    text = watermark(),
                    modifier = Modifier.testTag(CHAT_WATERMARK_TAG),
                    style = MaterialTheme.typography.labelSmall,
                )
            }
        }
    }
}

/**
 * "By Yalo" with the brand emphasised.
 *
 * The brand comes in as a format argument so that each translation decides
 * where it sits, which matters for languages that do not put it last.
 */
@Composable
private fun watermark(): AnnotatedString {
    val text = stringResource(R.string.yalo_chat_watermark, YALO_BRAND)
    val brandStart = text.indexOf(YALO_BRAND)
    return AnnotatedString.Builder(text).apply {
        if (brandStart >= 0) {
            addStyle(
                style = SpanStyle(fontWeight = FontWeight.Bold),
                start = brandStart,
                end = brandStart + YALO_BRAND.length,
            )
        }
    }.toAnnotatedString()
}
