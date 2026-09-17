// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages.markdown

import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class MarkdownAnnotatorTest {

    @Test
    fun keepsPlainTextAsItWasWritten() {
        val rendered = markdownToAnnotatedString("Your order is on its way.")

        assertEquals("Your order is on its way.", rendered.text)
    }

    @Test
    fun readsAnEmptyMessageAsEmpty() {
        assertEquals("", markdownToAnnotatedString("").text)
    }

    @Test
    fun emphasisesWithoutShowingItsMarkers() {
        val rendered = markdownToAnnotatedString("**loud** and *soft* and ~~gone~~")

        assertEquals("loud and soft and gone", rendered.text)
        assertTrue(rendered.styling("loud").any { it.fontWeight == FontWeight.Bold })
        assertTrue(rendered.styling("soft").any { it.fontStyle == FontStyle.Italic })
        assertTrue(
            rendered.styling("gone").any { it.textDecoration == TextDecoration.LineThrough },
        )
    }

    @Test
    fun leavesAsterisksThatMeantNothingAlone() {
        val rendered = markdownToAnnotatedString("2 * 3 * 4 costs 24")

        assertEquals("2 * 3 * 4 costs 24", rendered.text)
    }

    @Test
    fun setsCodeInAMonospaceFace() {
        val rendered = markdownToAnnotatedString("Run `flutter test` first")

        assertEquals("Run flutter test first", rendered.text)
        assertTrue(rendered.styling("flutter test").any { it.fontFamily == FontFamily.Monospace })
    }

    @Test
    fun makesALinkOutOfItsLabel() {
        val rendered = markdownToAnnotatedString("See [our prices](https://yalo.com/pricing)")

        assertEquals("See our prices", rendered.text)
        assertEquals(listOf("https://yalo.com/pricing"), rendered.urls())
    }

    @Test
    fun makesALinkOutOfAPlainAddress() {
        val rendered = markdownToAnnotatedString("Book at https://yalo.com/demo today")

        assertEquals("Book at https://yalo.com/demo today", rendered.text)
        assertEquals(listOf("https://yalo.com/demo"), rendered.urls())
    }

    @Test
    fun bulletsAnUnorderedListAndIndentsWhatHangsOffIt() {
        val rendered = markdownToAnnotatedString("- one\n- two\n  - nested")

        assertEquals("• one\n• two\n    • nested", rendered.text)
    }

    @Test
    fun numbersAnOrderedList() {
        val rendered = markdownToAnnotatedString("1. first\n2. second")

        assertEquals("1. first\n2. second", rendered.text)
    }

    @Test
    fun drawsAHeadingLargerThanTheTextBelowIt() {
        val rendered = markdownToAnnotatedString("# Delivery\n\nIt ships today.")

        assertEquals("Delivery\n\nIt ships today.", rendered.text)
        val heading = rendered.styling("Delivery").first { it.fontWeight == FontWeight.Bold }
        assertTrue(heading.fontSize.value > 1f)
    }

    @Test
    fun drawsAHeadingUnderlinedWithEqualsTheSameWay() {
        val rendered = markdownToAnnotatedString("Delivery\n===\n\nIt ships today.")

        assertEquals("Delivery\n\nIt ships today.", rendered.text)
        assertTrue(rendered.styling("Delivery").any { it.fontWeight == FontWeight.Bold })
    }

    @Test
    fun makesALinkOutOfAnAddressInAngleBrackets() {
        val rendered = markdownToAnnotatedString("Book at <https://yalo.com/demo>")

        assertEquals("Book at https://yalo.com/demo", rendered.text)
        assertEquals(listOf("https://yalo.com/demo"), rendered.urls())
    }

    @Test
    fun breaksTheLineWhereTheAuthorAskedFor() {
        val rendered = markdownToAnnotatedString("one  \ntwo")

        assertEquals("one\ntwo", rendered.text)
    }

    @Test
    fun showsTheAddressWhenALinkHasNoLabel() {
        val rendered = markdownToAnnotatedString("[](https://yalo.com/demo)")

        assertEquals("https://yalo.com/demo", rendered.text)
        assertEquals(listOf("https://yalo.com/demo"), rendered.urls())
    }

    @Test
    fun keepsTheWordsOfALinkThatPointsNowhere() {
        val rendered = markdownToAnnotatedString("[our prices]()")

        assertTrue(rendered.text.contains("our prices"))
        assertEquals(emptyList<String>(), rendered.urls())
    }

    @Test
    fun keepsTheWordsOfALinkWrittenAgainstAReference() {
        val rendered = markdownToAnnotatedString("See [our prices][prices]")

        assertTrue(rendered.text.contains("our prices"))
    }

    @Test
    fun keepsAnImageWrittenAgainstAReferenceRatherThanLosingIt() {
        val rendered = markdownToAnnotatedString("![a red shirt][shirt]")

        assertTrue(rendered.text.contains("a red shirt"))
    }

    @Test
    fun keepsTheLinesOfAnIndentedCodeBlock() {
        val rendered = markdownToAnnotatedString("Run this:\n\n    val a = 1\n    val b = 2")

        assertTrue(rendered.text.endsWith("val a = 1\nval b = 2"))
        assertTrue(rendered.styling("val a = 1").any { it.fontFamily == FontFamily.Monospace })
    }

    @Test
    fun setsAQuoteApartFromWhatSurroundsIt() {
        val rendered = markdownToAnnotatedString("> they said so")

        assertEquals("they said so", rendered.text)
        assertTrue(rendered.styling("they said so").any { it.fontStyle == FontStyle.Italic })
    }

    @Test
    fun keepsTheLinesOfACodeBlockAndDropsItsFence() {
        val rendered = markdownToAnnotatedString("```kotlin\nval a = 1\nval b = 2\n```")

        assertEquals("val a = 1\nval b = 2", rendered.text)
        assertTrue(rendered.styling("val a = 1").any { it.fontFamily == FontFamily.Monospace })
    }

    @Test
    fun readsASingleNewlineAsASpaceAndABlankLineAsANewParagraph() {
        val rendered = markdownToAnnotatedString("one\ntwo\n\nthree")

        assertEquals("one two\n\nthree", rendered.text)
    }

    @Test
    fun describesAnImageRatherThanLeavingAGap() {
        val rendered = markdownToAnnotatedString("![a red shirt](https://yalo.com/shirt.png)")

        assertEquals("a red shirt", rendered.text)
    }

    @Test
    fun writesOutWhatItCannotLayOutRatherThanLosingIt() {
        val table = "| size | price |\n| --- | --- |\n| S | 10 |"

        assertEquals(table, markdownToAnnotatedString(table).text)
    }

    @Test
    fun takesTheStylesItIsGiven() {
        val shout = SpanStyle(fontWeight = FontWeight.Black)

        val rendered = markdownToAnnotatedString("**loud**", MarkdownStyles(bold = shout))

        assertEquals(listOf(shout), rendered.styling("loud"))
    }

    /** The styles covering [part], so a test names what it reads instead of an offset. */
    private fun AnnotatedString.styling(part: String): List<SpanStyle> {
        val start = text.indexOf(part)
        return spanStyles
            .filter { range -> range.start <= start && range.end >= start + part.length }
            .map { range -> range.item }
    }

    private fun AnnotatedString.urls(): List<String> =
        getLinkAnnotations(0, text.length)
            .mapNotNull { range -> range.item as? LinkAnnotation.Url }
            .map { link -> link.url }
}
