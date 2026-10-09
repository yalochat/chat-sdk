// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

/// Every expected value was produced by the web SDK's `xxhash32`. They keep a
/// conversation scoped by context the same one on every client, so a change
/// that moves any of them has to be made on all of them at once.
struct XxHash32Tests {
    @Test(arguments: [
        ("", "ry8zp"),
        ("a", "nlkdw6"),
        ("abc", "e3lqf3"),
        ("{}", "6qi9vt"),
        (#"{"source":"product-page"}"#, "1e2gi7e"),
        (#"{"source":"product-page","sku":"37549996"}"#, "188hajw"),
        (#"{"sku":"37549996","source":"product-page"}"#, "13rbbtq"),
        ("the quick brown fox jumps over the lazy dog", "sf9uuv"),
        (#"{"emoji":"ñ é 漢字"}"#, "tyxmh7"),
    ])
    func matchesTheWebSDK(input: String, expected: String) {
        #expect(xxhash32(input) == expected)
    }
}
