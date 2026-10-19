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
    private let chatMessages: ChatMessageService
    private let log: YaloLog
    private let lock: NSLock = NSLock()
    private var commands: [String: CommandHandler] = [:]
    private var clearListeners: [UUID: AsyncStream<Void>.Continuation] = [:]

    public convenience init(config: YaloChatClientConfig) {
        self.init(
            config: config,
            chatMessages: ChatMessageDatabaseService(fileURL: ChatDependencies.databaseURL, logLevel: config.logLevel)
        )
    }

    init(config: YaloChatClientConfig, chatMessages: ChatMessageService) {
        self.config = config
        self.chatMessages = chatMessages
        self.log = YaloLog("Client", level: config.logLevel)
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

    /// Deletes every message of the conversation, whether a chat is showing it
    /// or not, for example when the person logs out. A chat showing it empties
    /// and the channel greets the person again, as in a new conversation.
    public func clearMessages() async {
        // An ephemeral conversation is forgotten with its chat, so only a chat
        // showing one has anything to delete.
        if config.sessionMode != .ephemeral {
            do {
                try await chatMessages.deleteSessions([ChatSession(config: config).id])
            } catch {
                log.error("could not clear the messages", error: error)
            }
        }
        let listeners: [AsyncStream<Void>.Continuation] = lock.withLock {
            Array(clearListeners.values)
        }
        for listener in listeners {
            listener.yield()
        }
    }

    /// Yields every time the host asks to clear the messages.
    func clearRequests() -> AsyncStream<Void> {
        let id: UUID = UUID()
        let (stream, continuation): (AsyncStream<Void>, AsyncStream<Void>.Continuation) = AsyncStream.makeStream()
        continuation.onTermination = { [weak self] _ in
            self?.lock.withLock {
                self?.clearListeners[id] = nil
            }
        }
        lock.withLock {
            clearListeners[id] = continuation
        }
        return stream
    }
}
