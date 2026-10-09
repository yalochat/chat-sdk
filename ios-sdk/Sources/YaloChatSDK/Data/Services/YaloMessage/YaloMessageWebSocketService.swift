// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import SwiftProtobuf
import YaloChatProto

/// The part of a websocket the service uses, so tests can stay off the network.
protocol WebSocket: AnyObject, Sendable {
    func write(_ frame: String) async throws
    /// The next text frame. Throws once the socket is closed.
    func read() async throws -> String
    func close()
}

extension URLSessionWebSocketTask: WebSocket {
    func write(_ frame: String) async throws {
        try await send(.string(frame))
    }

    func read() async throws -> String {
        switch try await receive() {
        case .string(let text):
            return text
        case .data(let data):
            return String(decoding: data, as: UTF8.self)
        @unknown default:
            return ""
        }
    }

    func close() {
        cancel(with: .normalClosure, reason: nil)
    }
}

/// Holds a link to the channel over a websocket, one socket at a time.
///
/// Nothing may be sent until the backend acknowledges the connection. What is
/// sent before then is held, and goes out in order once it does.
actor YaloMessageWebSocketService: YaloMessageService {
    private static let maxPending: Int = 128
    private static let incomingBuffer: Int = 64

    private let socketURL: URL
    private let ackTimeout: TimeInterval
    private let sockets: @Sendable (URL) -> WebSocket
    private let log: YaloLog
    private var live: WebSocket?
    private var pending: [String] = []
    private var listeners: [UUID: AsyncStream<PollMessageItem>.Continuation] = [:]

    init(
        baseURL: URL,
        session: URLSession = .shared,
        ackTimeout: TimeInterval = 10,
        sockets: (@Sendable (URL) -> WebSocket)? = nil,
        logLevel: LogLevel = .warn
    ) {
        var components: URLComponents = URLComponents(
            url: baseURL.appendingPathComponent("websocket/v1/connect/inapp"),
            resolvingAgainstBaseURL: false
        )!
        components.scheme = components.scheme == "http" ? "ws" : "wss"
        self.socketURL = components.url!
        self.ackTimeout = ackTimeout
        self.log = YaloLog("MessageSocket", level: logLevel)
        self.sockets = sockets ?? { url in
            let task: URLSessionWebSocketTask = session.webSocketTask(with: url)
            task.resume()
            return task
        }
    }

    func messages() -> AsyncStream<PollMessageItem> {
        let (stream, continuation): (AsyncStream<PollMessageItem>, AsyncStream<PollMessageItem>.Continuation) =
            AsyncStream.makeStream(bufferingPolicy: .bufferingNewest(Self.incomingBuffer))
        let id: UUID = UUID()
        listeners[id] = continuation
        continuation.onTermination = { _ in
            Task {
                await self.removeListener(id)
            }
        }
        return stream
    }

    func run(token: String) async -> Bool {
        log.info("opening the socket to \(socketURL.host ?? "")")
        // The backend reads the token from the query, not a header.
        var components: URLComponents = URLComponents(url: socketURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "token", value: token)]
        let socket: WebSocket = sockets(components.url!)
        return await withTaskCancellationHandler {
            await session(on: socket)
        } onCancel: {
            socket.close()
        }
    }

    func send(_ message: SdkMessage) async throws {
        let frame: String = try message.jsonString()
        guard let live else {
            pending.append(frame)
            if pending.count > Self.maxPending {
                pending.removeFirst()
            }
            return
        }
        do {
            try await live.write(frame)
        } catch {
            log.warn("the socket would not take a message", error: error)
            throw error
        }
        log.debug("sent \(frame)")
    }

    func close() {
        log.info("forgetting what was waiting to be sent")
        pending.removeAll()
    }

    private func session(on socket: WebSocket) async -> Bool {
        defer {
            if live === socket {
                live = nil
            }
            log.debug("closing the socket")
            socket.close()
        }
        guard await acknowledged(socket) else {
            log.warn("the server never acknowledged the connection")
            return false
        }
        log.info("the socket is open")
        if !pending.isEmpty {
            log.info("sending \(pending.count) held back while the line was down")
        }
        // Emptied before going live, so a send made meanwhile cannot jump the queue.
        while !pending.isEmpty {
            let frame: String = pending.removeFirst()
            if (try? await socket.write(frame)) != nil {
                log.debug("sent \(frame)")
            }
        }
        live = socket
        while let frame = try? await socket.read() {
            log.debug("received \(frame)")
            guard let item = Self.message(from: frame) else {
                continue
            }
            for listener in listeners.values {
                listener.yield(item)
            }
        }
        return true
    }

    // A backend that never acknowledges is a line that looks up but is not.
    private func acknowledged(_ socket: WebSocket) async -> Bool {
        let timeout: TimeInterval = ackTimeout
        return await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                while let frame = try? await socket.read() {
                    if Self.isConnectionAck(frame) {
                        return true
                    }
                }
                return false
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                return false
            }
            let first: Bool = await group.next() ?? false
            if !first {
                // Unblocks the reader, which would otherwise wait for a frame forever.
                socket.close()
            }
            group.cancelAll()
            return first
        }
    }

    private func removeListener(_ id: UUID) {
        listeners[id] = nil
    }

    // Unknown fields are ignored so a newer backend cannot break an older app.
    private static var decodingOptions: JSONDecodingOptions {
        var options: JSONDecodingOptions = JSONDecodingOptions()
        options.ignoreUnknownFields = true
        return options
    }

    private static func isConnectionAck(_ frame: String) -> Bool {
        let ack: Yalo_ExternalChannel_InApp_Sdk_V2_ConnectionAck? = try? .init(
            jsonString: frame,
            options: decodingOptions
        )
        return ack?.type == .connectionAck
    }

    // Acknowledgements carry a `type` and messages do not.
    private static func message(from frame: String) -> PollMessageItem? {
        guard
            let fields = try? JSONSerialization.jsonObject(with: Data(frame.utf8)) as? [String: Any],
            fields["type"] == nil
        else {
            return nil
        }
        return try? PollMessageItem(jsonString: frame, options: decodingOptions)
    }
}
