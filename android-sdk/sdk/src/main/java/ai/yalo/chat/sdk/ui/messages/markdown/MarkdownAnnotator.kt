// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.sdk.ui.messages.markdown

import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.TextLinkStyles
import androidx.compose.ui.text.withStyle
import org.intellij.markdown.IElementType
import org.intellij.markdown.MarkdownElementTypes
import org.intellij.markdown.MarkdownTokenTypes
import org.intellij.markdown.ast.ASTNode
import org.intellij.markdown.ast.findChildOfType
import org.intellij.markdown.ast.getTextInNode
import org.intellij.markdown.flavours.gfm.GFMElementTypes
import org.intellij.markdown.flavours.gfm.GFMFlavourDescriptor
import org.intellij.markdown.flavours.gfm.GFMTokenTypes
import org.intellij.markdown.parser.CancellationToken
import org.intellij.markdown.parser.MarkdownParser

/**
 * Turns the markdown an assistant writes into text Compose can draw.
 *
 * The result is one [AnnotatedString] rather than a tree of composables, so a
 * reply stays a single selectable block of text and the host's text style
 * still reaches every part of it.
 *
 * The vocabulary matches what the web SDK renders: emphasis, strikethrough,
 * code, links, headings, lists and quotes. Anything else is written out as the
 * text the author typed rather than dropped, so nothing an assistant says can
 * disappear on the way to the screen.
 */
internal fun markdownToAnnotatedString(
    source: String,
    styles: MarkdownStyles = MarkdownStyles(),
): AnnotatedString = MarkdownAnnotator(source, styles).build()

private class MarkdownAnnotator(
    private val source: CharSequence,
    private val styles: MarkdownStyles,
) {

    private val out = AnnotatedString.Builder()

    fun build(): AnnotatedString {
        val tree = MarkdownParser(
            flavour = GFMFlavourDescriptor(),
            cancellationToken = CancellationToken.NonCancellable,
        ).buildMarkdownTreeFromString(source)
        appendBlocks(tree.children)
        return out.toAnnotatedString()
    }

    /** Writes every block in [nodes], leaving a blank line between them. */
    private fun appendBlocks(nodes: List<ASTNode>) {
        nodes.filter { node -> node.type in BLOCKS }
            .forEachIndexed { index, node ->
                if (index > 0) {
                    out.append(PARAGRAPH_BREAK)
                }
                appendBlock(node)
            }
    }

    private fun appendBlock(node: ASTNode) {
        when (node.type) {
            MarkdownElementTypes.PARAGRAPH -> appendInline(node.children)

            MarkdownElementTypes.UNORDERED_LIST,
            MarkdownElementTypes.ORDERED_LIST,
            -> appendList(node, depth = 0)

            MarkdownElementTypes.BLOCK_QUOTE -> out.withStyle(styles.quote) {
                appendBlocks(node.children)
            }

            MarkdownElementTypes.CODE_FENCE,
            MarkdownElementTypes.CODE_BLOCK,
            -> appendCode(node)

            in HEADING_LEVELS.keys -> appendHeading(node)

            else -> out.append(node.text())
        }
    }

    private fun appendHeading(node: ASTNode) {
        val content = node.findChildOfType(MarkdownTokenTypes.ATX_CONTENT)
            ?: node.findChildOfType(MarkdownTokenTypes.SETEXT_CONTENT)
            ?: return
        val words = content.children
            .dropWhile { child -> child.type == MarkdownTokenTypes.WHITE_SPACE }
        out.withStyle(styles.headings[HEADING_LEVELS.getValue(node.type)]) {
            appendInline(words)
        }
    }

    /**
     * Writes a list, and the lists inside it, one item per line.
     *
     * The bullet and the indentation are part of the text rather than a layout
     * around it, which is what keeps the whole message one selectable block.
     */
    private fun appendList(list: ASTNode, depth: Int) {
        list.children.filter { child -> child.type == MarkdownElementTypes.LIST_ITEM }
            .forEachIndexed { index, item ->
                if (index > 0) {
                    out.append(LINE_BREAK)
                }
                out.append(INDENT.repeat(depth))
                out.append(marker(item))
                appendItem(item, depth)
            }
    }

    private fun marker(item: ASTNode): String {
        val number = item.findChildOfType(MarkdownTokenTypes.LIST_NUMBER) ?: return BULLET
        return number.text().trim() + " "
    }

    private fun appendItem(item: ASTNode, depth: Int) {
        var written = false
        item.children.filter { child -> child.type in BLOCKS }.forEach { child ->
            if (written) {
                out.append(LINE_BREAK)
            }
            when (child.type) {
                MarkdownElementTypes.UNORDERED_LIST,
                MarkdownElementTypes.ORDERED_LIST,
                -> appendList(child, depth + 1)

                else -> appendBlock(child)
            }
            written = true
        }
    }

    private fun appendCode(node: ASTNode) {
        // An indented block keeps the four spaces that made it code, and they
        // are not part of what the author wrote.
        val lines = node.children
            .filter { child -> child.type in CODE_CONTENT }
            .map { child -> child.text().removePrefix(CODE_BLOCK_INDENT) }
        out.withStyle(styles.code) {
            append(lines.joinToString(LINE_BREAK))
        }
    }

    private fun appendInline(nodes: List<ASTNode>) {
        // A break is written as two spaces and the newline that follows them,
        // so the newline is already spoken for.
        val visible = nodes.filterIndexed { index, node ->
            node.type != MarkdownTokenTypes.EOL ||
                nodes.getOrNull(index - 1)?.type != MarkdownTokenTypes.HARD_LINE_BREAK
        }
        visible.forEach { node ->
            when (node.type) {
                MarkdownElementTypes.STRONG -> out.withStyle(styles.bold) {
                    appendInline(node.inside(STRONG_MARKERS))
                }

                MarkdownElementTypes.EMPH -> out.withStyle(styles.italic) {
                    appendInline(node.inside(EMPH_MARKERS))
                }

                GFMElementTypes.STRIKETHROUGH -> out.withStyle(styles.strikethrough) {
                    appendInline(node.inside(STRIKETHROUGH_MARKERS))
                }

                MarkdownElementTypes.CODE_SPAN -> out.withStyle(styles.code) {
                    val code = node.inside(CODE_SPAN_MARKERS)
                    append(code.joinToString("") { child -> child.text() })
                }

                MarkdownElementTypes.INLINE_LINK -> appendLink(node)
                MarkdownElementTypes.IMAGE -> appendImage(node)
                MarkdownElementTypes.AUTOLINK -> appendUrl(node.text().trim('<', '>'))
                GFMTokenTypes.GFM_AUTOLINK -> appendUrl(node.text())

                // A newline inside a paragraph is a space, the way it reads in
                // the web SDK. Only an explicit break starts a new line.
                MarkdownTokenTypes.EOL -> out.append(" ")
                MarkdownTokenTypes.HARD_LINE_BREAK -> out.append(LINE_BREAK)

                else -> if (node.children.isEmpty()) {
                    out.append(node.text())
                } else {
                    appendInline(node.children)
                }
            }
        }
    }

    private fun appendLink(node: ASTNode) {
        val destination = node.findChildOfType(MarkdownElementTypes.LINK_DESTINATION)
            ?.text()
            ?.trim('<', '>')
        if (destination == null) {
            appendInline(node.children)
            return
        }
        val label = node.findChildOfType(MarkdownElementTypes.LINK_TEXT)?.inside(LINK_TEXT_MARKERS)
        out.pushLink(LinkAnnotation.Url(destination, TextLinkStyles(style = styles.link)))
        if (label.isNullOrEmpty()) {
            out.append(destination)
        } else {
            appendInline(label)
        }
        out.pop()
    }

    /**
     * Writes the description of an image rather than the image.
     *
     * A picture an assistant sends arrives as its own message with its own kind,
     * so an image inside markdown is decoration, and its description is the part
     * worth reading.
     */
    private fun appendImage(node: ASTNode) {
        val label = node.findChildOfType(MarkdownElementTypes.INLINE_LINK)
            ?.findChildOfType(MarkdownElementTypes.LINK_TEXT)
        if (label == null) {
            out.append(node.text())
            return
        }
        appendInline(label.inside(LINK_TEXT_MARKERS))
    }

    private fun appendUrl(url: String) {
        out.pushLink(LinkAnnotation.Url(url, TextLinkStyles(style = styles.link)))
        out.append(url)
        out.pop()
    }

    /** The children of a node without the markers that delimit it. */
    private fun ASTNode.inside(markers: Int): List<ASTNode> =
        children.drop(markers).dropLast(markers)

    private fun ASTNode.text(): String = getTextInNode(source).toString()
}

private const val PARAGRAPH_BREAK = "\n\n"
private const val LINE_BREAK = "\n"
private const val BULLET = "• "
private const val INDENT = "    "
private const val CODE_BLOCK_INDENT = "    "

private const val EMPH_MARKERS = 1
private const val STRONG_MARKERS = 2
private const val STRIKETHROUGH_MARKERS = 2
private const val CODE_SPAN_MARKERS = 1
private const val LINK_TEXT_MARKERS = 1

/** Which of [MarkdownStyles.headings] each kind of heading is drawn with. */
private val HEADING_LEVELS: Map<IElementType, Int> = mapOf(
    MarkdownElementTypes.ATX_1 to 0,
    MarkdownElementTypes.ATX_2 to 1,
    MarkdownElementTypes.ATX_3 to 2,
    MarkdownElementTypes.ATX_4 to 3,
    MarkdownElementTypes.ATX_5 to 4,
    MarkdownElementTypes.ATX_6 to 5,
    MarkdownElementTypes.SETEXT_1 to 0,
    MarkdownElementTypes.SETEXT_2 to 1,
)

private val BLOCKS: Set<IElementType> = setOf(
    MarkdownElementTypes.PARAGRAPH,
    MarkdownElementTypes.UNORDERED_LIST,
    MarkdownElementTypes.ORDERED_LIST,
    MarkdownElementTypes.BLOCK_QUOTE,
    MarkdownElementTypes.CODE_FENCE,
    MarkdownElementTypes.CODE_BLOCK,
    GFMElementTypes.TABLE,
) + HEADING_LEVELS.keys

private val CODE_CONTENT: Set<IElementType> = setOf(
    MarkdownTokenTypes.CODE_FENCE_CONTENT,
    MarkdownTokenTypes.CODE_LINE,
)
