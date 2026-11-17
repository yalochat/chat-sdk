// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import Testing
@testable import YaloChatSDK

@MainActor
struct VideoMessageTests {
    private static let preview: VideoPreview = VideoPreview(
        file: URL(fileURLWithPath: "/dev/null"),
        poster: UIGraphicsImageRenderer(size: CGSize(width: 40, height: 30)).image { context in
            context.fill(CGRect(x: 0, y: 0, width: 40, height: 30))
        },
        duration: 42
    )

    private func message(_ id: Int64, content: String = "") -> ChatMessage {
        ChatMessage(role: .agent, type: .video, timestamp: Date(), id: id, content: content, video: VideoAttachment())
    }

    /// Draws `message` and waits for its video to arrive, so what is drawn
    /// last is the poster or what stands in for a video that cannot play.
    private func rendersOnceLoaded(_ message: ChatMessage, answer: VideoPreview?) async -> Bool {
        let asked: Recorded<Int64?> = Recorded()
        let controller: UIHostingController = UIHostingController(rootView: VideoMessage(message: message) { asking in
            asked.append(asking.id)
            return answer
        })
        let window: UIWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        let loaded: Bool = await eventually { asked.values == [message.id] }
        controller.view.layoutIfNeeded()
        return loaded && controller.view.bounds.height > 0
    }

    @Test func showsThePosterWithItsCaption() async {
        #expect(await rendersOnceLoaded(message(1, content: "How to set it up"), answer: Self.preview))
    }

    @Test func showsAStandInForAVideoThatCannotPlay() async {
        #expect(await rendersOnceLoaded(message(2), answer: nil))
    }

    @Test func aCachedVideoIsDrawnWithoutLoading() async {
        let asked: Recorded<Int64?> = Recorded()

        #expect(renders(VideoMessage(message: message(3), cached: Self.preview) { asking in
            asked.append(asking.id)
            return nil
        }))
        #expect(!(await eventually(timeout: 0.2) { !asked.values.isEmpty }))
    }

    @Test func aVideoWithNoKnownLengthIsDrawn() {
        let unknown: VideoPreview = VideoPreview(file: Self.preview.file, poster: Self.preview.poster, duration: 0)

        #expect(renders(VideoMessage(message: message(4), cached: unknown) { _ in nil }))
    }

    @Test(arguments: [
        (0.0, "0:00"),
        (42.4, "0:42"),
        (62.0, "1:02"),
        (3_725.0, "1:02:05"),
    ])
    func writesTheLengthTheWayAPlayerDoes(seconds: TimeInterval, expected: String) {
        #expect(VideoMessage.length(seconds) == expected)
    }

    @Test func thePlayerScreenIsDrawn() async throws {
        let file: URL = try await videoFile()

        #expect(renders(VideoPlayerScreen(file: file)))
    }
}
