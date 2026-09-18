// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages.markdown

import androidx.compose.runtime.Immutable
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.em

/**
 * How each piece of markdown is painted.
 *
 * Sizes are in `em` so a heading stays proportional to whatever text style the
 * message is drawn with, rather than pinning itself to a size the host app
 * never asked for.
 *
 * Every value has a default, so the renderer can be tested without a composition
 * and a new one can be added without touching every call.
 */
@Immutable
internal data class MarkdownStyles(
    val bold: SpanStyle = SpanStyle(fontWeight = FontWeight.Bold),
    val italic: SpanStyle = SpanStyle(fontStyle = FontStyle.Italic),
    val strikethrough: SpanStyle = SpanStyle(textDecoration = TextDecoration.LineThrough),
    val code: SpanStyle = SpanStyle(fontFamily = FontFamily.Monospace),
    val quote: SpanStyle = SpanStyle(fontStyle = FontStyle.Italic),
    val link: SpanStyle = SpanStyle(textDecoration = TextDecoration.Underline),
    val headings: List<SpanStyle> = DEFAULT_HEADINGS,
)

private val DEFAULT_HEADINGS: List<SpanStyle> = listOf(
    SpanStyle(fontWeight = FontWeight.Bold, fontSize = 1.5.em),
    SpanStyle(fontWeight = FontWeight.Bold, fontSize = 1.3.em),
    SpanStyle(fontWeight = FontWeight.Bold, fontSize = 1.15.em),
    SpanStyle(fontWeight = FontWeight.Bold),
    SpanStyle(fontWeight = FontWeight.Bold),
    SpanStyle(fontWeight = FontWeight.Bold),
)
