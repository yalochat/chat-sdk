# Android Chat SDK

Yalo Android Chat SDK lets you drop a chat screen into any Jetpack Compose app.

The chat renders inside the space you give it, follows your app theme out of the box, and speaks every language the SDK ships with.

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [The Chat composable](#the-chat-composable)
  - [Sizing and window insets](#sizing-and-window-insets)
  - [Avatar](#avatar)
  - [Back button](#back-button)
- [Theming](#theming)
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

Two chats built from the same `channelId`, `organizationId` and `userId` are the same conversation and show the same messages.

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

## Theming

The chat derives its colors and shapes from your `MaterialTheme`, so it follows your light and dark schemes with no setup. Override only what you need. See the [Theming API](doc/theming.md) for the full list of properties.

## Translations

The chat ships translated into every supported language and follows the device language. See [Translations](doc/translations.md) for the list and for how to replace a string with your own copy.

## Methods

- **`client.sendTextMessage(text)`**: Sends text as if the person had typed it in the input. Blank text is ignored. You can call it before the chat is on screen: the message waits until a chat opens and is then delivered once.
