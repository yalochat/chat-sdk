# Yalo Chat SDK — Android

A Kotlin-native Android library that embeds the Yalo Chat interface into any Android app. No Flutter runtime required.

---

## Table of contents

1. [Requirements](#requirements)
2. [Project structure](#project-structure)
3. [Building the SDK](#building-the-sdk)
4. [Running the demo app](#running-the-demo-app)
   - [Android Studio](#android-studio)
   - [Physical device via USB](#physical-device-via-usb)
5. [How the SDK works](#how-the-sdk-works)
6. [Integrating into your app](#integrating-into-your-app)
7. [Theming and customisation](#theming-and-customisation)

---

## Requirements

| Tool | Minimum version |
|---|---|
| Android Studio | Ladybug 2024.2+ |
| Android Gradle Plugin | 8.7+ |
| Kotlin | 2.0.21 |
| Min SDK (library) | API 21 (Android 5.0) |
| Min SDK (demo app) | API 23 (Android 6.0) |
| Target SDK | API 35 |

---

## Project structure

```
android-sdk/
├── sdk/        ← The library module. This is what you ship to consumers.
└── app/        ← Demo app. Integration test harness — not production code.
```

---

## Building the SDK

### 1. Clone and open

```bash
git clone https://github.com/yalochat/chat-sdk.git
cd chat-sdk/android-sdk
```

Open the `android-sdk/` directory in Android Studio (**File → Open**).

### 2. Set up credentials

The demo app needs real Yalo API credentials to connect to a backend. Copy the example file and fill in your values:

```bash
cp local.properties.example local.properties
```

Edit `local.properties`:

```properties
sdk.dir=/path/to/your/Android/sdk   # set automatically by Android Studio

yalo.apiBaseUrl=https://your-yalo-api-base-url
yalo.channelName=your-channel-name
yalo.channelId=your-channel-id
yalo.organizationId=your-organization-id
```

> `local.properties` is gitignored — credentials are never committed.

### 3. Build the SDK library

```bash
./gradlew :sdk:assembleRelease
```

The output `.aar` is at `sdk/build/outputs/aar/sdk-release.aar`.

To run all unit tests:

```bash
./gradlew :sdk:test
```

---

## Running the demo app

### Android Studio

1. Open the project in Android Studio.
2. Make sure `local.properties` is filled in (see above).
3. Select the **app** run configuration from the toolbar.
4. Choose an emulator (API 23+) or a connected device, then click **Run ▶**.

Android Studio will build the `:sdk` module automatically before launching the app.

### Physical device via USB

1. Enable **Developer options** on your device: go to **Settings → About phone** and tap **Build number** seven times.
2. Enable **USB debugging** inside Developer options.
3. Connect your device via USB and accept the prompt on the device.
4. Verify Android Studio sees the device, then click **Run ▶** — or from the terminal:

```bash
./gradlew :app:installDebug
```

The app installs and launches automatically.

---

## How the SDK works

From a consumer perspective the SDK has a single entry point: `YaloChat.init()`.

```
Your app
  └── calls YaloChat.init(config)
        └── SDK sets up networking, local persistence, and the ViewModel layer
              └── You call ChatScreen() anywhere in your Compose UI
                    └── Full chat interface renders — messages, input, audio, images
```

**Message flow:**
- Outgoing messages are inserted locally first (optimistic UI) and then sent to the Yalo backend over HTTP.
- Incoming messages are fetched by a background polling loop that runs only while `ChatScreen` is visible. When the screen is dismissed, polling stops automatically.
- Messages are persisted in a local SQLite database via SQLDelight, so they survive process restarts.

**Permissions:**
The SDK requests two runtime permissions on demand — it never asks upfront:
- `CAMERA` — requested when the user taps the camera option in the attachment picker.
- `RECORD_AUDIO` — requested when the user taps the microphone button.

Both denials are handled gracefully; the SDK never crashes on denial.

---

## Integrating into your app

> The `app/` module in this repo is the reference integration. The steps below mirror what `MainActivity` does.

### Step 1 — Add the SDK module

In your project's `settings.gradle.kts`:

```kotlin
include(":sdk")
project(":sdk").projectDir = file("path/to/android-sdk/sdk")
```

In your app's `build.gradle.kts`:

```kotlin
dependencies {
    implementation(project(":sdk"))
}
```

### Step 2 — Initialise the SDK

Call `YaloChat.init()` once before rendering `ChatScreen` — typically in your `Activity.onCreate` or a Hilt module:

```kotlin
YaloChat.init(
    config = YaloChatConfig(
        channelName    = "Support Chat",
        channelId      = "your-channel-id",
        organizationId = "your-organization-id",
    ),
    context = this,
)
```

`YaloChat.init()` is safe to call multiple times — it tears down the previous session before starting a new one.

### Step 3 — Render the chat screen

`ChatScreen` is a standard Jetpack Compose composable. Add it anywhere in your navigation graph:

```kotlin
setContent {
    var showChat by remember { mutableStateOf(false) }

    if (showChat) {
        ChatScreen(onBack = { showChat = false })
    } else {
        // your own UI
        Button(onClick = { showChat = true }) { Text("Open chat") }
    }
}
```

`ChatScreen` accepts several optional parameters:

| Parameter | Type | Description |
|---|---|---|
| `onBack` | `(() -> Unit)?` | If provided, a back arrow appears in the app bar. |
| `showAttachmentButton` | `Boolean` | Show/hide the attachment (image) button. Defaults to `true`. |
| `appBar` | `(@Composable () -> Unit)?` | Replaces the default app bar with a custom composable. |
| `onShopPressed` | `(() -> Unit)?` | Called when the user taps the shop action in a product message. |
| `onCartPressed` | `(() -> Unit)?` | Called when the user taps the cart action in a product message. |

The SDK does not manage its own back stack — navigation is left to the host app.

---

## Theming and customisation

Pass a `ChatTheme` instance to `YaloChatConfig` to control how the chat looks. All properties have sensible defaults (matching the Flutter SDK's built-in light theme), so you only need to override what you want to change.

### Partial override

```kotlin
YaloChat.init(
    config = YaloChatConfig(
        // ... credentials ...
        theme = ChatTheme(
            sendButtonColor       = Color(0xFF00AA00),
            userBubbleColor       = Color(0xFFDCF8C6),
            userMessageTextStyle  = TextStyle(color = Color(0xFF000000)),
            bubbleShape           = RoundedCornerShape(8.dp),
        ),
    ),
    context = this,
)
```

### Inherit from your Material theme

If your app already has a Material 3 colour scheme, derive the chat theme from it automatically.

`MaterialTheme.colorScheme` is only accessible inside a `@Composable` scope. Call `fromMaterialTheme` inside `setContent {}` after your `MaterialTheme` wrapper, then pass the result to `YaloChat.init`:

```kotlin
setContent {
    MaterialTheme(colorScheme = myColorScheme) {
        val chatTheme = ChatTheme.fromMaterialTheme(MaterialTheme.colorScheme)

        YaloChat.init(
            config = YaloChatConfig(
                // ... credentials ...
                theme = chatTheme,
            ),
            context = this@MainActivity,
        )

        ChatScreen()
    }
}
```

If you initialise the SDK in `Activity.onCreate` before `setContent`, construct the `ColorScheme` directly instead:

```kotlin
YaloChat.init(
    config = YaloChatConfig(
        // ... credentials ...
        theme = ChatTheme.fromMaterialTheme(
            lightColorScheme(primary = Color(0xFF6650A4))
        ),
    ),
    context = this,
)
```

This maps Material colour slots (primary, surface, outline, etc.) to their ChatTheme equivalents using the same mapping as the Flutter SDK's `ChatTheme.fromThemeData`.

### Available properties

| Category | Properties |
|---|---|
| **Colors** | `backgroundColor`, `appBarBackgroundColor`, `userBubbleColor`, `agentBubbleColor`, `sendButtonColor`, `waveColor`, `inputTextFieldColor`, `inputTextFieldBorderColor`, `actionIconColor`, `cancelRecordingIconColor`, `closeModalIconColor`, `playAudioIconColor`, `pauseAudioIconColor`, `attachIconColor`, `imagePlaceholderBackgroundColor` |
| **Text styles** | `userMessageTextStyle`, `assistantMessageTextStyle`, `hintTextStyle`, `timerTextStyle`, `modalHeaderStyle` |
| **Shape** | `bubbleShape` — corner radius of message bubbles |
| **Icons** | `sendButtonIcon`, `recordAudioIcon`, `attachIcon`, `playAudioIcon`, `pauseAudioIcon`, `cancelRecordingIcon`, `closeModalIcon` |

All `TextStyle` overrides are merged with the base Material typography — you only need to specify the properties you want to change (e.g., just `color`).

All icon properties accept any `ImageVector`, so you can substitute your own icon set.
