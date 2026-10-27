# Theming

The `theme` prop of `Chat` takes a `ChatTheme` that controls how the chat paints itself, without touching its internals.

Every value is optional. Anything left out keeps the platform default, which follows the device light and dark mode: Material colors on Android and system colors on iOS.

## Table of contents

- [Usage](#usage)
- [Values](#values)
  - [Colors](#colors)
  - [Shapes](#shapes)
  - [Sizes](#sizes)
- [Properties reference](#properties-reference)
  - [Window](#window)
  - [Header](#header)
  - [Footer and input](#footer-and-input)
  - [Messages](#messages)
  - [Quick replies](#quick-replies)
  - [Message buttons](#message-buttons)
  - [Typing indicator](#typing-indicator)
- [Light and dark](#light-and-dark)
- [Full theming example](#full-theming-example)

## Usage

Pass only the values you want to change:

```tsx
<Chat
  client={client}
  theme={{
    headerBackground: '#6200ee',
    onHeaderBackground: 'white',
    userMessageBackground: '#ede7f6',
  }}
/>
```

Everything you leave out keeps following the platform.

## Values

### Colors

Colors take any React Native color string or number, such as `'#6200ee'`, `'rgba(98, 0, 238, 0.5)'` or `'white'`.

- `PlatformColor` and `DynamicColorIOS` are not supported yet. They are ignored with a warning, and the default is kept.

### Shapes

Shapes are corner radii in points.

- A number rounds every corner, for example `12`.
- An object rounds only the corners it names, and the rest stay square, for example `{ topStart: 18, topEnd: 18 }`.
- The corners are `topStart`, `topEnd`, `bottomEnd` and `bottomStart`. Start and end follow the reading direction, so they flip in right to left languages.
- A radius larger than half the shorter side is capped there, so a big number such as `999` rounds the ends fully.

### Sizes

Sizes are in points, the same unit React Native uses for layout.

## Properties reference

Each color pair works the same way: the `background` value paints a surface and the matching `on...` value paints the text and icons drawn on it.

Some values are not drawn on iOS yet. They are marked "Android only" below and are ignored on iOS until the iOS SDK supports them.

### Window

- **`background`** (color): Background of the conversation area. Defaults to the Material `surface` color on Android and the system background color on iOS.
- **`onBackground`** (color, Android only): Color used for content drawn on the conversation background. Defaults to the Material `onSurface` color.

### Header

- **`headerBackground`** (color): Background of the bar above the conversation. Defaults to the Material `surfaceContainer` color on Android and the secondary system background color on iOS.
- **`onHeaderBackground`** (color): Color of the channel name, the status line, the watermark and the back button. Defaults to the Material `onSurface` color on Android and the system label color on iOS.

### Footer and input

- **`footerBackground`** (color): Background of the bar holding the message input. Defaults to the Material `surfaceContainer` color on Android and the secondary system background color on iOS.
- **`onFooterBackground`** (color): Color of the content in that bar. Defaults to the Material `onSurface` color on Android and the system label color on iOS.
- **`inputShape`** (shape): Shape of the message input and of the recording bar that replaces it. Defaults to fully rounded ends.
- **`inputBorderColor`** (color): Color of the line around the message input. That line goes around the place text is typed and the plus that picks a picture together, so the two read as one input. The recording bar follows it too. Defaults to the Material `outline` color on Android and the system separator color on iOS.
- **`inputFieldBorderColor`** (color, Android only): Color of the line around the place text is typed on its own, inside the one above. Defaults to transparent, so only the outer line shows. Set a color when you want the field and the plus told apart.
- **`inputBackground`** (color): Fill of the message input, inside its line. The recording bar follows it too. Defaults to transparent, so the footer shows through.
- **`sendButtonBackground`** (color): Fill of the round button after the input, both while it sends and while it records. While there is nothing to send it is drawn faded. Defaults to the Material `primary` color on Android and the accent color on iOS.
- **`onSendButtonBackground`** (color): Color of the icon on that button. Defaults to the Material `onPrimary` color on Android and white on iOS.

### Messages

- **`userMessageBackground`** (color): Bubble background for messages the person sent. Defaults to the Material `surfaceContainerHigh` color on Android and the secondary system background color on iOS.
- **`onUserMessageBackground`** (color): Text color inside those bubbles. Defaults to the Material `onSurface` color on Android and the system label color on iOS.
- **`userMessageShape`** (shape): Shape of the person's bubbles. Defaults to a rounded shape with a squared off bottom corner on the side the bubble sits on Android, and every corner rounded by 18 points on iOS.
- **`agentMessageBackground`** (color): Background for messages the channel sent. Defaults to transparent, so what the channel says reads as the conversation itself rather than as a reply. Set a color to put them in a bubble.
- **`onAgentMessageBackground`** (color): Text color for those messages. Defaults to the Material `onSurface` color on Android and the system label color on iOS.
- **`agentMessageShape`** (shape): Shape of the bubble around those messages. Defaults to square corners, which is invisible while the background is transparent. Set it along with `agentMessageBackground` when you want those messages bubbled.
- **`agentMessageBorderColor`** (color): Color of the line around that bubble. Defaults to transparent.
- **`agentMessagePadding`** (size): Room between that bubble and what is inside it. Defaults to `0`, so the text lines up with the conversation while there is no bubble.
- **`linkColor`** (color, Android only): Color of the links inside a message the channel sent. Defaults to the Material `primary` color.
- **`imageShape`** (shape, Android only): Shape a picture is cut to inside a message. Defaults to a rounded shape.

A voice message has no color of its own. It draws its waveform in the text color of whatever it sits on, so it follows `onUserMessageBackground` in the person's bubbles, `onAgentMessageBackground` in the channel's, and `onFooterBackground` while a recording is being made.

### Quick replies

These paint the chips the person taps to answer.

- **`quickReplyBackground`** (color): Background of a chip. Defaults to transparent. Set a color to fill it.
- **`onQuickReplyBackground`** (color): Color of the text on a chip. Defaults to the Material `onSurface` color on Android and the system label color on iOS.
- **`quickReplyBorderColor`** (color): Color of the line around a chip. Defaults to the Material `outline` color on Android and the system separator color on iOS.
- **`quickReplyShape`** (shape): Shape of a chip. Defaults to fully rounded ends.

### Message buttons

These paint the buttons stacked under a message, both the ones that answer the channel and the links that open a page. A link also shows an arrow in the text color. The last button the person tapped on a message stays highlighted, links excluded.

- **`postbackBackground`** (color): Background of a button. Defaults to transparent. Set a color to fill it.
- **`onPostbackBackground`** (color): Color of the text on a button. Defaults to the Material `onSurface` color on Android and the system label color on iOS.
- **`postbackBorderColor`** (color): Color of the line around a button. Defaults to the Material `outline` color on Android and the system separator color on iOS.
- **`postbackShape`** (shape, Android only): Shape of a button. Defaults to a lightly rounded shape.
- **`selectedPostbackBackground`** (color): Background of the button the person tapped last. Defaults to the Material `secondaryContainer` color on Android and the system tertiary fill color on iOS.
- **`onSelectedPostbackBackground`** (color): Color of the text on the button the person tapped last. Defaults to the Material `onSecondaryContainer` color on Android and the system label color on iOS.

### Typing indicator

- **`typingIndicatorDotColor`** (color): Color of the animated dots shown while the chat waits for a reply. Defaults to the Material `onSurfaceVariant` color on Android and the secondary system label color on iOS.

## Light and dark

Because the defaults come from the platform, a chat with no theme of its own switches with the device. If you override a value, you own it in both modes, so pick the color from the current scheme rather than hardcoding one:

```tsx
import { useColorScheme } from 'react-native';

function SupportChat({ client }: { client: YaloChatClient }) {
  const dark = useColorScheme() === 'dark';
  return (
    <Chat
      client={client}
      theme={{
        headerBackground: dark ? '#1f2937' : '#ede7f6',
        onHeaderBackground: dark ? 'white' : '#1f2937',
      }}
    />
  );
}
```

The theme is read again whenever it changes, so the chat follows the device as soon as the scheme switches.

## Full theming example

```tsx
import { Chat, type ChatTheme, type YaloChatClient } from 'yalo-chat-react-native-sdk';

const brand = '#6200ee';

const theme: ChatTheme = {
  background: 'white',
  onBackground: '#1c1b1f',
  headerBackground: brand,
  onHeaderBackground: 'white',
  footerBackground: 'white',
  onFooterBackground: '#1c1b1f',
  userMessageBackground: brand,
  onUserMessageBackground: 'white',
  agentMessageBackground: '#f3edf7',
  onAgentMessageBackground: '#1c1b1f',
  agentMessagePadding: 12,
  typingIndicatorDotColor: brand,
  linkColor: brand,
  quickReplyBackground: 'transparent',
  onQuickReplyBackground: brand,
  quickReplyBorderColor: brand,
  postbackBackground: 'transparent',
  onPostbackBackground: brand,
  postbackBorderColor: brand,
  selectedPostbackBackground: brand,
  onSelectedPostbackBackground: 'white',
  inputShape: 8,
  inputBorderColor: brand,
  inputBackground: 'white',
  sendButtonBackground: brand,
  onSendButtonBackground: 'white',
  userMessageShape: 16,
  agentMessageShape: 16,
  imageShape: 8,
  quickReplyShape: 16,
  postbackShape: 8,
};

export function BrandedChat({ client }: { client: YaloChatClient }) {
  return <Chat client={client} theme={theme} />;
}
```
