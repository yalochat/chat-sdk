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
  - [Quick replies](#quick-replies)
  - [Shapes](#shapes)
  - [Message buttons](#message-buttons)
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
- **`inputBorderColor`** (`Color`): Color of the line around the message input. The recording bar follows it too. Defaults to the system separator color.
- **`inputBackground`** (`Color`): Fill of the message input, inside its line. Defaults to clear, so the footer shows through.
- **`inputShape`** (`ChatShape`): Shape of the message input and the recording bar. Defaults to `.capsule`.
- **`sendButtonBackground`** (`Color`): Fill of the round button after the input, both while it sends and while it records. Defaults to the accent color. While there is nothing to send it is drawn faded.
- **`onSendButtonBackground`** (`Color`): Color of the icon on that button. Defaults to white.

### Messages

- **`userMessageBackground`** (`Color`): Bubble background for messages the person sent. Defaults to the secondary system background color.
- **`onUserMessageBackground`** (`Color`): Text color inside those bubbles. Defaults to the system label color.
- **`userMessageShape`** (`ChatShape`): Shape of the person's bubbles. Defaults to every corner rounded by 18 points.
- **`agentMessageBackground`** (`Color`): Background for messages the channel sent. Defaults to clear, so what the channel says reads as the conversation itself rather than as a reply. Set a color to put them in a box.
- **`onAgentMessageBackground`** (`Color`): Text color for those messages. Defaults to the system label color.
- **`agentMessageShape`** (`ChatShape`): Shape of the box around those messages. Defaults to square corners, which is invisible while the background is clear. Set it along with `agentMessageBackground` when you want those messages boxed.
- **`agentMessageBorderColor`** (`Color`): Color of the line around that box. Defaults to clear.
- **`agentMessagePadding`** (`CGFloat`): Room between that box and what is inside it. Defaults to 0, so the text lines up with the conversation while there is no box.
- **`typingIndicatorDotColor`** (`Color`): Color of the three dots shown while the chat waits for a reply. Defaults to the secondary system label color.

### Quick replies

These paint the chips the person taps to answer.

- **`quickReplyBackground`** (`Color`): Background of a chip. Defaults to clear. Set a color to fill it.
- **`onQuickReplyBackground`** (`Color`): Color of the text on a chip. Defaults to the system label color.
- **`quickReplyBorderColor`** (`Color`): Color of the line around a chip. Defaults to the system separator color.
- **`quickReplyShape`** (`ChatShape`): Shape of a chip. Defaults to `.capsule`.

### Shapes

A `ChatShape` rounds each corner on its own. A radius larger than half the shorter side is capped there.

- `ChatShape(radius: 8)` rounds every corner by 8 points.
- `ChatShape(topLeading: 16, topTrailing: 16)` rounds only the corners it names.
- `.capsule` rounds the ends fully, whatever the height.

### Message buttons

These paint the buttons stacked under a message, both the ones that answer the channel and the links that open a page. A link also shows an arrow in the text color. The answer the person tapped last stays highlighted.

- **`postbackBackground`** (`Color`): Background of a button. Defaults to clear. Set a color to fill it.
- **`onPostbackBackground`** (`Color`): Color of the text on a button. Defaults to the system label color.
- **`postbackBorderColor`** (`Color`): Color of the line around a button. Defaults to the system separator color.
- **`selectedPostbackBackground`** (`Color`): Background of the button the person tapped last on a message. Defaults to the system tertiary fill color.
- **`onSelectedPostbackBackground`** (`Color`): Color of the text on the button the person tapped last. Defaults to the system label color.

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
                inputBackground: Color(.systemBackground),
                inputShape: ChatShape(radius: 8),
                sendButtonBackground: brand,
                onSendButtonBackground: .white,
                userMessageBackground: brand,
                onUserMessageBackground: .white,
                agentMessageBackground: .clear,
                onAgentMessageBackground: Color(.label),
                typingIndicatorDotColor: brand,
                quickReplyBackground: .clear,
                onQuickReplyBackground: brand,
                quickReplyBorderColor: brand,
                quickReplyShape: ChatShape(radius: 8),
                postbackBackground: .clear,
                onPostbackBackground: brand,
                postbackBorderColor: brand
            )
        )
    }
}
```
