# React Native Chat SDK

Yalo React Native Chat SDK lets you drop a chat screen into any React Native app.

The chat is the native Yalo chat: the Android SDK on Android and the iOS SDK on iOS. Both take the same config and the same theme from JavaScript.

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [The Chat component](#the-chat-component)
- [Theming](#theming)
- [Platform differences](#platform-differences)

## Requirements

- React Native 0.86 or newer, with the New Architecture on.
- Android 7.0 (API level 24) or newer.
- iOS 15.1 or newer.

## Installation

```sh
npm install yalo-chat-react-native-sdk
```

Then install the iOS pods:

```sh
cd ios && pod install
```

Voice messages need the microphone:

- Android: add `<uses-permission android:name="android.permission.RECORD_AUDIO" />` to your `AndroidManifest.xml`.
- iOS: add `NSMicrophoneUsageDescription` to your `Info.plist`.

Set `hideVoiceButton` in the config to leave voice messages out, and the permission with them.

## Quick start

Create a client with your channel details and render `Chat` wherever you want the conversation to appear:

```tsx
import { Chat, YaloChatClient } from 'yalo-chat-react-native-sdk';

const client = new YaloChatClient({
  channelId: 'your-channel-id',
  organizationId: 'your-organization-id',
  channelName: 'Support',
});

export function SupportScreen() {
  return <Chat client={client} />;
}
```

Creating a client is cheap, so an app with several conversations can hold one client per conversation.

## Configuration

`YaloChatClientConfig` takes the details of the conversation.

Required properties:

- **`channelId`** (`string`): Your channel identifier.
- **`organizationId`** (`string`): Your organization identifier.
- **`channelName`** (`string`): Name displayed in the chat header.

Optional properties:

- **`userId`** (`string`): Your own user identifier. Leave it out to keep the conversation anonymous.
- **`logLevel`** (`'debug' | 'info' | 'warn' | 'error' | 'silent'`): How much the SDK writes to the device log. Defaults to `'warn'`.
- **`quickReplyType`** (`'modal' | 'inline'`): Where the quick replies a message offers are shown. Defaults to `'modal'`, a bar above the message input. `'inline'` puts them under the message that offered them.
- **`welcomeMessageType`** (`'none' | 'verticalQuickReplies'`): How the first message of a conversation is drawn. Defaults to `'none'`, like any other message. `'verticalQuickReplies'` shows it alone and centered, with one quick reply per line, until the person sends something.
- **`openContext`** (`Record<string, string>`): What the chat is being opened from, for example the product the person was looking at. Sent to the channel when the chat opens on an empty conversation.
- **`sessionMode`** (`'shared' | 'perContext' | 'ephemeral'`): How the conversation is scoped. Defaults to `'shared'`.
  - `'shared'`: one conversation per person, remembered.
  - `'perContext'`: one conversation per `openContext`, remembered.
  - `'ephemeral'`: a new conversation every time, nothing left behind.
- **`hideVoiceButton`** (`boolean`): Leaves the microphone out of the message input. Defaults to `false`.
- **`hideAttachmentButton`** (`boolean`): Leaves the plus out of the message input, so nobody can pick a picture to send. Defaults to `false`.
- **`hideWatermark`** (`boolean`): Leaves the "By Yalo" line out of the header. Defaults to `false`.

The config is read when the chat is shown. To change it, create a new client.

## The Chat component

Props:

- **`client`** (`YaloChatClient`): The conversation to show.
- **`theme`** (`ChatTheme`): Colors and shapes. See [Theming](#theming).
- **`onBack`** (`() => void`): Shows a back button in the header that calls it. Leave it out when the chat is not something the person closes.
- **`style`**: The chat fills the space it is given, `flex: 1` by default.

The chat leaves safe areas and the keyboard to your app, so wrap it in whatever your app already uses for them.

```tsx
<Chat client={client} onBack={() => navigation.goBack()} />
```

## Theming

Every value is optional. Anything left out keeps the platform default, which follows light and dark mode.

```tsx
<Chat
  client={client}
  theme={{
    headerBackground: '#1f2937',
    onHeaderBackground: 'white',
    userMessageShape: { topStart: 18, topEnd: 18, bottomStart: 18, bottomEnd: 4 },
    inputShape: 12,
  }}
/>
```

Colors take any React Native color string or number. `PlatformColor` and `DynamicColorIOS` are not supported yet and are ignored with a warning.

- `background`, `onBackground`
- `headerBackground`, `onHeaderBackground`
- `footerBackground`, `onFooterBackground`
- `userMessageBackground`, `onUserMessageBackground`
- `agentMessageBackground`, `onAgentMessageBackground`, `agentMessageBorderColor`
- `typingIndicatorDotColor`
- `linkColor`
- `quickReplyBackground`, `onQuickReplyBackground`, `quickReplyBorderColor`
- `postbackBackground`, `onPostbackBackground`, `postbackBorderColor`
- `inputBorderColor`, `inputFieldBorderColor`, `inputBackground`
- `sendButtonBackground`, `onSendButtonBackground`

`agentMessagePadding` is the room in points between the box around a message the channel sent and its content. It defaults to 0.

Shapes are corner radii in points. A number rounds every corner. An object rounds only the corners it names, and the rest stay square.

- `inputShape`
- `userMessageShape`
- `agentMessageShape`
- `imageShape`
- `quickReplyShape`
- `postbackShape`

## Platform differences

Both platforms take the full API. Some options are not drawn on iOS yet and are ignored there until the iOS SDK supports them:

- The theme colors `onBackground`, `linkColor`, `postback*` and `inputFieldBorderColor`.
- Every theme shape except `inputShape`, `quickReplyShape` and `agentMessageShape`.
