// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// Runs a command the channel asked for. It receives the request payload and
/// returns the payload sent back. Throwing reports the command as failed.
public typealias CommandHandler = @Sendable (_ payload: String) async throws -> String

/// The way into the SDK.
///
/// Creating one costs nothing: storage and the connection are built only when
/// a chat is shown, so an app can hold one client per conversation.
public final class YaloChatClient: @unchecked Sendable {
    let config: YaloChatClientConfig
    private let lock: NSLock = NSLock()
    private var commands: [String: CommandHandler] = [:]

    public init(config: YaloChatClientConfig) {
        self.config = config
    }

    /// Runs `handler` whenever the channel asks for `command` while a chat is
    /// open. Registering the same command again replaces its handler.
    public func registerCommand(_ command: String, handler: @escaping CommandHandler) {
        lock.withLock {
            commands[command] = handler
        }
    }

    func commandHandler(for command: String) -> CommandHandler? {
        lock.withLock {
            commands[command]
        }
    }
}
