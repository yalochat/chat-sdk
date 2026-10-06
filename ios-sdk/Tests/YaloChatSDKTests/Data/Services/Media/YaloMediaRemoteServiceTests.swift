// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

struct YaloMediaRemoteServiceTests {
    private let cacheDirectory: URL = FileManager.default.temporaryDirectory
        .appendingPathComponent("yalo-chat-media-tests-\(UUID().uuidString)", isDirectory: true)

    private func service(_ server: StubServer) -> YaloMediaRemoteService {
        YaloMediaRemoteService(baseURL: server.baseURL, cacheDirectory: cacheDirectory, session: server.session)
    }

    private func content(_ bytes: String = "picture bytes", name: String = "photo.jpg") throws -> MediaContent {
        let file: URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data(bytes.utf8).write(to: file)
        return MediaContent(fileURL: file, fileName: name, mimeType: "image/jpeg")
    }

    private static let created: Data = Data("""
    {"id": "media-1", "signed_url": "https://files.test/a.jpg?sig=1", "original_name": "photo.jpg", "type": "image"}
    """.utf8)

    @Test func uploadReturnsTheStoredMedia() async throws {
        let server: StubServer = StubServer(status: 201, body: Self.created)

        let media: Media = try await service(server).upload(try content(), token: "token-1")

        #expect(media == Media(
            id: "media-1",
            signedURL: "https://files.test/a.jpg?sig=1",
            originalName: "photo.jpg",
            type: .image
        ))
    }

    @Test func uploadSendsTheFileAsMultipartUnderTheToken() async throws {
        let server: StubServer = StubServer(status: 201, body: Self.created)

        _ = try await service(server).upload(try content("picture bytes", name: "my \"photo\".jpg"), token: "token-1")

        let sent: RecordedRequest = try #require(server.requests.first)
        let body: String = String(decoding: sent.body, as: UTF8.self)
        #expect(sent.request.httpMethod == "POST")
        #expect(sent.request.url?.path == "/v1/channels/all/media")
        #expect(sent.request.value(forHTTPHeaderField: "Authorization") == "Bearer token-1")
        #expect(sent.request.value(forHTTPHeaderField: "Content-Length") == String(sent.body.count))
        #expect(body.contains("name=\"file\"; filename=\"my %22photo%22.jpg\""))
        #expect(body.contains("Content-Type: image/jpeg\r\n\r\npicture bytes\r\n"))
    }

    @Test func uploadReadsCamelCaseFields() async throws {
        let server: StubServer = StubServer(status: 201, body: Data("""
        {"id": "media-2", "signedUrl": "https://files.test/b.ogg", "originalName": "note.ogg", "type": "voice"}
        """.utf8))

        let media: Media = try await service(server).upload(try content(), token: "token-1")

        #expect(media == Media(id: "media-2", signedURL: "https://files.test/b.ogg", originalName: "note.ogg", type: .voice))
    }

    @Test func uploadCanBeSentAgainWithTheSameContent() async throws {
        let server: StubServer = StubServer(status: 401)
        let media: MediaContent = try content()
        let service: YaloMediaRemoteService = service(server)

        await #expect(throws: MediaServiceError.staleToken) {
            try await service.upload(media, token: "old")
        }
        server.respond(status: 201, body: Self.created)
        _ = try await service.upload(media, token: "new")

        let bodies: [String] = server.requests.map { String(decoding: $0.body, as: UTF8.self) }
        #expect(bodies.count == 2)
        #expect(bodies.allSatisfy { $0.contains("picture bytes") })
    }

    @Test func uploadFailsOnAnyOtherStatus() async throws {
        let server: StubServer = StubServer(status: 500)

        await #expect(throws: MediaServiceError.uploadFailed(status: 500)) {
            try await service(server).upload(try content(), token: "token-1")
        }
    }

    @Test func uploadFailsWhenTheAnswerCannotBeRead() async throws {
        let server: StubServer = StubServer(status: 201, body: Data("not json".utf8))

        await #expect(throws: MediaServiceError.unreadableResponse) {
            try await service(server).upload(try content(), token: "token-1")
        }
    }

    @Test func uploadFailsWhenTheFileIsMissing() async throws {
        let server: StubServer = StubServer(status: 201, body: Self.created)
        let missing: MediaContent = MediaContent(
            fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString),
            fileName: "gone.jpg",
            mimeType: "image/jpeg"
        )

        await #expect(throws: (any Error).self) {
            try await service(server).upload(missing, token: "token-1")
        }
        #expect(server.requests.isEmpty)
    }

    @Test func downloadStoresTheFile() async throws {
        let server: StubServer = StubServer(status: 200, body: Data("voice bytes".utf8))

        let file: URL = try await service(server).download(server.baseURL.appendingPathComponent("a.ogg").absoluteString)

        #expect(try Data(contentsOf: file) == Data("voice bytes".utf8))
        #expect(server.requests.first?.request.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test func downloadServesARepeatFromTheCacheWhateverTheSignature() async throws {
        let server: StubServer = StubServer(status: 200, body: Data("voice bytes".utf8))
        let service: YaloMediaRemoteService = service(server)
        let address: String = server.baseURL.appendingPathComponent("a.ogg").absoluteString

        let first: URL = try await service.download("\(address)?sig=1")
        let second: URL = try await service.download("\(address)?sig=2")

        #expect(first == second)
        #expect(server.requests.count == 1)
    }

    @Test func downloadFailsWithoutCachingOnAnErrorStatus() async throws {
        let server: StubServer = StubServer(status: 404)
        let service: YaloMediaRemoteService = service(server)
        let address: String = server.baseURL.appendingPathComponent("a.ogg").absoluteString

        await #expect(throws: MediaServiceError.downloadFailed(status: 404)) {
            try await service.download(address)
        }
        server.respond(status: 200, body: Data("voice bytes".utf8))
        _ = try await service.download(address)
        #expect(server.requests.count == 2)
    }

    @Test(arguments: ["not an address", "file:///tmp/a.ogg", "https:///a.ogg"])
    func downloadRefusesWhatIsNotAWebAddress(_ address: String) async throws {
        let server: StubServer = StubServer()

        await #expect(throws: MediaServiceError.invalidAddress(address)) {
            try await service(server).download(address)
        }
    }

    @Test func messageTypeReadsUnknownValuesAsUnknown() {
        #expect(MessageType.of("chat-status") == .chatStatus)
        #expect(MessageType.of("hologram") == .unknown)
    }
}
