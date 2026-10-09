// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// Everything one conversation needs, built the first time it is asked for.
@MainActor
final class ChatDependencies {
    private let config: YaloChatClientConfig
    private let baseURL: URL
    private let cacheDirectory: URL
    private let databaseURL: URL?
    private let imagesDirectory: URL
    private let voiceDirectory: URL
    private let session: URLSession

    init(
        config: YaloChatClientConfig,
        baseURL: URL = YaloAPI.baseURL,
        cacheDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0],
        databaseURL: URL? = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("yalo-chat/yalo_chat.sqlite"),
        // Not the cache: the system may empty it while a sent picture still needs its copy.
        imagesDirectory: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("yalo-chat/images", isDirectory: true),
        // Not the cache either: a recorded note is the only copy that can be played back.
        voiceDirectory: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("yalo-chat/voice", isDirectory: true),
        session: URLSession = .shared
    ) {
        self.config = config
        self.baseURL = baseURL
        self.cacheDirectory = cacheDirectory
        self.databaseURL = databaseURL
        self.imagesDirectory = imagesDirectory
        self.voiceDirectory = voiceDirectory
        self.session = session
    }

    lazy var mediaService: YaloMediaService = YaloMediaRemoteService(
        baseURL: baseURL,
        cacheDirectory: cacheDirectory.appendingPathComponent("yalo-chat-media", isDirectory: true),
        session: session,
        logLevel: config.logLevel
    )

    lazy var auth: YaloMessageAuthService = YaloMessageAuthRemoteService(
        channelId: config.channelId,
        organizationId: config.organizationId,
        authUserId: config.userId,
        baseURL: baseURL,
        session: session,
        logLevel: config.logLevel
    )

    lazy var chatMessages: ChatMessageService = ChatMessageDatabaseService(fileURL: databaseURL, logLevel: config.logLevel)

    lazy var images: ImageService = ImageDeviceService(directory: imagesDirectory, logLevel: config.logLevel)

    lazy var voiceRecorder: VoiceRecorderService = VoiceRecorderDeviceService(logLevel: config.logLevel)

    lazy var voicePlayer: VoicePlayerService = VoicePlayerDeviceService(logLevel: config.logLevel)

    lazy var tokens: TokenRepository = TokenRepository(auth: auth, logLevel: config.logLevel)

    lazy var media: MediaRepository = MediaRepository(service: mediaService, tokens: tokens)

    lazy var voice: VoiceRepository = VoiceRepositoryLocal(
        recorder: voiceRecorder,
        player: voicePlayer,
        directory: voiceDirectory,
        logLevel: config.logLevel
    )

    lazy var yaloMessageService: YaloMessageService = YaloMessageWebSocketService(
        baseURL: baseURL,
        session: session,
        logLevel: config.logLevel
    )

    lazy var yaloMessages: YaloMessageRepository = YaloMessageRepositoryRemote(
        service: yaloMessageService,
        tokens: tokens,
        logLevel: config.logLevel
    )

    func chatViewModel() -> ChatViewModel {
        ChatViewModel(
            chatMessages: chatMessages,
            yaloMessages: yaloMessages,
            voice: voice,
            media: media,
            images: images,
            sessionId: config.sessionId,
            openContext: config.openContext
        )
    }
}
