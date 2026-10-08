// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

struct MediaRepositoryTests {
    private let service: FakeYaloMediaService = FakeYaloMediaService()
    private let content: MediaContent = MediaContent(
        fileURL: URL(fileURLWithPath: "/tmp/voice.m4a"),
        fileName: "voice.m4a",
        mimeType: "audio/mp4"
    )

    private func repository() -> MediaRepository {
        MediaRepository(service: service, tokens: TokenRepository(auth: CountingAuthService()))
    }

    @Test func uploadsWithTheToken() async throws {
        let media: Media = try await repository().upload(content)

        #expect(media.id == "media-1")
        #expect(await service.uploads == [content])
        #expect(await service.uploadTokens == ["access-1"])
    }

    @Test func aRefusedTokenIsReplacedOnce() async throws {
        await service.failUploads(with: [MediaServiceError.staleToken])

        let media: Media = try await repository().upload(content)

        #expect(media.id == "media-2")
        #expect(await service.uploadTokens == ["access-1", "access-2"])
    }

    @Test func aSecondRefusalIsReported() async {
        await service.failUploads(with: [MediaServiceError.staleToken, MediaServiceError.staleToken])

        await #expect(throws: MediaServiceError.staleToken) {
            try await repository().upload(content)
        }
    }

    @Test func otherFailuresAreNotRetried() async {
        await service.failUploads(with: [MediaServiceError.uploadFailed(status: 500)])

        await #expect(throws: MediaServiceError.uploadFailed(status: 500)) {
            try await repository().upload(content)
        }
        #expect(await service.uploads.count == 1)
    }

    @Test func downloadsThroughTheService() async throws {
        let file: URL = URL(fileURLWithPath: "/tmp/cached.m4a")
        await service.serveDownloads(from: file)

        #expect(try await repository().download("https://cdn/a.m4a") == file)
        #expect(await service.downloads == ["https://cdn/a.m4a"])
    }
}
