// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import Testing
@testable import YaloChatSDK

@MainActor
struct MessageButtonsTests {
    @Test func messageButtonsRenderPostbacksAndLinks() {
        let buttons: [MessageButton] = [
            MessageButton(text: "Menu", kind: .postback),
            MessageButton(text: "Our site", kind: .link, url: "https://yalo.ai"),
            MessageButton(text: "No address", kind: .link),
        ]

        #expect(renders(MessageButtons(buttons: buttons)))
    }
}
