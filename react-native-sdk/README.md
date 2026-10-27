# React Native Chat SDK

Yalo React Native Chat SDK lets you drop a chat screen into any React Native app.

The chat is the native Yalo chat: the Android SDK on Android and the iOS SDK on iOS. Both take the same config and the same theme from JavaScript.

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [The Chat component](#the-chat-component)
- [Clearing messages](#clearing-messages)
- [Logging out](#logging-out)
- [Data on the device](#data-on-the-device)
- [Custom commands](#custom-commands)
- [Theming](#theming)
- [Translations](#translations)
- [Platform differences](#platform-differences)

## Requirements

- React Native 0.76 or newer, on the New Architecture or the old one.
- Android 7.0 (API level 24) or newer.
- Android builds need:
  - `compileSdkVersion` 35 or newer.
  - Android Gradle Plugin 8.6 or newer.
  - Kotlin 1.9 or newer.
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
- **`userAuthTokenProvider`** (`() => Promise<string | null | undefined>`): Returns a JSON Web Token (JWT) compliant with [RFC 7519](https://www.rfc-editor.org/rfc/rfc7519), signed by your backend, that proves who the signed-in person is. Use it with channels set up to verify your users. The chat calls it every time it authenticates, so return a fresh token each time. When set, the backend takes the person from the token. You must also set `userId` to the same value as the token's `sub` claim, so each signed-in person keeps their own conversation on the device. If it returns nothing or throws, the chat does not connect.
  - The token should use the claim names from RFC 7519:
    - `sub`: your own id for the user. Keep it stable and unique, and pass the same value as `userId`.
    - `iss`: who issued the token, your backend.
    - `aud`: who the token is for, Yalo.
    - `exp`: when the token expires. Keep it short, a few minutes is enough, since a new one is asked for every time.
    - `iat` (optional): when the token was issued.
    - `jti` (recommended): a unique id for the token. With it, each token can be used only once, so a token that leaks cannot be used again.
  - For profile details such as name, email or phone, use the standard claim names `name`, `email` and `phone_number`.
  ```tsx
  const client = new YaloChatClient({
    channelId: 'your-channel-id',
    organizationId: 'your-organization-id',
    channelName: 'Yalo',
    userId: signedInUser.id, // same value as the token's sub
    userAuthTokenProvider: async () => {
      const response = await fetch('https://my-backend.example.com/yalo-token');
      return (await response.json()).token;
    },
  });
  ```
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
- **`hideFeedbackButtons`** (`boolean`): Leaves the thumbs up and thumbs down out from under the channel's replies, so nobody can rate them. Defaults to `false`, which shows them.
- **`texts`** (`YaloChatTexts`): Your own copy for built-in strings, such as `inputPlaceholder`. Defaults to none, which keeps the built-in translations. See [Translations](doc/translations.md).

The config is read when the chat is shown. To change it, create a new client.

## The Chat component

Props:

- **`client`** (`YaloChatClient`): The conversation to show.
- **`theme`** (`ChatTheme`): Colors and shapes. Leave it out to keep the platform default. See [Theming](doc/theming.md).
- **`avatar`** (`ImageURISource | ImageRequireSource`): An image drawn as a circle beside the channel name. With `welcomeMessageType` set to `verticalQuickReplies`, it is also drawn centered above the welcome message, until the person sends something. Takes the same sources as `Image`, a remote URL or a bundled image. Nothing is drawn when you leave it out.
- **`onBack`** (`() => void`): Shows a back button in the header that calls it. Leave it out when the chat is not something the person closes.
- **`style`**: The chat fills the space it is given, `flex: 1` by default.

The chat leaves safe areas and the keyboard to your app, so wrap it in whatever your app already uses for them.

```tsx
<Chat
  client={client}
  avatar={{ uri: 'https://example.com/logo.png' }}
  onBack={() => navigation.goBack()}
/>
```

A bundled image works too:

```tsx
<Chat client={client} avatar={require('./logo.png')} />
```

## Clearing messages

Call `clearMessages()` to delete every message stored on the device.

```tsx
await client.clearMessages();
```

Notes:

- It deletes the messages of every conversation, whatever client or `sessionMode` they came from.
- It works whether or not a chat is on screen. The messages are deleted by the time the promise resolves.
- Every chat on screen empties and the channel greets the person again, as in a new conversation.
- The person stays the same to the channel. To start over as a new person, use `logout()`.

## Logging out

Call `logout()` when the person logs out of your app.

```tsx
await client.logout();
```

Notes:

- It deletes every message and every session stored on the device, of every conversation.
- It works whether or not a chat is on screen. Everything is deleted by the time the promise resolves.
- Every chat on screen empties and connects again as a new person, and the channel greets them.

## Data on the device

- Messages, pictures and voice notes are kept in the app's own storage.
- The access and refresh tokens are always stored encrypted:
  - On Android, with a key kept in the Android Keystore that never leaves the device.
  - On iOS, in the Keychain. They can only be read once the device has been unlocked after a restart, and they never leave the device, not even in a backup.
- `clearMessages()` and `logout()` delete them. See [Clearing messages](#clearing-messages) and [Logging out](#logging-out).

## Custom commands

The channel can ask your app to run something and wait for a reply. Register a handler on the client under a command id of your choice. When the channel sends a request with that id, the SDK runs your handler with the request payload and sends what it returns back to the channel.

```tsx
client.registerCommand('refreshCatalog', async (payload) => {
  // payload: the string the channel sent
  const { region } = JSON.parse(payload);
  await reloadCatalogFor(region);
  return JSON.stringify({ status: 'reloaded' });
});
```

Notes:

- The handler can be synchronous or return a promise. The SDK waits for it before replying.
- You can register commands before or after the `Chat` is shown.
- If the handler returns nothing, the response payload is an empty string.
- You choose the command id. The channel runs your handler by sending a custom command request with the same id.
- The handler only runs while a chat is open, since that is when the SDK is connected.
- If the handler throws or rejects, the SDK replies with an error status and an empty payload.
- When the channel sends a command id with no registered handler, the SDK logs a warning and sends no response.
- Registering the same id again replaces its handler.

### Returning the cart

`getCart` and `updateCartProduct` are built-in command ids for the cart. Their handlers get and return typed objects instead of strings.

```tsx
client.registerCommand('getCart', async ({ cursor, pageSize }) => {
  const products = await loadCart(cursor, pageSize);
  return {
    products,
    // Optional. Include it to support pagination.
    pageInfo: { pageSize: 20, nextCursor: 'page-2' },
  };
});

client.registerCommand('updateCartProduct', async ({ sku, units, subunits }) => {
  await setCartQuantity(sku, units, subunits);
});
```

- `getCart` receives `{ cursor?, pageSize? }` and returns `{ products, pageInfo? }`. The `CartProduct` and `CartPageInfo` types list every field.
- `updateCartProduct` receives `{ sku, units, subunits? }`. `units` and `subunits` are the totals after the change.
- If either handler throws or rejects, the SDK replies with an error status.

## Theming

The chat follows the platform colors and the device light and dark mode with no setup. Pass a `theme` to `Chat` to override only what you need. Every value is optional.

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

See [Theming](doc/theming.md) for every property, its default on each platform, and a full example.

## Translations

The chat ships translated into every supported language and follows the device language. See [Translations](doc/translations.md) for the list and for how to replace a string with your own copy.

## Platform differences

Both platforms take the full API. Some options are not drawn on iOS yet and are ignored there until the iOS SDK supports them:

- The theme colors `onBackground`, `linkColor` and `inputFieldBorderColor`.
- The theme shapes `imageShape` and `postbackShape`.
