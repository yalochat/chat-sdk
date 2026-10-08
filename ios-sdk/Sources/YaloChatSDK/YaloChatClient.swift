// Copyright (c) Yalochat, Inc. All rights reserved.

/// The way into the SDK.
///
/// Creating one costs nothing: storage and the connection are built only when
/// a chat is shown, so an app can hold one client per conversation.
public final class YaloChatClient: Sendable {
    let config: YaloChatClientConfig

    public init(config: YaloChatClientConfig) {
        self.config = config
    }
}
