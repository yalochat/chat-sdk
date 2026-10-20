// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import SwiftProtobuf
import YaloChatProto

/// Keeps a line to the channel open and translates between `ChatMessage` and
/// the wire format.
///
/// When a connection dies another one is opened with a fresh token, waiting a
/// little longer after each attempt the backend did not accept.
@MainActor
final class YaloMessageRepositoryRemote: YaloMessageRepository {
    private enum Lifecycle {
        case closed
        case running
        case paused
    }

    private static let maxBackoff: TimeInterval = 30
    private static let maxAttempt: Int = 5

    private let service: YaloMessageService
    private let tokens: TokenRepository
    private let now: @Sendable () -> Date
    private let sleep: @Sendable (TimeInterval) async throws -> Void
    private let log: YaloLog
    private var lifecycle: Lifecycle = .closed
    private var connecting: Task<Void, Never>?

    init(
        service: YaloMessageService,
        tokens: TokenRepository,
        now: @escaping @Sendable () -> Date = { Date() },
        sleep: @escaping @Sendable (TimeInterval) async throws -> Void = { seconds in
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        },
        logLevel: LogLevel = .warn
    ) {
        self.service = service
        self.tokens = tokens
        self.now = now
        self.sleep = sleep
        self.log = YaloLog("Messages", level: logLevel)
    }

    func connect() {
        guard lifecycle == .closed else {
            return
        }
        log.info("connecting")
        lifecycle = .running
        startConnecting()
    }

    func pause() {
        guard lifecycle == .running else {
            return
        }
        log.info("pausing, the app went away")
        lifecycle = .paused
        connecting?.cancel()
        connecting = nil
    }

    func resume() {
        guard lifecycle == .paused else {
            return
        }
        log.info("resuming")
        lifecycle = .running
        startConnecting()
    }

    func close() {
        log.info("closing")
        lifecycle = .closed
        connecting?.cancel()
        connecting = nil
        Task { [service] in
            await service.close()
        }
    }

    func restart() async {
        log.info("starting the line over")
        connecting?.cancel()
        connecting = nil
        await service.close()
        guard lifecycle == .running, connecting == nil else {
            return
        }
        startConnecting()
    }

    func messages() -> AsyncStream<ChatMessage> {
        let service: YaloMessageService = service
        let now: @Sendable () -> Date = now
        return AsyncStream { continuation in
            let listening: Task<Void, Never> = Task {
                for await item in await service.messages() {
                    if let message = Self.chatMessage(from: item, now: now()) {
                        continuation.yield(message)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                listening.cancel()
            }
        }
    }

    func commandRequests() -> AsyncStream<CommandRequest> {
        let service: YaloMessageService = service
        return AsyncStream { continuation in
            let listening: Task<Void, Never> = Task {
                for await item in await service.messages() {
                    if let request = Self.commandRequest(from: item.message) {
                        continuation.yield(request)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                listening.cancel()
            }
        }
    }

    func answerCommand(_ request: CommandRequest, result: Result<String, Error>) async throws {
        guard lifecycle != .closed else {
            throw YaloMessageRepositoryError.closed
        }
        let answeredAt: Google_Protobuf_Timestamp = Google_Protobuf_Timestamp(date: now())
        var envelope: SdkMessage = SdkMessage()
        envelope.correlationID = request.correlationId
        envelope.timestamp = answeredAt
        switch request.kind {
        case .custom:
            var response: Yalo_ExternalChannel_InApp_Sdk_V2_CustomCommandResponse = .init()
            response.timestamp = answeredAt
            response.status = Self.status(of: result)
            response.payload = (try? result.get()) ?? ""
            envelope.payload = .customCommandResponse(response)
        case .getCart:
            var response: Yalo_ExternalChannel_InApp_Sdk_V2_GetCartResponse = cartPage(of: result)
            response.timestamp = answeredAt
            envelope.payload = .getCartResponse(response)
        case .updateCartProduct:
            var response: Yalo_ExternalChannel_InApp_Sdk_V2_UpdateCartProductResponse = .init()
            response.timestamp = answeredAt
            response.status = Self.status(of: result)
            envelope.payload = .updateCartProductResponse(response)
        }
        try await service.send(envelope)
    }

    /// The page the host returned as JSON, or a failed answer when it could not be read.
    private func cartPage(of result: Result<String, Error>) -> Yalo_ExternalChannel_InApp_Sdk_V2_GetCartResponse {
        guard case .success(let json) = result else {
            return Yalo_ExternalChannel_InApp_Sdk_V2_GetCartResponse.with { $0.status = .error }
        }
        var options: JSONDecodingOptions = JSONDecodingOptions()
        options.ignoreUnknownFields = true
        do {
            var page: Yalo_ExternalChannel_InApp_Sdk_V2_GetCartResponse = try .init(jsonString: json, options: options)
            page.status = .success
            return page
        } catch {
            log.warn("the cart the host returned is not valid JSON", error: error)
            return Yalo_ExternalChannel_InApp_Sdk_V2_GetCartResponse.with { $0.status = .error }
        }
    }

    private static func status(of result: Result<String, Error>) -> Yalo_ExternalChannel_InApp_Sdk_V2_ResponseStatus {
        switch result {
        case .success:
            return .success
        case .failure:
            return .error
        }
    }

    /// A request the host app has to answer, or nil when `message` is not one.
    /// Cart requests reach the host as JSON, without the channel's timestamp.
    private static func commandRequest(from message: SdkMessage) -> CommandRequest? {
        switch message.payload {
        case .customCommandRequest(let request):
            return CommandRequest(correlationId: message.correlationID, commandId: request.commandID, payload: request.payload)
        case .getCartRequest(let request):
            var fields: [String: Any] = [:]
            if request.hasCursor {
                fields["cursor"] = request.cursor
            }
            if request.hasPageSize {
                fields["pageSize"] = request.pageSize
            }
            return CommandRequest(
                correlationId: message.correlationID,
                commandId: "getCart",
                payload: json(of: fields),
                kind: .getCart
            )
        case .updateCartProductRequest(let request):
            var fields: [String: Any] = ["sku": request.sku, "units": request.units]
            if request.hasSubunits {
                fields["subunits"] = request.subunits
            }
            return CommandRequest(
                correlationId: message.correlationID,
                commandId: "updateCartProduct",
                payload: json(of: fields),
                kind: .updateCartProduct
            )
        default:
            return nil
        }
    }

    private static func json(of fields: [String: Any]) -> String {
        let data: Data = (try? JSONSerialization.data(withJSONObject: fields, options: [.sortedKeys])) ?? Data("{}".utf8)
        return String(decoding: data, as: UTF8.self)
    }

    func send(_ message: ChatMessage) async throws {
        guard lifecycle != .closed else {
            log.warn("a message was written while the chat was closed")
            throw YaloMessageRepositoryError.closed
        }
        try await service.send(try Self.sdkMessage(from: message, sentAt: now()))
    }

    func requestGuidanceCard(openContext: [String: String]) async throws {
        guard lifecycle != .closed else {
            throw YaloMessageRepositoryError.closed
        }
        let askedAt: Date = now()
        var request: Yalo_ExternalChannel_InApp_Sdk_V2_GuidanceCardRequest = .init()
        request.timestamp = Google_Protobuf_Timestamp(date: askedAt)
        // Nothing to go on is said by leaving the field out, not by an empty object.
        if !openContext.isEmpty {
            let json: Data = try JSONSerialization.data(withJSONObject: openContext, options: [.sortedKeys])
            request.context = String(decoding: json, as: UTF8.self)
        }
        var envelope: SdkMessage = SdkMessage()
        envelope.correlationID = UUID().uuidString
        envelope.timestamp = Google_Protobuf_Timestamp(date: askedAt)
        envelope.payload = .guidanceCardRequest(request)
        log.info("asking the channel to open the conversation")
        try await service.send(envelope)
    }

    func sendFeedback(_ feedback: ChatMessage.Feedback?, wiId: String) async throws {
        guard lifecycle != .closed else {
            throw YaloMessageRepositoryError.closed
        }
        let ratedAt: Google_Protobuf_Timestamp = Google_Protobuf_Timestamp(date: now())
        var request: Yalo_ExternalChannel_InApp_Sdk_V2_MessageFeedbackRequest = .init()
        request.messageID = wiId
        request.rating = switch feedback {
        case .thumbsUp: .thumbsUp
        case .thumbsDown: .thumbsDown
        case nil: .unspecified
        }
        request.timestamp = ratedAt
        var envelope: SdkMessage = SdkMessage()
        envelope.correlationID = UUID().uuidString
        envelope.timestamp = ratedAt
        envelope.payload = .messageFeedbackRequest(request)
        try await service.send(envelope)
    }

    private func startConnecting() {
        let service: YaloMessageService = service
        let tokens: TokenRepository = tokens
        let sleep: @Sendable (TimeInterval) async throws -> Void = sleep
        let log: YaloLog = log
        connecting = Task {
            await Self.connectUntilStopped(service: service, tokens: tokens, sleep: sleep, log: log)
        }
    }

    // A token is fetched for every attempt, since the last one may have run out while it was up.
    private static func connectUntilStopped(
        service: YaloMessageService,
        tokens: TokenRepository,
        sleep: @Sendable (TimeInterval) async throws -> Void,
        log: YaloLog
    ) async {
        var attempt: Int = 0
        while !Task.isCancelled {
            do {
                let token: String = try await tokens.token()
                if !Task.isCancelled, await service.run(token: token) {
                    // The line worked, so the waits start over.
                    attempt = 0
                }
            } catch where !Task.isCancelled {
                log.warn("no token, so no socket", error: error)
            } catch {
                return
            }
            let delay: TimeInterval = min(maxBackoff, pow(2, Double(attempt)))
            log.info("reconnecting in \(Int(delay))s")
            do {
                try await sleep(delay)
            } catch {
                return
            }
            attempt = min(attempt + 1, maxAttempt)
        }
    }

    /// A voice message with no recording, or an image message with no picture,
    /// has nothing for the channel to show, so it is refused rather than sent empty.
    private static func sdkMessage(from message: ChatMessage, sentAt: Date) throws -> SdkMessage {
        var envelope: SdkMessage = SdkMessage()
        // The row id, so an acknowledgement names the row it belongs to.
        envelope.correlationID = message.id.map(String.init) ?? UUID().uuidString
        envelope.timestamp = Google_Protobuf_Timestamp(date: sentAt)
        switch message.type {
        case .text:
            var content: Yalo_ExternalChannel_InApp_Sdk_V2_TextMessage = .init()
            content.text = message.content
            // When it was written, which is not when it goes out.
            content.timestamp = Google_Protobuf_Timestamp(date: message.timestamp)
            content.role = .user
            content.status = .inProgress
            var request: Yalo_ExternalChannel_InApp_Sdk_V2_TextMessageRequest = .init()
            request.timestamp = Google_Protobuf_Timestamp(date: sentAt)
            request.content = content
            envelope.payload = .textMessageRequest(request)
        case .voice:
            guard let note = message.voice else {
                throw YaloMessageRepositoryError.unsupported(message.type)
            }
            var content: Yalo_ExternalChannel_InApp_Sdk_V2_VoiceMessage = .init()
            // The id the upload answered with, which is what the channel expects.
            content.mediaURL = note.mediaURL
            content.mediaType = note.mimeType
            content.fileName = note.fileName
            content.byteCount = note.byteCount
            content.duration = note.duration
            content.amplitudesPreview = note.amplitudes
            content.timestamp = Google_Protobuf_Timestamp(date: message.timestamp)
            content.role = .user
            content.status = .inProgress
            var request: Yalo_ExternalChannel_InApp_Sdk_V2_VoiceNoteMessageRequest = .init()
            request.timestamp = Google_Protobuf_Timestamp(date: sentAt)
            request.content = content
            envelope.payload = .voiceNoteMessageRequest(request)
        case .image:
            guard let picture = message.image else {
                throw YaloMessageRepositoryError.unsupported(message.type)
            }
            var content: Yalo_ExternalChannel_InApp_Sdk_V2_ImageMessage = .init()
            // The caption is the message's own body.
            content.text = message.content
            content.mediaURL = picture.mediaURL
            content.mediaType = picture.mimeType
            content.fileName = picture.fileName
            content.byteCount = picture.byteCount
            content.timestamp = Google_Protobuf_Timestamp(date: message.timestamp)
            content.role = .user
            content.status = .inProgress
            var request: Yalo_ExternalChannel_InApp_Sdk_V2_ImageMessageRequest = .init()
            request.timestamp = Google_Protobuf_Timestamp(date: sentAt)
            request.content = content
            envelope.payload = .imageMessageRequest(request)
        default:
            throw YaloMessageRepositoryError.unsupported(message.type)
        }
        return envelope
    }

    /// Text, voice and images so far. Anything else is left out rather than shown empty.
    private static func chatMessage(from item: PollMessageItem, now: Date) -> ChatMessage? {
        let timestamp: Date = item.hasDate ? item.date.date : now
        let status: ChatMessage.Status = ChatMessage.Status(rawValue: item.status) ?? .delivered
        switch item.message.payload {
        case .textMessageRequest(let request):
            return ChatMessage(
                role: .agent,
                type: .text,
                timestamp: timestamp,
                wiId: item.id,
                content: request.content.text,
                status: status,
                header: request.hasHeader ? request.header : nil,
                footer: request.hasFooter ? request.footer : nil,
                buttons: request.buttons.map(Self.button)
            )
        case .voiceNoteMessageRequest(let request):
            // An address to download from, not a file that is already here.
            return ChatMessage(
                role: .agent,
                type: .voice,
                timestamp: timestamp,
                wiId: item.id,
                status: status,
                header: request.hasHeader ? request.header : nil,
                footer: request.hasFooter ? request.footer : nil,
                buttons: request.buttons.map(Self.button),
                voice: VoiceNote(
                    duration: request.content.duration,
                    amplitudes: request.content.amplitudesPreview,
                    mediaURL: request.content.mediaURL,
                    mimeType: request.content.mediaType,
                    fileName: request.content.fileName,
                    byteCount: request.content.byteCount
                )
            )
        case .imageMessageRequest(let request):
            // An address to download from, and the caption as the body.
            return ChatMessage(
                role: .agent,
                type: .image,
                timestamp: timestamp,
                wiId: item.id,
                content: request.content.text,
                status: status,
                header: request.hasHeader ? request.header : nil,
                footer: request.hasFooter ? request.footer : nil,
                buttons: request.buttons.map(Self.button),
                image: ImageAttachment(
                    mediaURL: request.content.mediaURL,
                    mimeType: request.content.mediaType,
                    fileName: request.content.fileName,
                    byteCount: request.content.byteCount
                )
            )
        default:
            return nil
        }
    }

    /// A kind this SDK does not know reads back as a reply, the one thing
    /// every button can do and the one that stays inside the conversation.
    private static func button(_ wire: Yalo_ExternalChannel_InApp_Sdk_V2_Button) -> MessageButton {
        let kind: MessageButton.Kind = switch wire.buttonType {
        case .postback: .postback
        case .link: .link
        default: .reply
        }
        return MessageButton(text: wire.text, kind: kind, url: wire.hasURL ? wire.url : nil)
    }
}
