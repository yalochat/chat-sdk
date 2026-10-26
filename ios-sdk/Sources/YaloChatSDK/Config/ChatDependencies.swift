// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// Everything one conversation needs, built the first time it is asked for.
@MainActor
final class ChatDependencies {
    // Not the cache: the system may empty it while a sent picture or a
    // recorded note still needs its only copy.
    nonisolated static let storageDirectory: URL = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("yalo-chat", isDirectory: true)

    nonisolated static let databaseURL: URL? = storageDirectory.appendingPathComponent("yalo_chat.sqlite")

    private nonisolated static let images: String = "images"
    private nonisolated static let voice: String = "voice"
    private nonisolated static let ephemeral: String = "ephemeral"

    /// Where the pictures and voice notes of every conversation are kept.
    nonisolated static func messageFiles(in storageDirectory: URL) -> [URL] {
        [images, voice, ephemeral].map { name in
            storageDirectory.appendingPathComponent(name, isDirectory: true)
        }
    }

    private let config: YaloChatClientConfig
    let chatSession: ChatSession
    private let baseURL: URL
    private let cacheDirectory: URL
    private let databaseURL: URL?
    private let storageDirectory: URL
    private let urlSession: URLSession
    private let tokenStore: TokenStoreService

    init(
        config: YaloChatClientConfig,
        baseURL: URL = YaloAPI.baseURL,
        cacheDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0],
        databaseURL: URL? = ChatDependencies.databaseURL,
        storageDirectory: URL = ChatDependencies.storageDirectory,
        session: URLSession = .shared,
        tokenStore: TokenStoreService = TokenKeychainService()
    ) {
        self.config = config
        self.chatSession = ChatSession(config: config)
        self.baseURL = baseURL
        self.cacheDirectory = cacheDirectory
        self.databaseURL = databaseURL
        self.storageDirectory = storageDirectory
        self.urlSession = session
        self.tokenStore = tokenStore
    }

    private var ephemeralDirectory: URL {
        storageDirectory.appendingPathComponent(Self.ephemeral, isDirectory: true)
    }

    /// An ephemeral conversation keeps its files apart, so it can be deleted whole.
    private var sessionDirectory: URL {
        guard config.sessionMode == .ephemeral else {
            return storageDirectory
        }
        return ephemeralDirectory.appendingPathComponent(chatSession.id, isDirectory: true)
    }

    lazy var mediaService: YaloMediaService = YaloMediaRemoteService(
        baseURL: baseURL,
        cacheDirectory: cacheDirectory.appendingPathComponent("yalo-chat-media", isDirectory: true),
        session: urlSession,
        logLevel: config.logLevel
    )

    lazy var auth: YaloMessageAuthService = YaloMessageAuthRemoteService(
        channelId: config.channelId,
        organizationId: config.organizationId,
        authUserId: chatSession.authUserId,
        userAuthTokenProvider: config.userAuthTokenProvider,
        baseURL: baseURL,
        session: urlSession,
        logLevel: config.logLevel
    )

    lazy var chatMessages: ChatMessageService = ChatMessageDatabaseService(fileURL: databaseURL, logLevel: config.logLevel)

    lazy var images: ImageService = ImageDeviceService(
        directory: sessionDirectory.appendingPathComponent(Self.images, isDirectory: true),
        logLevel: config.logLevel
    )

    lazy var voiceRecorder: VoiceRecorderService = VoiceRecorderDeviceService(logLevel: config.logLevel)

    lazy var voicePlayer: VoicePlayerService = VoicePlayerDeviceService(logLevel: config.logLevel)

    lazy var tokens: TokenRepository = TokenRepository(
        auth: auth,
        store: tokenStore,
        sessionId: chatSession.id,
        ephemeral: config.sessionMode == .ephemeral,
        logLevel: config.logLevel
    )

    lazy var media: MediaRepository = MediaRepository(service: mediaService, tokens: tokens)

    lazy var voice: VoiceRepository = VoiceRepositoryLocal(
        recorder: voiceRecorder,
        player: voicePlayer,
        directory: sessionDirectory.appendingPathComponent(Self.voice, isDirectory: true),
        logLevel: config.logLevel
    )

    lazy var yaloMessageService: YaloMessageService = YaloMessageWebSocketService(
        baseURL: baseURL,
        session: urlSession,
        logLevel: config.logLevel
    )

    lazy var yaloMessages: YaloMessageRepository = YaloMessageRepositoryRemote(
        service: yaloMessageService,
        tokens: tokens,
        logLevel: config.logLevel
    )

    func chatViewModel(
        commandHandlers: @escaping (String) -> CommandHandler? = { _ in nil },
        clearRequests: @escaping () -> AsyncStream<ChatReset> = { AsyncStream { continuation in continuation.finish() } }
    ) -> ChatViewModel {
        ChatViewModel(
            chatMessages: chatMessages,
            yaloMessages: yaloMessages,
            voice: voice,
            media: media,
            images: images,
            tokens: tokens,
            sessionId: chatSession.id,
            ephemeral: config.sessionMode == .ephemeral,
            ephemeralDirectory: ephemeralDirectory,
            run: ChatViewModel.run,
            openContext: config.openContext,
            welcomeMessageType: config.welcomeMessageType,
            commandHandlers: commandHandlers,
            clearRequests: clearRequests,
            logLevel: config.logLevel
        )
    }
}
