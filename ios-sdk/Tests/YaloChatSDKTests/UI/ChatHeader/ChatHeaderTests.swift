// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

@MainActor
struct ChatHeaderTests {
    @Test func headerRendersWithEveryPart() {
        #expect(renders(ChatHeader(title: "Yalo", status: "Online", onBack: {})))
    }

    @Test func headerRendersWithoutWatermark() {
        #expect(renders(ChatHeader(title: "Yalo", hideWatermark: true)))
    }

    @Test func watermarkIsLocalized() throws {
        let path: String = try #require(Bundle.module.path(forResource: "es", ofType: "lproj"))
        let spanish: Bundle = try #require(Bundle(path: path))
        let format: String = spanish.localizedString(forKey: "By %@", value: nil, table: nil)
        #expect(String(format: format, "Yalo") == "Por Yalo")
    }
}
