# Theming

The Android Chat SDK exposes a `ChatTheme` that controls how the chat paints itself, without touching its internals.

Every value defaults to your app `MaterialTheme`, so a chat dropped into an app already follows that app's light and dark schemes.

## Table of contents

- [Usage](#usage)
- [Properties reference](#properties-reference)
  - [Window](#window)
  - [Header](#header)
  - [Footer and input](#footer-and-input)
  - [Messages](#messages)
  - [Typing indicator](#typing-indicator)
- [Light and dark](#light-and-dark)
- [Full theming example](#full-theming-example)

## Usage

Start from `ChatTheme.default()` and copy over only the values you want to change:

```kotlin
Chat(
    client = client,
    theme = ChatTheme.default().copy(
        headerBackground = Color(0xFF6200EE),
        onHeaderBackground = Color.White,
        userMessageBackground = Color(0xFFEDE7F6),
    ),
)
```

`ChatTheme.default()` is a composable function, so call it inside a composable. Everything you leave alone keeps following your `MaterialTheme`.

## Properties reference

Each color pair works the same way: the `background` value paints a surface and the matching `on...` value paints the text and icons drawn on it.

### Window

- **`background`** (`Color`): Background of the conversation area. Defaults to the Material `surface` color.
- **`onBackground`** (`Color`): Color used for content drawn on the conversation background. Defaults to the Material `onSurface` color.

### Header

- **`headerBackground`** (`Color`): Background of the bar above the conversation. Defaults to the Material `surfaceContainer` color.
- **`onHeaderBackground`** (`Color`): Color of the channel name, the status line, the watermark, the back button and the avatar area. Defaults to the Material `onSurface` color.

### Footer and input

- **`footerBackground`** (`Color`): Background of the bar holding the message input. Defaults to the Material `surfaceContainer` color.
- **`onFooterBackground`** (`Color`): Color of the content in that bar. Defaults to the Material `onSurface` color.
- **`inputShape`** (`Shape`): Shape of the message input. Defaults to the Material `extraLarge` shape, which gives a fully rounded field.

### Messages

- **`userMessageBackground`** (`Color`): Bubble background for messages the person sent. Defaults to the Material `surfaceContainerHigh` color.
- **`onUserMessageBackground`** (`Color`): Text color inside those bubbles. Defaults to the Material `onSurface` color.
- **`agentMessageBackground`** (`Color`): Bubble background for messages the channel sent. Defaults to transparent, so what the channel says reads as the conversation itself rather than as a reply. Set a color to give it a bubble.
- **`onAgentMessageBackground`** (`Color`): Text color for those messages. Defaults to the Material `onSurface` color.
- **`userMessageShape`** (`Shape`): Shape of the person's bubbles. Defaults to a rounded shape with a squared off bottom corner on the side the bubble sits.
- **`agentMessageShape`** (`Shape`): Shape of the channel's bubbles. Defaults to a rectangle, which is invisible while the background is transparent. Set it along with `agentMessageBackground` when you want those messages bubbled.

### Typing indicator

- **`typingIndicatorDotColor`** (`Color`): Color of the animated dots shown while the chat waits for a reply. Defaults to the Material `onSurfaceVariant` color.

## Light and dark

Because the defaults read from `MaterialTheme`, a chat with no theme of its own switches with your app. If you override a value, you own it in both schemes, so read your own colors rather than hardcoding them:

```kotlin
Chat(
    client = client,
    theme = ChatTheme.default().copy(
        headerBackground = MaterialTheme.colorScheme.primaryContainer,
        onHeaderBackground = MaterialTheme.colorScheme.onPrimaryContainer,
    ),
)
```

Reading from your own color scheme keeps the chat correct when the device switches to dark mode, since your scheme already changed with it.

## Full theming example

```kotlin
import ai.yalo.chat.sdk.ui.Chat
import ai.yalo.chat.sdk.ui.theme.ChatTheme

@Composable
fun BrandedChat(client: YaloChatClient) {
    val brand = Color(0xFF6200EE)
    Chat(
        client = client,
        theme = ChatTheme.default().copy(
            background = MaterialTheme.colorScheme.surface,
            onBackground = MaterialTheme.colorScheme.onSurface,
            headerBackground = brand,
            onHeaderBackground = Color.White,
            footerBackground = MaterialTheme.colorScheme.surface,
            onFooterBackground = MaterialTheme.colorScheme.onSurface,
            userMessageBackground = brand,
            onUserMessageBackground = Color.White,
            agentMessageBackground = MaterialTheme.colorScheme.surfaceContainer,
            onAgentMessageBackground = MaterialTheme.colorScheme.onSurface,
            typingIndicatorDotColor = brand,
            inputShape = RoundedCornerShape(8.dp),
            userMessageShape = RoundedCornerShape(16.dp),
            agentMessageShape = RoundedCornerShape(16.dp),
        ),
    )
}
```
