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
    public var inputHintColor: Color

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
    public var currencyIconColor: Color

    // MARK: - CTA message buttons
    public var ctaButtonColor: Color
    public var ctaButtonBorderColor: Color
    public var ctaButtonTextColor: Color

    // MARK: - Buttons message buttons
    public var buttonsButtonColor: Color
    public var buttonsButtonBorderColor: Color
    public var buttonsButtonTextColor: Color

    // MARK: - Icons / footer / controls
    public var actionIconColor: Color
    public var messageFooterColor: Color
    public var expandControlColor: Color
    public var errorColor: Color

    // MARK: - Action icon colors
    public var cancelRecordingIconColor: Color
    public var closeModalIconColor: Color
    public var playAudioIconColor: Color
    public var pauseAudioIconColor: Color
    public var attachIconColor: Color
    public var cameraIconColor: Color
    public var galleryIconColor: Color
    public var trashIconColor: Color
    public var numericControlIconColor: Color
    public var imagePlaceholderIconColor: Color

    // MARK: - Attachment picker
    public var attachmentPickerBackgroundColor: Color
    public var pickerButtonBorderColor: Color

    // MARK: - Fonts
    public var userMessageFont: Font
    public var agentMessageFont: Font
    public var productTitleFont: Font
    public var productSubunitsFont: Font
    public var productPriceFont: Font
    public var messageHeaderFont: Font
    public var messageFooterFont: Font

    // MARK: - Layout
    public var bubbleCornerRadius: CGFloat

    // MARK: - Icon names (SF Symbols)
    public var sendIconName: String
    public var micIconName: String
    public var attachIconName: String
    public var shopIconName: String
    public var cartIconName: String
    public var cancelRecordingIconName: String
    public var closeModalIconName: String
    public var playIconName: String
    public var pauseIconName: String
    public var addIconName: String
    public var removeIconName: String
    public var ctaArrowIconName: String
    public var cameraIconName: String
    public var galleryIconName: String
    public var trashIconName: String
    public var imagePlaceholderIconName: String
    public var errorIconName: String

    // MARK: - Optional branding
    public var chatIconImage: Image?

    public init(
        backgroundColor: Color               = Color(.systemBackground),
        appBarBackgroundColor: Color          = Color(.systemBackground),
        userBubbleColor: Color                = Color(sdkHex: 0xF9FAFC),
        userBubbleTextColor: Color            = Color(sdkHex: 0x111111),
        agentBubbleColor: Color               = Color(.systemGray5),
        agentBubbleTextColor: Color           = Color(.label),
        inputBackgroundColor: Color           = Color(.systemBackground),
        inputBorderColor: Color               = Color(sdkHex: 0xE8E8E8),
        inputHintColor: Color                 = Color(sdkHex: 0xBEBEBE),
        sendButtonColor: Color                = Color(sdkHex: 0x2207F1),
        sendButtonIconColor: Color            = Color(sdkHex: 0xEFF4FF),
        waveformColor: Color                  = Color(sdkHex: 0x5C5EE8),
        quickReplyBackgroundColor: Color      = .clear,
        quickReplyBorderColor: Color          = Color(sdkHex: 0xECEDEF),
        quickReplyTextColor: Color            = Color(sdkHex: 0x2207F1),
        cardBackgroundColor: Color            = Color(.secondarySystemBackground),
        cardBorderColor: Color                = Color(sdkHex: 0xDDE4EC),
        productPriceColor: Color              = Color(sdkHex: 0x186C54),
        productSalePriceColor: Color          = Color(sdkHex: 0x0B996D),
        productPriceBackgroundColor: Color    = Color(sdkHex: 0xECFDF5),
        pricePerSubunitColor: Color           = Color(sdkHex: 0x334155),
        imagePlaceholderColor: Color          = Color(sdkHex: 0xF9FAFC),
        currencyIconColor: Color              = Color(sdkHex: 0x186C54),
        ctaButtonColor: Color                 = .clear,
        ctaButtonBorderColor: Color           = Color(sdkHex: 0xDDE4EC),
        ctaButtonTextColor: Color             = Color(sdkHex: 0x111111),
        buttonsButtonColor: Color             = .clear,
        buttonsButtonBorderColor: Color       = Color(sdkHex: 0xDDE4EC),
        buttonsButtonTextColor: Color         = Color(sdkHex: 0x111111),
        actionIconColor: Color                = Color(.label),
        messageFooterColor: Color             = Color(sdkHex: 0x7C8086),
        expandControlColor: Color             = Color(sdkHex: 0x2207F1),
        errorColor: Color                     = .red,
        cancelRecordingIconColor: Color       = Color(sdkHex: 0x7C8086),
        closeModalIconColor: Color            = Color(sdkHex: 0x7C8086),
        playAudioIconColor: Color             = Color(sdkHex: 0x7C8086),
        pauseAudioIconColor: Color            = Color(sdkHex: 0x7C8086),
        attachIconColor: Color                = Color(sdkHex: 0x7C8086),
        cameraIconColor: Color                = Color(sdkHex: 0x7C8086),
        galleryIconColor: Color               = Color(sdkHex: 0x7C8086),
        trashIconColor: Color                 = Color(sdkHex: 0x7C8086),
        numericControlIconColor: Color        = Color(sdkHex: 0x7C8086),
        imagePlaceholderIconColor: Color      = Color(sdkHex: 0x7C8086),
        attachmentPickerBackgroundColor: Color = Color(sdkHex: 0xF1F5FC),
        pickerButtonBorderColor: Color        = Color(sdkHex: 0xE6E6E6),
        userMessageFont: Font                 = .body,
        agentMessageFont: Font                = .body,
        productTitleFont: Font                = .subheadline,
        productSubunitsFont: Font             = .caption,
        productPriceFont: Font                = .subheadline,
        messageHeaderFont: Font               = .subheadline,
        messageFooterFont: Font               = .caption,
        bubbleCornerRadius: CGFloat           = 16,
        sendIconName: String                  = "paperplane.fill",
        micIconName: String                   = "mic.fill",
        attachIconName: String                = "paperclip",
        shopIconName: String                  = "storefront",
        cartIconName: String                  = "cart",
        cancelRecordingIconName: String       = "xmark.circle.fill",
        closeModalIconName: String            = "xmark",
        playIconName: String                  = "play.circle.fill",
        pauseIconName: String                 = "pause.circle.fill",
        addIconName: String                   = "plus",
        removeIconName: String                = "minus",
        ctaArrowIconName: String              = "arrow.right",
        cameraIconName: String                = "camera",
        galleryIconName: String               = "photo",
        trashIconName: String                 = "trash",
        imagePlaceholderIconName: String      = "photo",
        errorIconName: String                 = "exclamationmark.circle.fill",
        chatIconImage: Image?                 = nil
    ) {
        self.backgroundColor = backgroundColor
        self.appBarBackgroundColor = appBarBackgroundColor
        self.userBubbleColor = userBubbleColor
        self.userBubbleTextColor = userBubbleTextColor
        self.agentBubbleColor = agentBubbleColor
        self.agentBubbleTextColor = agentBubbleTextColor
        self.inputBackgroundColor = inputBackgroundColor
        self.inputBorderColor = inputBorderColor
        self.inputHintColor = inputHintColor
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
        self.currencyIconColor = currencyIconColor
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
        self.cancelRecordingIconColor = cancelRecordingIconColor
        self.closeModalIconColor = closeModalIconColor
        self.playAudioIconColor = playAudioIconColor
        self.pauseAudioIconColor = pauseAudioIconColor
        self.attachIconColor = attachIconColor
        self.cameraIconColor = cameraIconColor
        self.galleryIconColor = galleryIconColor
        self.trashIconColor = trashIconColor
        self.numericControlIconColor = numericControlIconColor
        self.imagePlaceholderIconColor = imagePlaceholderIconColor
        self.attachmentPickerBackgroundColor = attachmentPickerBackgroundColor
        self.pickerButtonBorderColor = pickerButtonBorderColor
        self.userMessageFont = userMessageFont
        self.agentMessageFont = agentMessageFont
        self.productTitleFont = productTitleFont
        self.productSubunitsFont = productSubunitsFont
        self.productPriceFont = productPriceFont
        self.messageHeaderFont = messageHeaderFont
        self.messageFooterFont = messageFooterFont
        self.bubbleCornerRadius = bubbleCornerRadius
        self.sendIconName = sendIconName
        self.micIconName = micIconName
        self.attachIconName = attachIconName
        self.shopIconName = shopIconName
        self.cartIconName = cartIconName
        self.cancelRecordingIconName = cancelRecordingIconName
        self.closeModalIconName = closeModalIconName
        self.playIconName = playIconName
        self.pauseIconName = pauseIconName
        self.addIconName = addIconName
        self.removeIconName = removeIconName
        self.ctaArrowIconName = ctaArrowIconName
        self.cameraIconName = cameraIconName
        self.galleryIconName = galleryIconName
        self.trashIconName = trashIconName
        self.imagePlaceholderIconName = imagePlaceholderIconName
        self.errorIconName = errorIconName
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

// MARK: - Hex color helper

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
