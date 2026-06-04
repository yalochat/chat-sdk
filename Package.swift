// swift-tools-version:5.7
// Copyright (c) Yalochat, Inc. All rights reserved.

import PackageDescription

// YaloChatIosSDK — complete iOS chat SDK for Yalo.
// Consumers add this package via File > Add Package Dependencies in Xcode
// using the repo URL: https://github.com/yalochat/chat-sdk
//
// The SDK has two layers:
//   YaloChatIosSDK — Swift/SwiftUI UI layer (this source target)
//   ChatSdk        — KMP business logic (pre-compiled XCFramework)
let package = Package(
    name: "YaloChatIosSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "YaloChatIosSDK",
            targets: ["YaloChatIosSDK"]
        ),
    ],
    targets: [
        .target(
            name: "YaloChatIosSDK",
            dependencies: ["ChatSdk"],
            path: "ios-sdk/Sources/YaloChatSDK",
            resources: [
                .process("Resources"),
            ]
        ),
        .binaryTarget(
            name: "ChatSdk",
            url: "https://github.com/yalochat/chat-sdk/releases/download/v0.0.1/ChatSdk.xcframework.zip",
            checksum: "0000000000000000000000000000000000000000000000000000000000000000"
        ),
    ]
)
