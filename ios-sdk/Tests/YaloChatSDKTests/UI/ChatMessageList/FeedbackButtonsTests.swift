// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import Testing
@testable import YaloChatSDK

@MainActor
struct FeedbackButtonsTests {
    @Test(arguments: [nil, ChatMessage.Feedback.thumbsUp, .thumbsDown])
    func feedbackButtonsRenderWhateverWasPicked(feedback: ChatMessage.Feedback?) {
        #expect(renders(FeedbackButtons(feedback: feedback)))
    }
}
