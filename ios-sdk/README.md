# iOS Chat SDK

Yalo iOS Chat SDK lets you drop a chat screen into any SwiftUI app.

The SDK is in early development. The chat screen shows its layout, and sending and receiving messages is not wired up yet.

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Open context](#open-context)
- [Session modes](#session-modes)
- [Clearing messages](#clearing-messages)
- [Logging out](#logging-out)
- [Data on the device](#data-on-the-device)
- [Voice messages](#voice-messages)
- [Image messages](#image-messages)
- [Quick replies and buttons](#quick-replies-and-buttons)
- [Theming](#theming)
- [Logging](#logging)
- [Translations](#translations)
- [Custom commands](#custom-commands)

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

To show an avatar beside the channel name, pass any view. The SDK does not load the image for you, so use `AsyncImage` or whatever your app already uses:

```swift
Chat(client: client) {
    AsyncImage(url: URL(string: "https://example.com/logo.png")) { image in
        image.resizable()
    } placeholder: {
        Color.gray
    }
    .frame(width: 40, height: 40)
    .clipShape(Circle())
}
```

With `welcomeMessageType` set to `.verticalQuickReplies`, the avatar is also drawn centered above the welcome message, until the person sends something.

## Configuration

`YaloChatClientConfig` takes the details of the conversation.

Required properties:

- **`channelId`** (`String`): Your channel identifier.
- **`organizationId`** (`String`): Your organization identifier.
- **`channelName`** (`String`): Name displayed in the chat header.

Optional properties:

- **`userId`** (`String?`): Your own user identifier. When provided, the conversation is linked to your user, so the same person picks up where they left off on any device. Defaults to `nil`, which keeps the conversation anonymous. An anonymous conversation still picks up where it was left on the same device, until the app is deleted.
- **`userAuthTokenProvider`** (`(@Sendable () async throws -> String?)?`): Returns a JSON Web Token (JWT) compliant with [RFC 7519](https://www.rfc-editor.org/rfc/rfc7519), signed by your backend, that proves who the signed-in person is. Use it with channels set up to verify your users. The SDK calls it every time it authenticates, so return a fresh token each time. When set, the backend takes the person from the token. You must also set `userId` to the same value as the token's `sub` claim, so each signed-in person keeps their own conversation on the device. If it returns `nil` or throws, the chat does not connect. Defaults to `nil`. It is not taken into account when comparing two configs.
  - The token should use the claim names from RFC 7519:
    - `sub`: your own id for the user. Keep it stable and unique, and pass the same value as `userId`.
    - `iss`: who issued the token, your backend.
    - `aud`: who the token is for, Yalo.
    - `exp`: when the token expires. Keep it short, a few minutes is enough, since a new one is asked for every time.
    - `iat` (optional): when the token was issued.
    - `jti` (recommended): a unique id for the token. With it, each token can be used only once, so a token that leaks cannot be used again.
  - For profile details such as name, email or phone, use the standard claim names `name`, `email` and `phone_number`.
  ```swift
  YaloChatClientConfig(
      channelId: "your-channel-id",
      organizationId: "your-organization-id",
      channelName: "Yalo",
      userId: signedInUser.id, // same value as the token's sub
      userAuthTokenProvider: { try await myBackend.yaloToken() }
  )
  ```
- **`quickReplyType`** (`QuickReplyType`): Where the answers a message offers are shown. Defaults to `.modal`, which puts them in a bar above the message input. Set `.inline` to put them under the message that offered them. See [Quick replies and buttons](#quick-replies-and-buttons).
- **`welcomeMessageType`** (`WelcomeMessageType`): How the first message of a conversation is drawn. Defaults to `.none`, which draws it like any other message.
  - `.verticalQuickReplies`: while the person has not sent anything yet and the channel has said only one thing, that message is shown centered, with the avatar above it and one quick reply per line under it, whatever `quickReplyType` says. Once the person sends a message, the avatar leaves the conversation and it is drawn as usual.
- **`logLevel`** (`LogLevel`): How much the SDK writes to the system log. Defaults to `.warn`, which keeps it quiet outside of warnings and errors. See [Logging](#logging).
- **`openContext`** (`[String: String]`): What the chat is being opened from, for example the product the person was looking at. Sent to the channel when the chat opens on an empty conversation, so it can speak first. Defaults to no context. See [Open context](#open-context).
- **`sessionMode`** (`SessionMode`): How the conversation is scoped, and whether it is remembered between visits. Defaults to `.shared`, which is one conversation per person, remembered. See [Session modes](#session-modes).
- **`hideWatermark`** (`Bool`): Leaves the "By Yalo" line under the channel name out of the header. Defaults to `false`, which shows it.
- **`hideVoiceButton`** (`Bool`): Leaves the microphone out of the message input, so nobody can record a voice message. Voice messages the channel sends are still shown. Defaults to `false`, which shows it.
- **`hideAttachmentButton`** (`Bool`): Leaves the plus out of the message input, so nobody can pick a picture to send. Pictures the channel sends are still shown. Defaults to `false`, which shows it.
- **`hideFeedbackButtons`** (`Bool`): Leaves the thumbs up and thumbs down out from under the channel's messages, so nobody can rate them. Defaults to `false`, which shows them once the person has sent their first message, so the welcome message has none. A picked rating stays selected, and tapping it again takes it back.

## Open context

The chat can tell the channel where it was opened from, so the conversation starts with something about what the person is doing rather than a generic greeting.

```swift
YaloChatClient(config: YaloChatClientConfig(
    channelId: "your-channel-id",
    organizationId: "your-organization-id",
    channelName: "Support",
    openContext: ["source": "product-page", "sku": "37549996"]
))
```

What to expect:

- The context is sent once, when the chat is shown and the conversation has nothing in it yet.
- A conversation already under way is picked up where it was left and nothing is sent, so nobody is greeted twice.
- The keys and values are yours. The channel decides what to make of them.
- The loading indicator is shown while the chat waits for the channel to say the first thing.

The context is part of the configuration, so a chat opened from somewhere else needs its own client. By default every context shares one conversation. To give each its own, set `sessionMode` to `.perContext`. See [Session modes](#session-modes).

## Session modes

`sessionMode` decides how a conversation is scoped and whether it is remembered.

```swift
YaloChatClient(config: YaloChatClientConfig(
    channelId: "your-channel-id",
    organizationId: "your-organization-id",
    channelName: "Support",
    sessionMode: .ephemeral
))
```

The modes:

- **`.shared`** (default): one conversation per person, remembered until the app is deleted. What the chat was opened from makes no difference to which conversation is shown.
- **`.perContext`**: one conversation per `openContext`, remembered the same way. Two chats opened from the same context carry on the same conversation, and a different context starts its own. A chat with no `openContext` behaves like `.shared`.
- **`.ephemeral`**: a new conversation every time the chat is shown, and nothing left behind once it is closed.

What to expect from `.ephemeral`:

- Closing the chat ends the conversation. Its messages and pictures are deleted.
- Leaving the chat on screen while the app goes to the background keeps the conversation.
- Whatever an app closed from the app switcher did not get to delete is deleted the next time a chat is shown.
- Two chats shown at once are two conversations, even when they were built from the same client.

Each mode is also its own person to the channel, so a conversation scoped by context or by a single visit does not pick up what another one said.

## Clearing messages

Call `clearMessages()` to delete every message stored on the device.

```swift
await client.clearMessages()
```

Notes:

- It deletes the messages of every conversation, whatever client or `sessionMode` they came from.
- It works whether or not a chat is on screen. The messages are deleted by the time it returns.
- Every chat on screen empties and the channel greets the person again, as in a new conversation.
- The person stays the same to the channel. To start over as a new person, use `logout()`.

## Logging out

Call `logout()` when the person logs out of your app.

```swift
await client.logout()
```

Notes:

- It deletes every message and every session stored on the device, of every conversation.
- It works whether or not a chat is on screen. Everything is deleted by the time it returns.
- Every chat on screen empties and connects again as a new person, and the channel greets them.

## Data on the device

- Messages, pictures and voice notes are kept in the app's own storage.
- The access and refresh tokens are kept in the Keychain, which stores them encrypted. They can only be read once the device has been unlocked after a restart, and they never leave the device, not even in a backup.
- `clearMessages()` and `logout()` delete them. See [Clearing messages](#clearing-messages) and [Logging out](#logging-out).

## Voice messages

The person taps the microphone to record a voice message and the send button to send it. The first time, iOS asks them for the microphone.

Add `NSMicrophoneUsageDescription` to your app's `Info.plist` with a short reason, for example:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Lets you record voice messages in the chat.</string>
```

iOS closes any app that asks for the microphone without it. If you do not want voice messages, set `hideVoiceButton` to `true` instead.

## Image messages

The person taps the plus in the message input to pick a picture from their photo library and send it. The chat uses the system photo picker, which only hands over the picture the person picked, so your app does not need to ask for photo library access or add anything to its `Info.plist`.

If you do not want image messages, set `hideAttachmentButton` to `true`.

## Quick replies and buttons

The channel can attach buttons to what it says. Tapping one sends its text as if the person had typed it.

- **Quick replies** are answers to the message.
  - They are offered until the person says something, typed or tapped, and then they go away.
  - `quickReplyType` decides where they are shown:
    - `.modal` (default): in a bar between the conversation and the message input.
    - `.inline`: under the message that offered them.
- **Postback buttons** stay under the message that sent them, one per line, and can be tapped again later in the conversation. The one the person tapped last stays highlighted.
- **Link buttons** sit with the postback buttons and show an arrow. Tapping one opens its address outside the chat instead of sending anything.

```swift
YaloChatClient(config: YaloChatClientConfig(
    channelId: "your-channel-id",
    organizationId: "your-organization-id",
    channelName: "Support",
    quickReplyType: .inline
))
```

See [Theming](doc/theming.md#quick-replies) to change their colors.

## Theming

Pass a `ChatTheme` to change the colors of the chat. Every value you leave out keeps following the system light and dark colors:

```swift
Chat(
    client: client,
    theme: ChatTheme(headerBackground: .indigo, onHeaderBackground: .white)
)
```

See [Theming](doc/theming.md) for every property.

## Logging

The SDK writes to the system log under the subsystem `ai.yalo.chat.sdk`. Every line has a category naming the part of the SDK it came from, such as `Auth`, `MessageSocket`, `Messages`, `Media` or `Database`.

You can read it in the Xcode console, or in the Console app by filtering on `subsystem:ai.yalo.chat.sdk`.

How much it writes follows `logLevel` in the config:

- `.warn`
  - The default. Only what went wrong, which is what you want in a released app.
- `.info`
  - Adds the course of a conversation: connecting, authenticating, reconnecting, uploads and downloads.
- `.debug`
  - Adds the full payload of every message sent and received, exactly as it went over the socket.
  - Meant for working on an integration, not for a released app.
- `.error`
  - Only failures the chat could not work around.
- `.silent`
  - Nothing at all.

```swift
YaloChatClient(config: YaloChatClientConfig(
    channelId: "your-channel-id",
    organizationId: "your-organization-id",
    channelName: "Support",
    logLevel: .debug
))
```

No level ever writes an access or refresh token, or a signed media address.

What people actually said is different. Up to `.info` a line says that a message moved, never its content. At `.debug` the whole conversation is written as it goes over the socket. Ship a released app at `.warn`, which is the default.

## Translations

The chat follows the language of the device. It ships with:

- Arabic (`ar`)
- Chinese (`zh`, `zh-Hans`)
- Portuguese (`pt`, `pt-BR`)
- Spanish (`es`, `es-MX`)

Any other language falls back to English.

## Custom commands

The channel can ask your app to run something and wait for a reply. Register a handler under a command id of your choice. When the channel sends a request with that id, the SDK runs your handler with the request payload and sends what it returns back to the channel.

```swift
client.registerCommand("refreshCatalog") { payload in
    // payload: the string the channel sent
    let region: String = try region(in: payload)
    try await catalog.reload(region)
    return #"{"status":"reloaded"}"#
}
```

Notes:

- The handler is `async throws`, so it can await other work. The SDK waits for it before replying, and each request runs on its own.
- You choose the command id. The channel runs your handler by sending a custom command request with the same id.
- The handler only runs while a chat is open, since that is when the SDK is connected.
- The string you return becomes the response payload. Return an empty string when there is nothing to send back.
- If the handler throws, the SDK replies with an error status and an empty payload.
- When the channel sends a command id with no registered handler, the SDK logs a warning and sends no response.
- Registering the same id again replaces its handler.

### Returning the cart

`getCart` and `updateCartProduct` are built-in command ids for the cart. You register them with `registerCommand` like any other command, and their payloads are JSON.

`getCart` is sent when the channel asks for the products in the cart. Return the page of the cart as JSON.

```swift
client.registerCommand("getCart") { payload in
    // payload: {"cursor":"page-2","pageSize":20}
    let request: CartRequest = try JSONDecoder().decode(CartRequest.self, from: Data(payload.utf8))
    let page: CartPage = try await cart.page(after: request.cursor)
    return String(decoding: try JSONEncoder().encode(page), as: UTF8.self)
}

client.registerCommand("updateCartProduct") { payload in
    // payload: {"sku":"WATER-1L","units":2}
    let change: CartChange = try JSONDecoder().decode(CartChange.self, from: Data(payload.utf8))
    try await cart.set(change.sku, units: change.units)
    return ""
}
```

`CartRequest`, `CartPage` and `CartChange` stand for your own `Codable` types with the fields below.

The `getCart` payload has these fields:

- `cursor` (string, optional): the page the channel wants. Left out for the first page.
- `pageSize` (number, optional): the most products the channel wants in the page.

Return a JSON object with these fields:

- `products` (array): the products in the page. Each product has:
  - `sku` (string): unique product identifier.
  - `name` (string): product name.
  - `price` (number): base price.
  - `imagesUrl` (string array): image URLs for the product.
  - `salePrice` (number, optional): sale price. Takes precedence over `price`.
  - `subunits` (number): units contained in one unit, for example bottles inside a case.
  - `unitStep` (number): increment used when changing the unit quantity.
  - `unitName` (string): unit name in ICU message format, for example `{amount, plural, one {case} other {cases}}`.
  - `subunitName` (string, optional): subunit name in the same format.
  - `subunitStep` (number): increment used when changing the subunit quantity.
  - `unitsAdded` (number): units currently in the cart.
  - `subunitsAdded` (number): subunits currently in the cart.
- `pageInfo` (object, optional): leave it out when your cart is not paginated. It has:
  - `pageSize` (number): products requested per page.
  - `cursor` (string, optional): cursor that produced this page.
  - `nextCursor` (string, optional): cursor for the next page. Left out on the last page.
  - `prevCursor` (string, optional): cursor for the previous page. Left out on the first page.

If what you return is not valid JSON, the SDK replies with an error status.

### Updating a cart product

`updateCartProduct` is sent when the channel changes how much of a product is in the cart. The payload has these fields:

- `sku` (string): the product to change.
- `units` (number): units of the product in the cart after the change.
- `subunits` (number, optional): subunits after the change. Left out when the product has no subunits.

The SDK replies with a success status when your handler returns, and with an error status when it throws. What the handler returns is ignored.
