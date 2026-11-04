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
    private let tokenStore: TokenStoreService
    private let messageFiles: [URL]
    private let resets: ChatResets
    private let log: YaloLog
    private let lock: NSLock = NSLock()
    private var commands: [String: CommandHandler] = [:]

    public convenience init(config: YaloChatClientConfig) {
        self.init(
            config: config,
            chatMessages: ChatMessageDatabaseService(fileURL: ChatDependencies.databaseURL, logLevel: config.logLevel),
            tokenStore: TokenKeychainService(),
            messageFiles: ChatDependencies.messageFiles(in: ChatDependencies.storageDirectory),
            resets: .shared
        )
    }

    init(
        config: YaloChatClientConfig,
        chatMessages: ChatMessageService,
        tokenStore: TokenStoreService = TokenKeychainService(),
        messageFiles: [URL] = [],
        resets: ChatResets = ChatResets()
    ) {
        self.config = config
        self.chatMessages = chatMessages
        self.tokenStore = tokenStore
        self.messageFiles = messageFiles
        self.resets = resets
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

    /// Deletes every message stored on the device, of every conversation,
    /// whether a chat is showing it or not. Every chat on screen empties and
    /// the channel greets the person again, as in a new conversation.
    public func clearMessages() async {
        await deleteMessages()
        resets.send(.messages)
    }

    /// Deletes every message and every token stored on the device, for
    /// example when the person logs out. Every chat on screen empties and
    /// connects again as a new person, who the channel greets.
    public func logout() async {
        await deleteMessages()
        do {
            try tokenStore.deleteAll()
        } catch {
            log.error("could not forget the tokens", error: error)
        }
        resets.send(.logout)
    }

    /// Yields every time the host asks to clear the messages or to log out.
    func clearRequests() -> AsyncStream<ChatReset> {
        resets.listen()
    }

    private func deleteMessages() async {
        do {
            try await chatMessages.deleteAll()
        } catch {
            log.error("could not clear the messages", error: error)
        }
        for directory in messageFiles {
            try? FileManager.default.removeItem(at: directory)
        }
    }
}

/// What the host asked every open chat to forget.
enum ChatReset: Sendable {
    case messages
    case logout
}

/// Tells every open chat in the app what the host asked to forget, whichever
/// client asked, since what is forgotten is shared by all of them.
final class ChatResets: @unchecked Sendable {
    static let shared: ChatResets = ChatResets()

    private let lock: NSLock = NSLock()
    private var listeners: [UUID: AsyncStream<ChatReset>.Continuation] = [:]

    func listen() -> AsyncStream<ChatReset> {
        let id: UUID = UUID()
        let (stream, continuation): (AsyncStream<ChatReset>, AsyncStream<ChatReset>.Continuation) = AsyncStream.makeStream()
        continuation.onTermination = { [weak self] _ in
            self?.lock.withLock {
                self?.listeners[id] = nil
            }
        }
        lock.withLock {
            listeners[id] = continuation
        }
        return stream
    }

    func send(_ reset: ChatReset) {
        let listeners: [AsyncStream<ChatReset>.Continuation] = lock.withLock {
            Array(self.listeners.values)
        }
        for listener in listeners {
            listener.yield(reset)
        }
    }
}
