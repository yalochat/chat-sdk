// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// Turns the markdown an assistant writes into one block of text.
///
/// `Text` draws emphasis, strikethrough, inline code and links on its own but
/// ignores blocks, so headings, lists, quotes and code blocks are written out
/// here. Text that cannot be parsed is shown as it was written.
func markdown(_ source: String) -> AttributedString {
    let options: AttributedString.MarkdownParsingOptions = AttributedString.MarkdownParsingOptions(
        interpretedSyntax: .full,
        failurePolicy: .returnPartiallyParsedIfPossible
    )
    guard let parsed = try? AttributedString(markdown: source, options: options) else {
        return AttributedString(source)
    }
    var output: AttributedString = AttributedString()
    var previous: PresentationIntent?
    for run in parsed.runs {
        let intent: PresentationIntent? = run.presentationIntent
        if intent != previous {
            if previous != nil {
                // Items of a list sit on consecutive lines, any other block is a paragraph.
                let bothListItems: Bool = listItem(in: intent) != nil && listItem(in: previous) != nil
                output += AttributedString(bothListItems ? "\n" : "\n\n")
            }
            if let item = listItem(in: intent), item.identity != listItem(in: previous)?.identity {
                output += AttributedString(listMarker(in: intent))
            }
            previous = intent
        }
        var piece: AttributedString = AttributedString(parsed[run.range])
        for component in intent?.components ?? [] {
            switch component.kind {
            case .header(let level):
                piece.font = level == 1 ? .title2.bold() : level == 2 ? .title3.bold() : .headline
            case .codeBlock:
                piece.font = .system(.body, design: .monospaced)
                while piece.characters.last?.isNewline == true {
                    piece.characters.removeLast()
                }
            case .blockQuote:
                piece.foregroundColor = .secondary
            default:
                break
            }
        }
        output += piece
    }
    return output
}

private func listItem(in intent: PresentationIntent?) -> PresentationIntent.IntentType? {
    intent?.components.first { component in
        if case .listItem = component.kind {
            return true
        }
        return false
    }
}

/// The bullet or number of the innermost item, indented by how deep it is nested.
private func listMarker(in intent: PresentationIntent?) -> String {
    let components: [PresentationIntent.IntentType] = intent?.components ?? []
    var depth: Int = -1
    var ordinal: Int = 0
    var ordered: Bool?
    for component in components {
        switch component.kind {
        case .listItem(let number) where ordered == nil:
            ordinal = number
        case .orderedList, .unorderedList:
            if ordered == nil {
                ordered = component.kind == .orderedList
            }
            depth += 1
        default:
            break
        }
    }
    let indent: String = String(repeating: "    ", count: max(depth, 0))
    return indent + (ordered == true ? "\(ordinal). " : "• ")
}
