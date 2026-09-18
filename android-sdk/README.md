# Android Chat SDK

Yalo Android Chat SDK lets you drop a chat screen into any Jetpack Compose app.

The chat renders inside the space you give it, follows your app theme out of the box, and speaks every language the SDK ships with.

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Open context](#open-context)
- [The Chat composable](#the-chat-composable)
  - [Sizing and window insets](#sizing-and-window-insets)
  - [Avatar](#avatar)
  - [Back button](#back-button)
- [Message formatting](#message-formatting)
- [Quick replies](#quick-replies)
- [Theming](#theming)
- [Logging](#logging)
- [Translations](#translations)
- [Methods](#methods)

## Requirements

- Android 7.0 (API level 24) or newer.
- Jetpack Compose with Material 3. The chat is a composable, so the host screen has to be a Compose screen.
- Java 11 or newer for compilation.

## Installation

The SDK is published to Maven Central. Make sure `mavenCentral()` is in your repositories, then add the dependency to your app module:

```kotlin
// app/build.gradle.kts
dependencies {
    implementation("ai.yalo.chat:chat-android-sdk:0.0.1")
}
```

Replace `0.0.1` with the version you want. Every released version has a matching `android-sdk/vX.Y.Z` tag in this repository.

To try the SDK without adding it to your own app, open the `android-sdk` project and run its example app.

## Quick start

Create a client with your channel details and render the `Chat` composable wherever you want the conversation to appear:

```kotlin
import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.ui.Chat

class MainActivity : ComponentActivity() {

    private val client = YaloChatClient(
        YaloChatClientConfig(
            channelId = "your-channel-id",
            organizationId = "your-organization-id",
            channelName = "Support",
        ),
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MyAppTheme {
                Chat(client = client)
            }
        }
    }
}
```

Creating a client is cheap, so an app with several conversations can hold one client per conversation without paying for any of them until a chat is shown.

The chat fills whatever space it is given. You decide where it lives: a full screen, a pane in a tablet layout, a bottom sheet, or a panel that slides in over your content.

## Configuration

`YaloChatClientConfig` takes the details of the conversation.

Required properties:

- **`channelId`** (`String`): Your channel identifier.
- **`organizationId`** (`String`): Your organization identifier.
- **`channelName`** (`String`): Name displayed in the chat header.

Optional properties:

- **`userId`** (`String?`): Your own user identifier. When provided, the conversation is linked to your user, so the same person picks up where they left off. Defaults to `null`, which keeps the conversation anonymous on the device.
- **`logLevel`** (`LogLevel`): How much the SDK says about itself in logcat. Defaults to `LogLevel.Warn`, which keeps it quiet outside of warnings and errors. Raise it to `LogLevel.Debug` or `LogLevel.Info` while integrating, or set `LogLevel.Silent` to turn it off entirely. See [Logging](#logging).
- **`quickReplyType`** (`QuickReplyType`): Where the answers a message offers are shown. Defaults to `QuickReplyType.Modal`, which puts them in a bar above the message input. Set `QuickReplyType.Inline` to put them under the message that offered them. See [Quick replies](#quick-replies).
- **`openContext`** (`Map<String, String>`): What the chat is being opened from, for example the product the person was looking at. Sent to the channel when the chat opens on an empty conversation, so it can speak first. Defaults to no context. See [Open context](#open-context).

Two chats built from the same `channelId`, `organizationId` and `userId` are the same conversation and show the same messages.

## Open context

The chat can tell the channel where it was opened from, so the conversation starts with something about what the person is doing rather than a generic greeting.

```kotlin
private val client = YaloChatClient(
    YaloChatClientConfig(
        channelId = "your-channel-id",
        organizationId = "your-organization-id",
        channelName = "Support",
        openContext = mapOf("source" to "product-page", "sku" to "37549996"),
    ),
)
```

What to expect:

- The context is sent once, when the chat is shown and the conversation has nothing in it yet.
- A conversation already under way is picked up where it was left and nothing is sent, so nobody is greeted twice.
- The keys and values are yours. The channel decides what to make of them.
- The loading indicator is shown while the chat waits for the channel to say the first thing.

The context is part of the configuration, so a chat opened from somewhere else needs its own client.

## The Chat composable

```kotlin
@Composable
public fun Chat(
    client: YaloChatClient,
    modifier: Modifier = Modifier,
    theme: ChatTheme = ChatTheme.default(),
    avatar: (@Composable () -> Unit)? = null,
    onBack: (() -> Unit)? = null,
)
```

- **`client`**: The client holding the configuration for this conversation.
- **`modifier`**: Applied to the chat surface. Use it for padding, size and insets.
- **`theme`**: How the chat paints itself. Follows your `MaterialTheme` unless you pass one in. See [Theming](doc/theming.md).
- **`avatar`**: Drawn beside the channel name in the header. Nothing is drawn when you leave it out.
- **`onBack`**: Adds a back button to the header. The header has no back button unless you give one.

### Sizing and window insets

The chat does not apply window insets of its own, which lets it sit in a `Scaffold`, a bottom sheet, or any other host without fighting it. Pass the padding your host gives you through the modifier:

```kotlin
Scaffold { innerPadding ->
    Chat(
        client = client,
        modifier = Modifier
            .padding(innerPadding)
            .consumeWindowInsets(innerPadding)
            .imePadding(),
    )
}
```

`imePadding()` lifts the message input above the keyboard while the user types.

### Avatar

The avatar is a slot rather than an image URL, so the SDK does not force an image loading library on your app. Load the image with whatever you already use:

```kotlin
Chat(
    client = client,
    avatar = {
        AsyncImage(
            model = "https://example.com/logo.png",
            contentDescription = null,
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape),
        )
    },
)
```

### Back button

Pass `onBack` when the chat owns the whole screen and needs its own way out:

```kotlin
Chat(
    client = client,
    onBack = { chatIsOpen = false },
)
```

Leave it out when the chat is embedded in a screen that already has a way back, such as a tab or a pane next to your content.

## Message formatting

What the channel answers is written in markdown, and the chat draws it that way. Messages the person sends are shown exactly as they typed them, so their own asterisks and underscores stay put.

The chat draws:

- Emphasis
  - `**bold**`, `*italic*` and `~~strikethrough~~`.
- Links
  - `[label](https://example.com)`, and plain addresses such as `https://example.com`, which become tappable and open in the browser. They take their color from `linkColor` in the theme.
- Lists
  - Bulleted and numbered, including lists inside lists.
- Headings
  - From `#` to `######`, sized against the text around them.
- Code
  - `` `inline` `` and fenced blocks, set in a monospace face.
- Quotes
  - Lines starting with `>`.

Anything else, a table for instance, is shown as the text it was written as, so nothing an answer contains goes missing.

## Quick replies

When the channel offers a set of answers, the chat shows them as chips. Tapping one sends its text as a message from the person, exactly as if they had typed it.

Only the latest offer is live, and it goes away as soon as the person answers, whether they tapped a chip or typed something of their own.

Where the chips appear follows `quickReplyType`:

- `QuickReplyType.Modal`
  - The default. A bar between the conversation and the message input, holding only what the channel is offering right now.
  - The bar is always in reach, so a long conversation does not hide the answers.
- `QuickReplyType.Inline`
  - Chips under the message that offered them, scrolling with the conversation.
  - The answers stay next to the question they belong to.

```kotlin
YaloChatClient(
    YaloChatClientConfig(
        channelId = "your-channel-id",
        organizationId = "your-organization-id",
        channelName = "Support",
        quickReplyType = QuickReplyType.Inline,
    ),
)
```

Their colors and shape come from the theme, the same as the rest of the chat. See [Theming](doc/theming.md).

## Theming

The chat derives its colors and shapes from your `MaterialTheme`, so it follows your light and dark schemes with no setup. Override only what you need. See the [Theming API](doc/theming.md) for the full list of properties.

## Logging

The SDK writes to logcat under the single tag `YaloChatSDK`, so you can read everything it says and nothing else:

```
adb logcat -s YaloChatSDK
```

Every line names the part of the SDK it came from, such as `Auth`, `MessageSocket`, `Media`, `TokenStorage` or `Database`.

How much it writes follows `logLevel` in the config:

- `LogLevel.Warn`
  - The default. Only what went wrong, which is what you want in a released app.
- `LogLevel.Info`
  - Adds the course of a conversation: connecting, authenticating, reconnecting, uploads and downloads.
- `LogLevel.Debug`
  - Adds the full payload of every message sent and received, exactly as it went over the socket, along with each token read and the timers behind reconnecting.
  - Meant for working on an integration, not for a released app.
- `LogLevel.Error`
  - Only failures the chat could not work around.
- `LogLevel.Silent`
  - Nothing at all.

```kotlin
YaloChatClient(
    YaloChatClientConfig(
        channelId = "your-channel-id",
        organizationId = "your-organization-id",
        channelName = "Support",
        logLevel = LogLevel.Debug,
    ),
)
```

No level ever writes an access or refresh token, or a signed media address. Anything on the device can read logcat, so nothing that opens a session goes into it.

What people actually said is different. Up to `LogLevel.Info` a line says that a message moved and what kind it was, never its content. At `LogLevel.Debug` the whole conversation is written as it goes over the socket, in both directions, so you can follow an integration frame by frame. Ship a released app at `LogLevel.Warn`, which is the default.

## Translations

The chat ships translated into every supported language and follows the device language. See [Translations](doc/translations.md) for the list and for how to replace a string with your own copy.

## Methods

- **`client.sendTextMessage(text)`**: Sends text as if the person had typed it in the input. Blank text is ignored. You can call it before the chat is on screen: the message waits until a chat opens and is then delivered once.
