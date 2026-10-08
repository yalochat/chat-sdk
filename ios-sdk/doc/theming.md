# Theming

The iOS Chat SDK exposes a `ChatTheme` that controls how the chat paints itself, without touching its internals.

Every value defaults to a system color, so a chat dropped into an app already follows light and dark mode.

## Table of contents

- [Usage](#usage)
- [Properties reference](#properties-reference)
  - [Window](#window)
  - [Header](#header)
  - [Footer and input](#footer-and-input)
  - [Messages](#messages)
- [Light and dark](#light-and-dark)
- [Full theming example](#full-theming-example)

## Usage

Pass only the values you want to change. Everything you leave out keeps its default:

```swift
Chat(
    client: client,
    theme: ChatTheme(
        headerBackground: .indigo,
        onHeaderBackground: .white,
        userMessageBackground: Color(red: 0.93, green: 0.91, blue: 0.96)
    )
)
```

Every property is a `var`, so you can also start from the defaults and change values one at a time:

```swift
var theme: ChatTheme = ChatTheme()
theme.headerBackground = .indigo
theme.onHeaderBackground = .white

Chat(client: client, theme: theme)
```

## Properties reference

Each color pair works the same way: the `background` value paints a surface and the matching `on...` value paints the text and icons drawn on it.

### Window

- **`background`** (`Color`): Background of the conversation area. Defaults to the system background color.

### Header

- **`headerBackground`** (`Color`): Background of the bar above the conversation. Defaults to the secondary system background color.
- **`onHeaderBackground`** (`Color`): Color of the channel name, the status line, the watermark and the back button. Defaults to the system label color.

### Footer and input

- **`footerBackground`** (`Color`): Background of the bar holding the message input. Defaults to the secondary system background color.
- **`onFooterBackground`** (`Color`): Color of the content in that bar. Defaults to the system label color.
- **`inputBorderColor`** (`Color`): Color of the line around the message input. Defaults to the system separator color.

### Messages

- **`userMessageBackground`** (`Color`): Bubble background for messages the person sent. Defaults to the secondary system background color.
- **`onUserMessageBackground`** (`Color`): Text color inside those bubbles. Defaults to the system label color.
- **`agentMessageBackground`** (`Color`): Background for messages the channel sent. Defaults to clear, so what the channel says reads as the conversation itself rather than as a reply.
- **`onAgentMessageBackground`** (`Color`): Text color for those messages. Defaults to the system label color.
- **`typingIndicatorDotColor`** (`Color`): Color of the three dots shown while the chat waits for a reply. Defaults to the secondary system label color.

## Light and dark

The defaults are system colors, so a chat with no theme of its own switches with the device. If you override a value, you own it in both modes. Use colors that already adapt, such as colors from your asset catalog with a dark variant, rather than fixed ones:

```swift
Chat(
    client: client,
    theme: ChatTheme(
        headerBackground: Color("BrandBackground"),
        onHeaderBackground: Color("OnBrandBackground")
    )
)
```

## Full theming example

```swift
import SwiftUI
import YaloChatSDK

struct BrandedChat: View {
    let client: YaloChatClient

    private let brand: Color = Color(red: 0.38, green: 0.0, blue: 0.93)

    var body: some View {
        Chat(
            client: client,
            theme: ChatTheme(
                background: Color(.systemBackground),
                headerBackground: brand,
                onHeaderBackground: .white,
                footerBackground: Color(.systemBackground),
                onFooterBackground: Color(.label),
                inputBorderColor: brand,
                userMessageBackground: brand,
                onUserMessageBackground: .white,
                agentMessageBackground: .clear,
                onAgentMessageBackground: Color(.label),
                typingIndicatorDotColor: brand
            )
        )
    }
}
```
