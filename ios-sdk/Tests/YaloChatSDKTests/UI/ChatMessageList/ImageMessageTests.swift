// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import Testing
@testable import YaloChatSDK

@MainActor
struct ImageMessageTests {
    private static let picture: UIImage = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 30)).image { context in
        context.fill(CGRect(x: 0, y: 0, width: 40, height: 30))
    }

    /// Draws `message` and waits for its picture to arrive, so what is drawn
    /// last is the picture or what stands in for a missing one.
    private func rendersOnceLoaded(_ message: ChatMessage, answer: UIImage?) async -> Bool {
        let asked: Recorded<Int64?> = Recorded()
        let controller: UIHostingController = UIHostingController(rootView: ImageMessage(message: message) { asking in
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

    @Test(arguments: [ChatMessage.Role.user, .agent])
    func showsThePictureWithItsCaption(role: ChatMessage.Role) async {
        let message: ChatMessage = ChatMessage(role: role, type: .image, timestamp: Date(), id: 1, content: "Look", image: ImageAttachment())

        #expect(await rendersOnceLoaded(message, answer: Self.picture))
    }

    @Test func aCachedPictureIsDrawnWithoutLoading() async {
        let message: ChatMessage = ChatMessage(role: .user, type: .image, timestamp: Date(), id: 3, image: ImageAttachment())
        let asked: Recorded<Int64?> = Recorded()

        #expect(renders(ImageMessage(message: message, cached: Self.picture) { asking in
            asked.append(asking.id)
            return nil
        }))
        #expect(!(await eventually(timeout: 0.2) { !asked.values.isEmpty }))
    }

    @Test func showsAStandInForAPictureThatIsNowhere() async {
        let message: ChatMessage = ChatMessage(role: .agent, type: .image, timestamp: Date(), id: 2, image: ImageAttachment())

        #expect(await rendersOnceLoaded(message, answer: nil))
    }
}
