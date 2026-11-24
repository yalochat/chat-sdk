// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// How the chat paints itself.
///
/// Every value defaults to a system color, so the chat follows light and dark
/// mode with no setup. Override only what you need:
///
/// ```swift
/// Chat(client: client, theme: ChatTheme(headerBackground: .indigo, onHeaderBackground: .white))
/// ```
///
/// `fontFamily` is the family name of a font your app registered. Text keeps
/// its size, weight and Dynamic Type scaling.
public struct ChatTheme: Sendable, Equatable {
    public var background: Color
    public var headerBackground: Color
    public var onHeaderBackground: Color
    public var footerBackground: Color
    public var onFooterBackground: Color
    public var inputBorderColor: Color
    public var inputBackground: Color
    public var inputShape: ChatShape
    public var inputScrollbarColor: Color
    public var inputScrollbarWidth: CGFloat
    public var sendButtonBackground: Color
    public var onSendButtonBackground: Color
    public var userMessageBackground: Color
    public var onUserMessageBackground: Color
    public var userMessageShape: ChatShape
    public var agentMessageBackground: Color
    public var onAgentMessageBackground: Color
    public var agentMessageShape: ChatShape
    public var agentMessageBorderColor: Color
    public var agentMessagePadding: CGFloat
    public var typingIndicatorDotColor: Color
    public var quickReplyBackground: Color
    public var onQuickReplyBackground: Color
    public var quickReplyBorderColor: Color
    public var quickReplyShape: ChatShape
    public var postbackBackground: Color
    public var onPostbackBackground: Color
    public var postbackBorderColor: Color
    public var selectedPostbackBackground: Color
    public var onSelectedPostbackBackground: Color
    public var userAvatarBackground: Color
    public var onUserAvatarBackground: Color
    public var assistantAvatarBackground: Color
    public var onAssistantAvatarBackground: Color
    public var fontFamily: String?

    public init(
        background: Color = Color(.systemBackground),
        headerBackground: Color = Color(.secondarySystemBackground),
        onHeaderBackground: Color = Color(.label),
        footerBackground: Color = Color(.secondarySystemBackground),
        onFooterBackground: Color = Color(.label),
        inputBorderColor: Color = Color(.separator),
        inputBackground: Color = .clear,
        // A capsule at one line (42 points), rounded corners once taller.
        inputShape: ChatShape = ChatShape(radius: 21),
        inputScrollbarColor: Color = Color(.systemGray3),
        inputScrollbarWidth: CGFloat = 3,
        sendButtonBackground: Color = .accentColor,
        onSendButtonBackground: Color = .white,
        userMessageBackground: Color = Color(.secondarySystemBackground),
        onUserMessageBackground: Color = Color(.label),
        userMessageShape: ChatShape = ChatShape(radius: 18),
        // Unbubbled, like the web SDK, so it reads as the conversation itself.
        agentMessageBackground: Color = .clear,
        onAgentMessageBackground: Color = Color(.label),
        agentMessageShape: ChatShape = ChatShape(radius: 0),
        agentMessageBorderColor: Color = .clear,
        agentMessagePadding: CGFloat = 0,
        typingIndicatorDotColor: Color = Color(.secondaryLabel),
        // Outlined rather than filled, like the web SDK, so a quick reply reads
        // as an offer rather than as something said.
        quickReplyBackground: Color = .clear,
        onQuickReplyBackground: Color = Color(.label),
        quickReplyBorderColor: Color = Color(.separator),
        quickReplyShape: ChatShape = .capsule,
        postbackBackground: Color = .clear,
        onPostbackBackground: Color = Color(.label),
        postbackBorderColor: Color = Color(.separator),
        selectedPostbackBackground: Color = Color(.tertiarySystemFill),
        onSelectedPostbackBackground: Color = Color(.label),
        userAvatarBackground: Color = Color(.systemGray5),
        onUserAvatarBackground: Color = Color(.label),
        assistantAvatarBackground: Color = .accentColor,
        onAssistantAvatarBackground: Color = .white,
        fontFamily: String? = nil
    ) {
        self.background = background
        self.headerBackground = headerBackground
        self.onHeaderBackground = onHeaderBackground
        self.footerBackground = footerBackground
        self.onFooterBackground = onFooterBackground
        self.inputBorderColor = inputBorderColor
        self.inputBackground = inputBackground
        self.inputShape = inputShape
        self.inputScrollbarColor = inputScrollbarColor
        self.inputScrollbarWidth = inputScrollbarWidth
        self.sendButtonBackground = sendButtonBackground
        self.onSendButtonBackground = onSendButtonBackground
        self.userMessageBackground = userMessageBackground
        self.onUserMessageBackground = onUserMessageBackground
        self.userMessageShape = userMessageShape
        self.agentMessageBackground = agentMessageBackground
        self.onAgentMessageBackground = onAgentMessageBackground
        self.agentMessageShape = agentMessageShape
        self.agentMessageBorderColor = agentMessageBorderColor
        self.agentMessagePadding = agentMessagePadding
        self.typingIndicatorDotColor = typingIndicatorDotColor
        self.quickReplyBackground = quickReplyBackground
        self.onQuickReplyBackground = onQuickReplyBackground
        self.quickReplyBorderColor = quickReplyBorderColor
        self.quickReplyShape = quickReplyShape
        self.postbackBackground = postbackBackground
        self.onPostbackBackground = onPostbackBackground
        self.postbackBorderColor = postbackBorderColor
        self.selectedPostbackBackground = selectedPostbackBackground
        self.onSelectedPostbackBackground = onSelectedPostbackBackground
        self.userAvatarBackground = userAvatarBackground
        self.onUserAvatarBackground = onUserAvatarBackground
        self.assistantAvatarBackground = assistantAvatarBackground
        self.onAssistantAvatarBackground = onAssistantAvatarBackground
        self.fontFamily = fontFamily
    }
}

extension ChatTheme {
    /// The text style in `fontFamily`, or the system font when there is none.
    func font(_ style: Font.TextStyle) -> Font {
        guard let fontFamily else {
            return style.systemFont
        }
        let custom: Font = .custom(fontFamily, size: Self.defaultSize(of: style.uiTextStyle), relativeTo: style)
        // The system draws headlines in semibold, so the custom one matches.
        if style == .headline {
            return custom.weight(.semibold)
        }
        return custom
    }

    /// The text style in `fontFamily` for UIKit views, or the system font when that family is not registered.
    func uiFont(_ style: UIFont.TextStyle) -> UIFont {
        guard let fontFamily, UIFont.familyNames.contains(fontFamily) else {
            return .preferredFont(forTextStyle: style)
        }
        let descriptor: UIFontDescriptor = UIFontDescriptor(fontAttributes: [.family: fontFamily])
        let base: UIFont = UIFont(descriptor: descriptor, size: Self.defaultSize(of: style))
        return UIFontMetrics(forTextStyle: style).scaledFont(for: base)
    }

    /// The size the system gives the style before Dynamic Type scales it.
    private static func defaultSize(of style: UIFont.TextStyle) -> CGFloat {
        let traits: UITraitCollection = UITraitCollection(preferredContentSizeCategory: .large)
        return UIFont.preferredFont(forTextStyle: style, compatibleWith: traits).pointSize
    }
}

private extension Font.TextStyle {
    var systemFont: Font {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption:
            return .caption
        case .caption2:
            return .caption2
        default:
            return .body
        }
    }

    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title1
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption:
            return .caption1
        case .caption2:
            return .caption2
        default:
            return .body
        }
    }
}

extension EnvironmentValues {
    @Entry var chatTheme: ChatTheme = ChatTheme()
}
