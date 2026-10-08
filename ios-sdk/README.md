# iOS Chat SDK

Yalo iOS Chat SDK lets you drop a chat screen into any SwiftUI app.

The SDK is in early development. The chat screen shows its layout, and sending and receiving messages is not wired up yet.

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Voice messages](#voice-messages)
- [Theming](#theming)
- [Translations](#translations)

## Requirements

- iOS 15 or newer.
- SwiftUI. The chat is a SwiftUI view, so you show it from a SwiftUI screen or through a `UIHostingController`.

## Installation

The SDK is distributed with Swift Package Manager.

In Xcode, choose **File > Add Package Dependencies**, enter the repository URL and pick a version:

```
https://github.com/yalochat/chat-sdk
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yalochat/chat-sdk", from: "0.1.0"),
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "YaloChatSDK", package: "chat-sdk"),
        ]
    ),
]
```

Replace `0.1.0` with the version you want. Every released version has a matching `X.Y.Z` tag in this repository.

To try the SDK without adding it to your own app, open `ios-sdk/YaloChatSDK.xcworkspace` and run the `ExampleApp` scheme.

## Quick start

Create a client with your channel details and show the `Chat` view wherever you want the conversation to appear:

```swift
import SwiftUI
import YaloChatSDK

struct SupportView: View {
    private let client: YaloChatClient = YaloChatClient(config: YaloChatClientConfig(
        channelId: "your-channel-id",
        organizationId: "your-organization-id",
        channelName: "Support"
    ))

    var body: some View {
        Chat(client: client)
    }
}
```

Creating a client is cheap, so an app with several conversations can hold one client per conversation without paying for any of them until a chat is shown.

The chat fills whatever space it is given. You decide where it lives: a full screen, a sheet, or a pane in an iPad layout.

When the person should be able to close the chat, pass `onBack`. The header then shows a back button that calls it:

```swift
Chat(client: client, onBack: {
    chatIsOpen = false
})
```

## Configuration

`YaloChatClientConfig` takes the details of the conversation.

Required properties:

- **`channelId`** (`String`): Your channel identifier.
- **`organizationId`** (`String`): Your organization identifier.
- **`channelName`** (`String`): Name displayed in the chat header.

Optional properties:

- **`userId`** (`String?`): Your own user identifier. When provided, the conversation is linked to your user, so the same person picks up where they left off. Defaults to `nil`, which keeps the conversation anonymous.
- **`hideWatermark`** (`Bool`): Leaves the "By Yalo" line under the channel name out of the header. Defaults to `false`, which shows it.
- **`hideVoiceButton`** (`Bool`): Leaves the microphone out of the message input, so nobody can record a voice message. Voice messages the channel sends are still shown. Defaults to `false`, which shows it.

## Voice messages

The person taps the microphone to record a voice message and the send button to send it. The first time, iOS asks them for the microphone.

Add `NSMicrophoneUsageDescription` to your app's `Info.plist` with a short reason, for example:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Lets you record voice messages in the chat.</string>
```

iOS closes any app that asks for the microphone without it. If you do not want voice messages, set `hideVoiceButton` to `true` instead.

## Theming

Pass a `ChatTheme` to change the colors of the chat. Every value you leave out keeps following the system light and dark colors:

```swift
Chat(
    client: client,
    theme: ChatTheme(headerBackground: .indigo, onHeaderBackground: .white)
)
```

See [Theming](doc/theming.md) for every property.

## Translations

The chat follows the language of the device. It ships with:

- Arabic (`ar`)
- Chinese (`zh`, `zh-Hans`)
- Portuguese (`pt`, `pt-BR`)
- Spanish (`es`, `es-MX`)

Any other language falls back to English.
