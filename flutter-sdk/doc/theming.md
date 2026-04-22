# Theming

The `ChatTheme` class controls all visual aspects of the chat widget, including colors, text styles, and icons. Every property has a built-in default, so the widget renders correctly without any overrides.

## Basic usage

Pass a `ChatTheme` to the `Chat` widget:

```dart
Chat(
  client: client,
  theme: ChatTheme(
    sendButtonColor: Colors.deepPurple,
    appBarBackgroundColor: Colors.deepPurple,
    waveColor: Colors.deepPurple,
  ),
);
```

## Using your existing ThemeData

If your app already has a `ThemeData`, create a `ChatTheme` from it:

```dart
ChatTheme.fromThemeData(Theme.of(context));
```

You can merge `ThemeData` with a custom `ChatTheme` by passing a base theme as a second parameter. The base theme values are used first, then `ThemeData` colors override the matching properties:

```dart
ChatTheme.fromThemeData(
  Theme.of(context),
  ChatTheme(
    chatIconImage: const AssetImage('assets/images/my-icon.png'),
  ),
);
```

## Color properties

### Window

| Property | Type | Description |
|----------|------|-------------|
| `backgroundColor` | `Color` | Background color of the main chat window. |
| `cardBackgroundColor` | `Color` | Background color for product cards. |
| `cardBorderColor` | `Color` | Border color for product cards. |

### Header

| Property | Type | Description |
|----------|------|-------------|
| `appBarBackgroundColor` | `Color` | Background color of the chat header bar. |
| `actionIconColor` | `Color` | Color of action icons in the header. |

### Messages

| Property | Type | Description |
|----------|------|-------------|
| `userMessageColor` | `Color` | Background color of user message bubbles. |
| `messageFooterColor` | `Color` | Color of the footer text below messages. |

### Text input

| Property | Type | Description |
|----------|------|-------------|
| `inputTextFieldColor` | `Color` | Background color of the message input field. |
| `inputTextFieldBorderColor` | `Color` | Border color of the message input field. |
| `attachmentPickerBackgroundColor` | `Color` | Background color of the attachment picker panel. |

### Buttons

| Property | Type | Description |
|----------|------|-------------|
| `sendButtonColor` | `Color` | Background color of the send button. |
| `sendButtonForegroundColor` | `Color` | Icon color inside the send button. |
| `pickerButtonBorderColor` | `Color` | Border color of attachment picker option buttons. |

### Quick replies

| Property | Type | Description |
|----------|------|-------------|
| `quickReplyColor` | `Color` | Background color of quick reply chips. |
| `quickReplyBorderColor` | `Color` | Border color of quick reply chips. |

### CTA messages

| Property | Type | Description |
|----------|------|-------------|
| `ctaButtonColor` | `Color` | Background color of CTA buttons. |
| `ctaButtonBorderColor` | `Color` | Border color of CTA buttons. |
| `ctaButtonForegroundColor` | `Color` | Text color of CTA buttons. |

### Button messages

| Property | Type | Description |
|----------|------|-------------|
| `buttonsMessageButtonColor` | `Color` | Background color of message buttons. |
| `buttonsMessageButtonBorderColor` | `Color` | Border color of message buttons. |
| `buttonsMessageButtonForegroundColor` | `Color` | Text color of message buttons. |

### Voice and audio

| Property | Type | Description |
|----------|------|-------------|
| `waveColor` | `Color` | Color of the audio waveform bars. |
| `cancelRecordingIconColor` | `Color` | Color of the cancel button while recording. |
| `playAudioIconColor` | `Color` | Color of the play button on voice messages. |
| `pauseAudioIconColor` | `Color` | Color of the pause button on voice messages. |

### Product cards

| Property | Type | Description |
|----------|------|-------------|
| `currencyIconColor` | `Color` | Color of the currency icon on product cards. |
| `numericControlIconColor` | `Color` | Color of the +/- quantity control icons. |
| `imagePlaceholderBackgroundColor` | `Color` | Background color of image placeholders. |
| `imagePlaceholderIconColor` | `Color` | Icon color inside image placeholders. |

### Product pricing

| Property | Type | Description |
|----------|------|-------------|
| `productPriceBackgroundColor` | `Color` | Background color of the price pill. |
| `pricePerSubunitColor` | `Color` | Color of the per-subunit price text. |

### Attachment icons

| Property | Type | Description |
|----------|------|-------------|
| `attachIconColor` | `Color` | Color of the attachment button icon. |
| `cameraIconColor` | `Color` | Color of the camera option icon. |
| `galleryIconColor` | `Color` | Color of the gallery option icon. |
| `trashIconColor` | `Color` | Color of the delete icon. |
| `closeModalIconColor` | `Color` | Color of the close icon in modals. |

## Text style properties

| Property | Type | Description |
|----------|------|-------------|
| `userMessageTextStyle` | `TextStyle` | Style for text in user message bubbles. |
| `assistantMessageTextStyle` | `TextStyle` | Style for text in assistant message bubbles. |
| `hintTextStyle` | `TextStyle` | Style for the input field placeholder text. |
| `timerTextStyle` | `TextStyle` | Style for the recording timer text. |
| `modalHeaderStyle` | `TextStyle` | Style for modal header text. |
| `quickReplyStyle` | `TextStyle` | Style for quick reply chip text. |
| `productTitleStyle` | `TextStyle` | Style for product card titles. |
| `productSubunitsStyle` | `TextStyle` | Style for the subunits label on products. |
| `productPriceStyle` | `TextStyle` | Style for the product price. |
| `productSalePriceStrikeStyle` | `TextStyle` | Style for the struck-through original price. |
| `pricePerSubunitStyle` | `TextStyle` | Style for the per-subunit price text. |
| `expandControlsStyle` | `TextStyle` | Style for the "Show more/less" toggle text. |
| `messageHeaderStyle` | `TextStyle` | Style for the header text in button/CTA messages. |
| `messageFooterStyle` | `TextStyle` | Style for the footer text in button/CTA messages. |
| `ctaButtonTextStyle` | `TextStyle` | Style for CTA button text. |
| `buttonsMessageButtonTextStyle` | `TextStyle` | Style for button message text. |

## Icon properties

All icon properties accept an `IconData` value. The SDK uses Material Icons by default.

| Property | Default | Description |
|----------|---------|-------------|
| `chatIconImage` | `null` | Custom image for the chat header avatar (`ImageProvider`). |
| `sendButtonIcon` | `Icons.send_outlined` | Icon for the send button. |
| `recordAudioIcon` | `Icons.mic_none` | Icon for the record audio button. |
| `shopIcon` | `Icons.storefront` | Icon for the shop indicator. |
| `cartIcon` | `Icons.shopping_cart_outlined` | Icon for the cart indicator. |
| `cancelRecordingIcon` | `Icons.close` | Icon for cancelling a recording. |
| `closeModalIcon` | `Icons.close` | Icon for closing modals. |
| `playAudioIcon` | `Icons.play_arrow_rounded` | Icon for the audio play button. |
| `pauseAudioIcon` | `Icons.pause_rounded` | Icon for the audio pause button. |
| `attachIcon` | `Icons.add` | Icon for the attachment button. |
| `cameraIcon` | `Icons.photo_camera` | Icon for the camera option. |
| `galleryIcon` | `Icons.insert_photo` | Icon for the gallery option. |
| `trashIcon` | `Icons.delete_outline` | Icon for the delete action. |
| `imagePlaceHolderIcon` | `Icons.image` | Icon shown in image placeholders. |
| `currencyIcon` | `Icons.toll` | Icon for the currency indicator. |
| `addIcon` | `Icons.add` | Icon for the quantity increment button. |
| `removeIcon` | `Icons.remove` | Icon for the quantity decrement button. |
| `ctaArrowForwardIcon` | `Icons.arrow_forward` | Icon for the CTA forward arrow. |

## Full theming example

```dart
Chat(
  client: client,
  theme: ChatTheme(
    // Brand colors
    sendButtonColor: Color(0xFF6200EE),
    sendButtonForegroundColor: Colors.white,
    appBarBackgroundColor: Color(0xFF6200EE),
    actionIconColor: Colors.white,

    // Messages
    userMessageColor: Color(0xFFF5F5F5),
    userMessageTextStyle: TextStyle(color: Colors.black87),
    assistantMessageTextStyle: TextStyle(color: Colors.black87, fontSize: 14),

    // Audio
    waveColor: Color(0xFF6200EE),

    // Product cards
    productPriceBackgroundColor: Color(0xFFEDE7F6),
    numericControlIconColor: Color(0xFF6200EE),

    // Custom icons
    sendButtonIcon: Icons.arrow_upward,
    chatIconImage: AssetImage('assets/images/my-avatar.png'),
  ),
);
```
