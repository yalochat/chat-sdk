// Copyright (c) Yalochat, Inc. All rights reserved.

/// The details of one conversation.
///
/// - `userId`: who the person is in your app. Nil starts an anonymous
///   conversation.
/// - `hideWatermark`: leaves the "By Yalo" line out of the header.
/// - `hideVoiceButton`: leaves the microphone out of the message input, so
///   nobody can record a voice message.
/// - `hideAttachmentButton`: leaves the plus out of the message input, so
///   nobody can pick a picture to send.
public struct YaloChatClientConfig: Sendable, Equatable {
    public let channelId: String
    public let organizationId: String
    public let channelName: String
    public let userId: String?
    public let hideWatermark: Bool
    public let hideVoiceButton: Bool
    public let hideAttachmentButton: Bool

    public init(
        channelId: String,
        organizationId: String,
        channelName: String,
        userId: String? = nil,
        hideWatermark: Bool = false,
        hideVoiceButton: Bool = false,
        hideAttachmentButton: Bool = false
    ) {
        self.channelId = channelId
        self.organizationId = organizationId
        self.channelName = channelName
        self.userId = userId
        self.hideWatermark = hideWatermark
        self.hideVoiceButton = hideVoiceButton
        self.hideAttachmentButton = hideAttachmentButton
    }

    /// Scopes what the device keeps for this conversation. Built like the
    /// Android SDK's, so both agree on what one conversation is.
    var sessionId: String {
        "\(organizationId)-\(channelId)-\(userId ?? "anonymous")"
    }
}
