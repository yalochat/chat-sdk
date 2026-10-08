// Copyright (c) Yalochat, Inc. All rights reserved.

/// The details of one conversation.
///
/// - `userId`: who the person is in your app. Nil starts an anonymous
///   conversation.
/// - `hideWatermark`: leaves the "By Yalo" line out of the header.
public struct YaloChatClientConfig: Sendable, Equatable {
    public let channelId: String
    public let organizationId: String
    public let channelName: String
    public let userId: String?
    public let hideWatermark: Bool

    public init(
        channelId: String,
        organizationId: String,
        channelName: String,
        userId: String? = nil,
        hideWatermark: Bool = false
    ) {
        self.channelId = channelId
        self.organizationId = organizationId
        self.channelName = channelName
        self.userId = userId
        self.hideWatermark = hideWatermark
    }
}
