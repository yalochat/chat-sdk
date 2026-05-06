// Copyright (c) Yalochat, Inc. All rights reserved.

// Mirrors Flutter's ChatTheme and Android's ChatTheme.
// Inject via .environment(\.chatTheme, theme) at ChatView root;
// consume via @Environment(\.chatTheme) in child views.
// Default values match Flutter SDK's light theme color constants (SdkColors).

import SwiftUI

public struct ChatTheme {

    // MARK: - Backgrounds
    public var backgroundColor: Color
    public var appBarBackgroundColor: Color

    // MARK: - User message bubble
    public var userBubbleColor: Color
    public var userBubbleTextColor: Color

    // MARK: - Agent message bubble
    public var agentBubbleColor: Color
    public var agentBubbleTextColor: Color

    // MARK: - Input bar
    public var inputBackgroundColor: Color
    public var inputBorderColor: Color

    // MARK: - Send / mic action button
    public var sendButtonColor: Color
    public var sendButtonIconColor: Color

    // MARK: - Audio waveform
    public var waveformColor: Color

    // MARK: - Quick reply chips
    public var quickReplyBackgroundColor: Color
    public var quickReplyBorderColor: Color
    public var quickReplyTextColor: Color

    // MARK: - Product / message cards
    public var cardBackgroundColor: Color
    public var cardBorderColor: Color

    // MARK: - Product pricing
    public var productPriceColor: Color
    public var productSalePriceColor: Color
    public var productPriceBackgroundColor: Color
    public var pricePerSubunitColor: Color
    public var imagePlaceholderColor: Color

    // MARK: - CTA message buttons
    public var ctaButtonColor: Color
    public var ctaButtonBorderColor: Color
    public var ctaButtonTextColor: Color

    // MARK: - Buttons message buttons
    public var buttonsButtonColor: Color
    public var buttonsButtonBorderColor: Color
    public var buttonsButtonTextColor: Color

    // MARK: - Icons / footer
    public var actionIconColor: Color
    public var messageFooterColor: Color
    public var expandControlColor: Color
    public var errorColor: Color

    // MARK: - Fonts
    public var userMessageFont: Font
    public var agentMessageFont: Font
    public var productTitleFont: Font
    public var productSubunitsFont: Font
    public var productPriceFont: Font
    public var messageHeaderFont: Font
    public var messageFooterFont: Font

    // MARK: - Icon names (SF Symbols)
    public var sendIconName: String
    public var micIconName: String
    public var attachIconName: String
    public var shopIconName: String
    public var cartIconName: String
    public var cancelRecordingIconName: String
    public var playIconName: String
    public var pauseIconName: String
    public var addIconName: String
    public var removeIconName: String
    public var ctaArrowIconName: String

    // MARK: - Optional branding
    public var chatIconImage: Image?

    public init(
        backgroundColor: Color          = Color(.systemBackground),
        appBarBackgroundColor: Color     = Color(.systemBackground),
        userBubbleColor: Color           = Color(sdkHex: 0xF9FAFC),
        userBubbleTextColor: Color       = Color(sdkHex: 0x111111),
        agentBubbleColor: Color          = Color(.systemGray5),
        agentBubbleTextColor: Color      = Color(.label),
        inputBackgroundColor: Color      = Color(.systemBackground),
        inputBorderColor: Color          = Color(sdkHex: 0xE8E8E8),
        sendButtonColor: Color           = Color(sdkHex: 0x2207F1),
        sendButtonIconColor: Color       = Color(sdkHex: 0xEFF4FF),
        waveformColor: Color             = Color(sdkHex: 0x5C5EE8),
        quickReplyBackgroundColor: Color = .clear,
        quickReplyBorderColor: Color     = Color(sdkHex: 0xECEDEF),
        quickReplyTextColor: Color       = Color(sdkHex: 0x2207F1),
        cardBackgroundColor: Color       = Color(.secondarySystemBackground),
        cardBorderColor: Color           = Color(sdkHex: 0xDDE4EC),
        productPriceColor: Color         = Color(sdkHex: 0x186C54),
        productSalePriceColor: Color     = Color(sdkHex: 0x0B996D),
        productPriceBackgroundColor: Color = Color(sdkHex: 0xECFDF5),
        pricePerSubunitColor: Color      = Color(sdkHex: 0x334155),
        imagePlaceholderColor: Color     = Color(sdkHex: 0xF9FAFC),
        ctaButtonColor: Color            = .clear,
        ctaButtonBorderColor: Color      = Color(sdkHex: 0xDDE4EC),
        ctaButtonTextColor: Color        = Color(sdkHex: 0x111111),
        buttonsButtonColor: Color        = .clear,
        buttonsButtonBorderColor: Color  = Color(sdkHex: 0xDDE4EC),
        buttonsButtonTextColor: Color    = Color(sdkHex: 0x111111),
        actionIconColor: Color           = Color(.label),
        messageFooterColor: Color        = Color(sdkHex: 0x7C8086),
        expandControlColor: Color        = Color(sdkHex: 0x2207F1),
        errorColor: Color                = .red,
        userMessageFont: Font            = .body,
        agentMessageFont: Font           = .body,
        productTitleFont: Font           = .subheadline,
        productSubunitsFont: Font        = .caption,
        productPriceFont: Font           = .subheadline,
        messageHeaderFont: Font          = .subheadline,
        messageFooterFont: Font          = .caption,
        sendIconName: String             = "paperplane.fill",
        micIconName: String              = "mic.fill",
        attachIconName: String           = "paperclip",
        shopIconName: String             = "storefront",
        cartIconName: String             = "cart",
        cancelRecordingIconName: String  = "xmark.circle.fill",
        playIconName: String             = "play.fill",
        pauseIconName: String            = "pause.fill",
        addIconName: String              = "plus",
        removeIconName: String           = "minus",
        ctaArrowIconName: String         = "arrow.right",
        chatIconImage: Image?            = nil
    ) {
        self.backgroundColor = backgroundColor
        self.appBarBackgroundColor = appBarBackgroundColor
        self.userBubbleColor = userBubbleColor
        self.userBubbleTextColor = userBubbleTextColor
        self.agentBubbleColor = agentBubbleColor
        self.agentBubbleTextColor = agentBubbleTextColor
        self.inputBackgroundColor = inputBackgroundColor
        self.inputBorderColor = inputBorderColor
        self.sendButtonColor = sendButtonColor
        self.sendButtonIconColor = sendButtonIconColor
        self.waveformColor = waveformColor
        self.quickReplyBackgroundColor = quickReplyBackgroundColor
        self.quickReplyBorderColor = quickReplyBorderColor
        self.quickReplyTextColor = quickReplyTextColor
        self.cardBackgroundColor = cardBackgroundColor
        self.cardBorderColor = cardBorderColor
        self.productPriceColor = productPriceColor
        self.productSalePriceColor = productSalePriceColor
        self.productPriceBackgroundColor = productPriceBackgroundColor
        self.pricePerSubunitColor = pricePerSubunitColor
        self.imagePlaceholderColor = imagePlaceholderColor
        self.ctaButtonColor = ctaButtonColor
        self.ctaButtonBorderColor = ctaButtonBorderColor
        self.ctaButtonTextColor = ctaButtonTextColor
        self.buttonsButtonColor = buttonsButtonColor
        self.buttonsButtonBorderColor = buttonsButtonBorderColor
        self.buttonsButtonTextColor = buttonsButtonTextColor
        self.actionIconColor = actionIconColor
        self.messageFooterColor = messageFooterColor
        self.expandControlColor = expandControlColor
        self.errorColor = errorColor
        self.userMessageFont = userMessageFont
        self.agentMessageFont = agentMessageFont
        self.productTitleFont = productTitleFont
        self.productSubunitsFont = productSubunitsFont
        self.productPriceFont = productPriceFont
        self.messageHeaderFont = messageHeaderFont
        self.messageFooterFont = messageFooterFont
        self.sendIconName = sendIconName
        self.micIconName = micIconName
        self.attachIconName = attachIconName
        self.shopIconName = shopIconName
        self.cartIconName = cartIconName
        self.cancelRecordingIconName = cancelRecordingIconName
        self.playIconName = playIconName
        self.pauseIconName = pauseIconName
        self.addIconName = addIconName
        self.removeIconName = removeIconName
        self.ctaArrowIconName = ctaArrowIconName
        self.chatIconImage = chatIconImage
    }
}

// MARK: - SwiftUI environment plumbing

struct ChatThemeKey: EnvironmentKey {
    static let defaultValue = ChatTheme()
}

extension EnvironmentValues {
    var chatTheme: ChatTheme {
        get { self[ChatThemeKey.self] }
        set { self[ChatThemeKey.self] = newValue }
    }
}

// MARK: - Hex color helper (internal — used by ChatTheme defaults and views)

extension Color {
    // Converts a 24-bit RGB hex value (e.g. 0x2207F1) to a SwiftUI Color.
    // Named sdkHex to avoid colliding with other hex extensions in consumer apps.
    public init(sdkHex hex: UInt32) {
        self.init(
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255
        )
    }
}
