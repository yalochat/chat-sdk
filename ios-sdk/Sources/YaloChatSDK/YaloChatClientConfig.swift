// Copyright (c) Yalochat, Inc. All rights reserved.

/// The details of one conversation.
///
/// - `userId`: who the person is in your app. Nil starts an anonymous
///   conversation.
/// - `quickReplyType`: where the answers a message offers are shown, in a
///   bar above the message input or under the message that offered them.
/// - `welcomeMessageType`: how the first message of a conversation is drawn.
/// - `logLevel`: how much the SDK writes to the unified log.
/// - `openContext`: what the chat is being opened from, for example the
///   product a person was looking at. Sent to the channel when the chat opens
///   on an empty conversation, so it can speak first.
/// - `sessionMode`: how the conversation is scoped, and whether it is
///   remembered between visits.
/// - `hideWatermark`: leaves the "By Yalo" line out of the header.
/// - `hideVoiceButton`: leaves the microphone out of the message input, so
///   nobody can record a voice message.
/// - `hideAttachmentButton`: leaves the plus out of the message input, so
///   nobody can pick a picture to send.
/// - `hideFeedbackButtons`: leaves the thumbs up and thumbs down out from
///   under the channel's messages, so nobody can rate them.
public struct YaloChatClientConfig: Sendable, Equatable {
    public let channelId: String
    public let organizationId: String
    public let channelName: String
    public let userId: String?
    public let quickReplyType: QuickReplyType
    public let welcomeMessageType: WelcomeMessageType
    public let logLevel: LogLevel
    public let openContext: [String: String]
    public let sessionMode: SessionMode
    public let hideWatermark: Bool
    public let hideVoiceButton: Bool
    public let hideAttachmentButton: Bool
    public let hideFeedbackButtons: Bool

    public init(
        channelId: String,
        organizationId: String,
        channelName: String,
        userId: String? = nil,
        quickReplyType: QuickReplyType = .modal,
        welcomeMessageType: WelcomeMessageType = .none,
        logLevel: LogLevel = .warn,
        openContext: [String: String] = [:],
        sessionMode: SessionMode = .shared,
        hideWatermark: Bool = false,
        hideVoiceButton: Bool = false,
        hideAttachmentButton: Bool = false,
        hideFeedbackButtons: Bool = false
    ) {
        self.channelId = channelId
        self.organizationId = organizationId
        self.channelName = channelName
        self.userId = userId
        self.quickReplyType = quickReplyType
        self.welcomeMessageType = welcomeMessageType
        self.logLevel = logLevel
        self.openContext = openContext
        self.sessionMode = sessionMode
        self.hideWatermark = hideWatermark
        self.hideVoiceButton = hideVoiceButton
        self.hideAttachmentButton = hideAttachmentButton
        self.hideFeedbackButtons = hideFeedbackButtons
    }

    /// The conversation before `sessionMode` has had its say: the whole
    /// session in `shared`, and the start of it in the other modes. Built like
    /// the other SDKs', so all agree on what one conversation is.
    var baseSessionId: String {
        "\(organizationId)-\(channelId)-\(userId ?? "anonymous")"
    }
}
