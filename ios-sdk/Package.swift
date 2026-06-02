// swift-tools-version:5.7
// Copyright (c) Yalochat, Inc. All rights reserved.

import PackageDescription

// YaloChatSDK — complete iOS chat SDK for Yalo.
// Consumers add this package via File > Add Package Dependencies in Xcode.
//
// The SDK has two layers:
//   YaloChatSDK  — Swift/SwiftUI UI layer (this source target)
//   ChatSdk      — KMP business logic (pre-compiled XCFramework)
let package = Package(
    name: "YaloChatSDK",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "YaloChatSDK",
            targets: ["YaloChatSDK"]
        ),
    ],
    targets: [
        .target(
            name: "YaloChatSDK",
            dependencies: ["ChatSdk"],
            path: "Sources/YaloChatSDK",
            resources: [
                .process("Resources"),
            ]
        ),
        .binaryTarget(
            name: "ChatSdk",
            url: "https://github.com/yalochat/chat-sdk/releases/download/ios-sdk/v0.0.1/ChatSdk.xcframework.zip",
            checksum: "PLACEHOLDER_UPDATED_BY_RELEASE_WORKFLOW"
        ),
    ]
)
