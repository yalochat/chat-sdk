# Android Chat SDK

Yalo Android Chat SDK lets you drop a chat screen into any Jetpack Compose app.

The chat renders inside the space you give it, follows your app theme out of the box, and speaks every language the SDK ships with.

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
- [The Chat composable](#the-chat-composable)
  - [Sizing and window insets](#sizing-and-window-insets)
  - [Avatar](#avatar)
  - [Back button](#back-button)
- [The ChatView view](#the-chatview-view)
- [Message formatting](#message-formatting)
- [Voice messages](#voice-messages)
  - [The microphone permission](#the-microphone-permission)
  - [Turning voice messages off](#turning-voice-messages-off)
- [Image messages](#image-messages)
  - [Turning image messages off](#turning-image-messages-off)
- [Feedback buttons](#feedback-buttons)
- [Theming](#theming)
- [Logging](#logging)
- [Translations](#translations)
- [Methods](#methods)
- [Custom commands](#custom-commands)
  - [Returning the cart](#returning-the-cart)
  - [Updating a cart product](#updating-a-cart-product)

## Requirements

- Android 7.0 (API level 24) or newer.
- `compileSdk` 35 or newer.
- Android Gradle Plugin 8.6 or newer.
- Kotlin 1.9 or newer.
- Java 11 or newer for compilation.
- The chat is a Jetpack Compose composable. Screens without Compose can use [`ChatView`](#the-chatview-view) instead.

## Installation

The SDK is published to Maven Central. Make sure `mavenCentral()` is in your repositories, then add the dependency to your app module:

```kotlin
// app/build.gradle.kts
dependencies {
    implementation("ai.yalo.chat:chat-android-sdk:0.1.0")
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
- **`userAuthTokenProvider`** (`(suspend () -> String?)?`): Returns a JSON Web Token (JWT) compliant with [RFC 7519](https://www.rfc-editor.org/rfc/rfc7519), signed by your backend, that proves who the signed-in person is. Use it with channels set up to verify your users. The SDK calls it every time it authenticates, so return a fresh token each time. When set, the person comes from the token and `userId` no longer decides who they are. If it returns `null`, a blank string or throws, the chat does not connect. Defaults to `null`.
  ```kotlin
  YaloChatClientConfig(
      channelId = "your-channel-id",
      organizationId = "your-organization-id",
      channelName = "Yalo",
      userAuthTokenProvider = { myBackend.yaloToken() },
  )
  ```
- **`logLevel`** (`LogLevel`): How much the SDK says about itself in logcat. Defaults to `LogLevel.Warn`, which keeps it quiet outside of warnings and errors. Raise it to `LogLevel.Debug` or `LogLevel.Info` while integrating, or set `LogLevel.Silent` to turn it off entirely. See [Logging](#logging).
- **`quickReplyType`** (`QuickReplyType`): Where the answers a message offers are shown. Defaults to `QuickReplyType.Modal`, which puts them in a bar above the message input. Set `QuickReplyType.Inline` to put them under the message that offered them.
- **`welcomeMessageType`** (`WelcomeMessageType`): How the first message of a conversation is drawn. Defaults to `WelcomeMessageType.None`, which draws it like any other message.
  - `WelcomeMessageType.VerticalQuickReplies`: while the person has not sent anything yet and the channel has said only one thing, that message is shown centered, with the [avatar](#avatar) above it and one quick reply per line under it, whatever `quickReplyType` says. Once the person sends a message, the avatar leaves the conversation and it is drawn as usual.
- **`openContext`** (`Map<String, String>`): What the chat is being opened from, for example the product the person was looking at. Sent to the channel when the chat opens on an empty conversation, so it can speak first. Defaults to no context. See [Open context](#open-context).
- **`sessionMode`** (`SessionMode`): How the conversation is scoped, and whether it is remembered between visits. Defaults to `SessionMode.Shared`, which is one conversation per person, remembered. See [Session modes](#session-modes).
- **`hideVoiceButton`** (`Boolean`): Leaves the microphone out of the message input. Defaults to `false`. Set it to `true` and the send button is always there, and nobody can record a voice message. See [Voice messages](#voice-messages).
- **`hideAttachmentButton`** (`Boolean`): Leaves the plus out of the message input. Defaults to `false`. Set it to `true` and nobody can pick a picture to send. Pictures the channel sends are still shown. See [Image messages](#image-messages).
- **`hideWatermark`** (`Boolean`): Leaves the "By Yalo" line under the channel name out of the header. Defaults to `false`, which shows it. Everything else in the header stays where it is.
- **`hideFeedbackButtons`** (`Boolean`): Leaves the thumbs up and thumbs down out from under the channel's replies. Defaults to `false`, which shows them. See [Feedback buttons](#feedback-buttons).

In the default `SessionMode.Shared`, two chats built from the same `channelId`, `organizationId` and `userId` are the same conversation and show the same messages. The other modes narrow that further. See [Session modes](#session-modes).

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

The context is part of the configuration, so a chat opened from somewhere else needs its own client. By default every context shares one conversation. To give each its own, set `sessionMode` to `SessionMode.PerContext`. See [Session modes](#session-modes).

## Session modes

`sessionMode` decides how a conversation is scoped and whether it is remembered.

```kotlin
private val client = YaloChatClient(
    YaloChatClientConfig(
        channelId = "your-channel-id",
        organizationId = "your-organization-id",
        channelName = "Support",
        sessionMode = SessionMode.Ephemeral,
    ),
)
```

The modes:

- **`SessionMode.Shared`** (default): one conversation per person, remembered until the app's data is cleared. What the chat was opened from makes no difference to which conversation is shown.
- **`SessionMode.PerContext`**: one conversation per `openContext`, remembered the same way. Two chats opened from the same context carry on the same conversation, and a different context starts its own. A chat with no `openContext` behaves like `Shared`.
- **`SessionMode.Ephemeral`**: a new conversation every time, and nothing left behind once it ends.

What to expect from `Ephemeral`:

- Turning the device keeps the conversation, the same way the rest of the screen survives it.
- Starting the app again begins a new conversation. The messages, the token and anything the conversation kept on disk are deleted.
- What a crash or a force stop did not get to delete is deleted the next time the app runs.
- Two chats shown at once are two conversations, even when they were built from the same client.
- An ephemeral chat written inside a loop or a list needs a `key(...)` around it, so two of them are not restored as one.

Each mode is also its own person to the channel, so a conversation scoped by context or by a single visit does not pick up what another one said.

## Clearing messages

Call `clearMessages(context)` to delete every message stored on the device. It is a `suspend` function, and any `Context` will do.

```kotlin
lifecycleScope.launch {
    client.clearMessages(context)
}
```

Notes:

- It deletes the messages of every conversation, whatever client or `sessionMode` they came from, along with the pictures and voice notes they kept on disk.
- It works whether or not a chat is on screen. The messages are deleted by the time it returns.
- Every chat on screen empties and the channel greets the person again, as in a new conversation.
- The person stays the same to the channel. To start over as a new person, use `logout(context)`.

## Logging out

Call `logout(context)` when the person logs out of your app. It is a `suspend` function, and any `Context` will do.

```kotlin
lifecycleScope.launch {
    client.logout(context)
}
```

Notes:

- It deletes every message and every session stored on the device, of every conversation.
- It works whether or not a chat is on screen. Everything is deleted by the time it returns.
- Every chat on screen empties and connects again as a new person, and the channel greets them.

## Data on the device

- Messages, pictures and voice notes are kept in the app's private storage.
- The access and refresh tokens are encrypted before they are stored, with a key kept in the Android Keystore that never leaves the device.
- `clearMessages(context)` and `logout(context)` delete them. See [Clearing messages](#clearing-messages) and [Logging out](#logging-out).

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
- **`avatar`**: Drawn beside the channel name in the header, and centered above the welcome message when `welcomeMessageType` is `VerticalQuickReplies`. Nothing is drawn when you leave it out.
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

## The ChatView view

`ChatView` is the same chat as a classic Android view, for screens that do not use Compose, such as an XML layout or a React Native bridge.

```kotlin
val chatView = ChatView(context).apply {
    client = YaloChatClient(config)
    theme = { default -> default.copy(headerBackground = Color.Red) }
    avatar = { context -> ImageView(context).apply { setImageResource(R.drawable.logo) } }
    onBack = { finish() }
}
setContentView(chatView)
```

- **`client`**: The client holding the configuration for this conversation. Nothing is drawn until you set it.
- **`theme`**: Adjusts the default theme, which follows the system light or dark scheme. Leave it out to keep the default. See [Theming](doc/theming.md).
- **`avatar`**: Creates the view drawn beside the channel name in the header, and centered above the welcome message when `welcomeMessageType` is `VerticalQuickReplies`. It is called once for each place the avatar shows, so return a new view every time. Nothing is drawn unless you set one.
- **`onBack`**: Adds a back button to the header. The header has no back button unless you set one.

The view finds its lifecycle through the window it is attached to, so place it in a `ComponentActivity`, such as an `AppCompatActivity`.

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

## Voice messages

The person records a voice message by tapping the microphone beside the message input. While they speak, the input turns into a waveform with the elapsed time on its left, and the button beside it turns into send:

- Tapping send finishes the recording and puts it in the conversation.
- Tapping the cross in the input throws the recording away and nothing is sent.

Voice messages the channel sends are shown the same way messages the person recorded are: a play button, the shape of the recording, and how long it runs. Tapping play fetches the audio if it is not on the device yet, and tapping again pauses it.

Nothing has to be configured for any of this except the permission below.

### The microphone permission

Recording needs `RECORD_AUDIO`. The SDK does not declare it, so it is never forced on an app that has voice messages turned off. Declare it in your own manifest:

```xml
<manifest>
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
</manifest>
```

The chat asks the person for the permission the first time they tap the microphone, and starts recording as soon as they allow it. Nothing happens if they refuse, or if the permission was never declared.

Recordings the person makes are kept in your app's own files so they can still be played back after they have been sent. They go when the app's data does.

### Turning voice messages off

Set `hideVoiceButton` and the microphone is gone. The send button takes its place permanently and is simply disabled while nothing has been typed:

```kotlin
YaloChatClient(
    YaloChatClientConfig(
        channelId = "your-channel-id",
        organizationId = "your-organization-id",
        channelName = "Support",
        hideVoiceButton = true,
    ),
)
```

Leave `RECORD_AUDIO` out of your manifest as well, and the app never asks for a microphone it does not use. Voice messages the channel sends are still played, because playing one records nothing.

## Image messages

The person sends a picture by tapping the plus beside the message input. That opens the system photo picker, they choose one picture, and it goes into the conversation:

- The picture is in the conversation as soon as it is picked, before it has been anywhere.
- It is sent on its own. A picture and typed text are two messages, not one message with a caption.

Pictures the channel sends are shown the same way, with whatever text came with them underneath. One that is not on the device yet is fetched the first time it is drawn, and asking for it again costs one download.

Nothing has to be configured for any of this. The photo picker runs outside your app and hands the chat only the one picture the person chose, so there is no gallery permission to declare and none to ask for.

Pictures the person sends are copied into your app's own files so they can still be shown after they have been sent. They go when the app's data does.

### Turning image messages off

Set `hideAttachmentButton` and the plus is gone, so nobody can pick a picture:

```kotlin
YaloChatClient(
    YaloChatClientConfig(
        channelId = "your-channel-id",
        organizationId = "your-organization-id",
        channelName = "Support",
        hideAttachmentButton = true,
    ),
)
```

Pictures the channel sends are still shown, because showing one picks nothing.

## Feedback buttons

Each text reply from the channel has a thumbs up and a thumbs down under it, so the person can rate it. They show only after the person sends their first message, so the welcome message has none.

How they work:

- Tapping one rates the reply and leaves that thumb selected.
- Tapping the other one changes the rating.
- Tapping the selected one again takes the rating back.

The rating is sent to the channel and remembered with the conversation, so it is still there when the chat is opened again.

Set `hideFeedbackButtons` to leave them out:

```kotlin
YaloChatClient(
    YaloChatClientConfig(
        channelId = "your-channel-id",
        organizationId = "your-organization-id",
        channelName = "Support",
        hideFeedbackButtons = true,
    ),
)
```

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
- **`client.clearMessages(context)`**: See [Clearing messages](#clearing-messages).
- **`client.logout(context)`**: See [Logging out](#logging-out).
- **`client.registerCommand(command, handler)`**: Runs `handler` when the channel asks for `command`. See [Custom commands](#custom-commands).

## Custom commands

The channel can ask your app to run something and wait for a reply. Register a handler under a command id of your choice. When the channel sends a request with that id, the SDK runs your handler with the request payload and sends what it returns back to the channel.

```kotlin
client.registerCommand("refreshCatalog") { payload ->
    // payload: the string the channel sent
    val region = JSONObject(payload).getString("region")
    catalog.reload(region)
    """{"status":"reloaded"}"""
}
```

Notes:

- The handler is a `suspend` function, so it can call other suspend functions. The SDK waits for it before replying, and each request runs on its own.
- You choose the command id. The channel runs your handler by sending a custom command request with the same id.
- The handler only runs while a chat is open, since that is when the SDK is connected.
- The string you return becomes the response payload. Return an empty string when there is nothing to send back.
- If the handler throws, the SDK replies with an error status and an empty payload.
- When the channel sends a command id with no registered handler, the SDK logs a warning and sends no response.
- Registering the same id again replaces its handler.

### Returning the cart

`getCart` and `updateCartProduct` are built-in command ids for the cart. You register them with `registerCommand` like any other command, and their payloads are JSON.

`getCart` is sent when the channel asks for the products in the cart. Return the page of the cart as JSON.

```kotlin
client.registerCommand("getCart") { payload ->
    // payload: {"cursor":"page-2","pageSize":20}
    val request = JSONObject(payload)
    // Your own cart, turned into the products below as JSON objects.
    val products: List<JSONObject> = cart.page(request.optString("cursor"))
    JSONObject().put("products", JSONArray(products)).toString()
}

client.registerCommand("updateCartProduct") { payload ->
    // payload: {"sku":"WATER-1L","units":2.0}
    val change = JSONObject(payload)
    cart.set(change.getString("sku"), change.getDouble("units"))
    ""
}
```

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
