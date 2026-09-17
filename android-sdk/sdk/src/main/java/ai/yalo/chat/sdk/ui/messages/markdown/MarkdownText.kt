// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages.markdown

import ai.yalo.chat.sdk.ui.theme.currentChatTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.style.TextDecoration

/** Markdown drawn with the colors the chat was themed with. */
@Composable
internal fun MarkdownText(
    text: String,
    modifier: Modifier = Modifier,
    style: TextStyle = MaterialTheme.typography.bodyLarge,
) {
    val styles = markdownStyles()
    val annotated = remember(text, styles) { markdownToAnnotatedString(text, styles) }
    Text(text = annotated, modifier = modifier, style = style)
}

/**
 * The palette the markdown is painted with.
 *
 * Only the link color is the host's to choose. Quotes and code are shaded from
 * the text color already in scope, so they stay readable on whatever background
 * the message sits on without asking the host for two more colors.
 */
@Composable
private fun markdownStyles(): MarkdownStyles {
    val theme = currentChatTheme
    return remember(theme) {
        MarkdownStyles(
            code = SpanStyle(
                fontFamily = FontFamily.Monospace,
                background = theme.onBackground.copy(alpha = CODE_BACKGROUND_ALPHA),
            ),
            quote = SpanStyle(
                fontStyle = FontStyle.Italic,
                color = theme.onBackground.copy(alpha = QUOTE_ALPHA),
            ),
            link = SpanStyle(
                color = theme.linkColor,
                textDecoration = TextDecoration.Underline,
            ),
        )
    }
}

private const val CODE_BACKGROUND_ALPHA = 0.08f
private const val QUOTE_ALPHA = 0.7f
