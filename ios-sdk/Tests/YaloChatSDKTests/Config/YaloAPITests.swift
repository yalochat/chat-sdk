// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

struct YaloAPITests {
    @Test func usesProductionByDefault() {
        #expect(YaloAPI.baseURL(environment: [:]).absoluteString == "https://\(YaloAPI.productionHost)")
    }

    @Test func usesTheHostFromTheEnvironment() {
        let url: URL = YaloAPI.baseURL(environment: ["YALO_API_BASE_URL": "example.yalochat.com/public-api-gateway"])

        #expect(url.absoluteString == "https://example.yalochat.com/public-api-gateway")
    }

    @Test func ignoresAnEmptyHost() {
        #expect(YaloAPI.baseURL(environment: ["YALO_API_BASE_URL": ""]).absoluteString == "https://\(YaloAPI.productionHost)")
    }

    @Test func ignoresAHostThatIsNotAURL() {
        #expect(YaloAPI.baseURL(environment: ["YALO_API_BASE_URL": "bad host"]).absoluteString == "https://\(YaloAPI.productionHost)")
    }

    @Test func baseURLReadsTheProcessEnvironment() {
        #expect(YaloAPI.baseURL == YaloAPI.baseURL(environment: ProcessInfo.processInfo.environment))
    }
}
