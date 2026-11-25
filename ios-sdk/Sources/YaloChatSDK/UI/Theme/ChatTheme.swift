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
    public var assistantMessageBackground: Color
    public var onAssistantMessageBackground: Color
    public var assistantMessageShape: ChatShape
    public var assistantMessageBorderColor: Color
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
    public var postbackShape: ChatShape
    public var messageTailSize: CGSize
    public var timestampColor: Color
    public var selectedPostbackBorderColor: Color?
    public var disabledSendButtonBackground: Color?
    public var onDisabledSendButtonBackground: Color?
    public var inputPlaceholderColor: Color
    public var userMessagePadding: EdgeInsets
    public var assistantMessagePadding: EdgeInsets
    public var feedbackButtonColor: Color?

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
        assistantMessageBackground: Color = .clear,
        onAssistantMessageBackground: Color = Color(.label),
        assistantMessageShape: ChatShape = ChatShape(radius: 0),
        assistantMessageBorderColor: Color = .clear,
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
        fontFamily: String? = nil,
        postbackShape: ChatShape = ChatShape(radius: 8),
        messageTailSize: CGSize = .zero,
        timestampColor: Color = Color(.secondaryLabel),
        selectedPostbackBorderColor: Color? = nil,
        disabledSendButtonBackground: Color? = nil,
        onDisabledSendButtonBackground: Color? = nil,
        inputPlaceholderColor: Color = Color(.placeholderText),
        userMessagePadding: EdgeInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16),
        assistantMessagePadding: EdgeInsets = EdgeInsets(),
        feedbackButtonColor: Color? = nil
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
        self.assistantMessageBackground = assistantMessageBackground
        self.onAssistantMessageBackground = onAssistantMessageBackground
        self.assistantMessageShape = assistantMessageShape
        self.assistantMessageBorderColor = assistantMessageBorderColor
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
        self.postbackShape = postbackShape
        self.messageTailSize = messageTailSize
        self.timestampColor = timestampColor
        self.selectedPostbackBorderColor = selectedPostbackBorderColor
        self.disabledSendButtonBackground = disabledSendButtonBackground
        self.onDisabledSendButtonBackground = onDisabledSendButtonBackground
        self.inputPlaceholderColor = inputPlaceholderColor
        self.userMessagePadding = userMessagePadding
        self.assistantMessagePadding = assistantMessagePadding
        self.feedbackButtonColor = feedbackButtonColor
    }
}

extension ChatTheme {
    @available(*, deprecated, renamed: "assistantMessageBackground")
    public var agentMessageBackground: Color {
        get { assistantMessageBackground }
        set { assistantMessageBackground = newValue }
    }

    @available(*, deprecated, renamed: "onAssistantMessageBackground")
    public var onAgentMessageBackground: Color {
        get { onAssistantMessageBackground }
        set { onAssistantMessageBackground = newValue }
    }

    @available(*, deprecated, renamed: "assistantMessageShape")
    public var agentMessageShape: ChatShape {
        get { assistantMessageShape }
        set { assistantMessageShape = newValue }
    }

    @available(*, deprecated, renamed: "assistantMessageBorderColor")
    public var agentMessageBorderColor: Color {
        get { assistantMessageBorderColor }
        set { assistantMessageBorderColor = newValue }
    }

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
