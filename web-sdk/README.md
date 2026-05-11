# Webchat SDK

Yalo Webchat SDK lets you embed a chat widget into any website with a single script tag.

## Prerequisites

The SDK uses [Material Symbols Outlined](https://fonts.google.com/icons) for its default icons. Add the following stylesheet to your page's `<head>`:

```html
<link
  href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&icon_names=add,arrow_forward,close,description,error,mic,pause,play_arrow,send,stop"
  rel="stylesheet"
/>
```

If you provide custom icons for every icon key via the `icons` config option, this stylesheet is not needed.

## Quick start

Add the icon font, the SDK script, and initialize the client:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Website</title>
    <link
      href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&icon_names=add,arrow_forward,close,description,error,mic,pause,play_arrow,send,stop"
      rel="stylesheet"
    />
  </head>
  <body>
    <!-- The button or element the chat widget attaches to -->
    <button type="button" id="yalo-chat">Open chat</button>

    <script src="https://chat-sdk-staging.yalochat.com/v0.0.1/sdk.js"></script>
    <script>
      var client = new YaloChatSdk.YaloChatClient({
        channelId: 'your-channel-id',
        organizationId: 'your-organization-id',
        channelName: 'Chat Demo',
        target: 'yalo-chat',
      });
      client.init();
    </script>
  </body>
</html>
```

`target` is the `id` of an HTML element on the page. The chat window will render next to that element.


## Configuration

| Property             | Type       | Required | Description                                   |
|----------------------|------------|----------|-----------------------------------------------|
| `channelId`          | `string`   | Yes      | Your channel identifier                       |
| `organizationId`     | `string`   | Yes      | Your organization identifier                  |
| `channelName`        | `string`   | Yes      | Name displayed in the chat header             |
| `target`             | `string`   | Yes      | ID of the HTML element the widget attaches to |
| `image`              | `string`   | No       | URL for the channel avatar image              |
| `locale`             | `string`   | No       | Locale for the chat UI (e.g. `"es"`, `"en"`)  |
| `icons`              | `SdkIcons` | No       | Custom icon overrides (see below)             |
| `audioWaveformColor` | `string`   | No       | Color for the audio waveform visualization    |
| `userId`             | `string`   | No       | Your own user identifier. When provided, the chat session is linked to your user. |

### Custom icons

The SDK uses Material Symbols Outlined by default (loaded via the Google Fonts stylesheet above). You can override any or all icons by passing an `icons` object with raw SVG strings:

```js
var client = new YaloChatSdk.YaloChatClient({
  channelId: 'your-channel-id',
  organizationId: 'your-organization-id',
  channelName: 'Support',
  target: 'yalo-chat',
  icons: {
    close: '<svg>...</svg>',
    send: '<svg>...</svg>',
  },
});
```

Available icon keys: `close`, `send`, `mic`, `attachment`, `play`, `pause`, `document`, `arrowForward`, `error`.

## Theming

The widget can be fully customized with CSS custom properties. See the [Theming API](doc/theming.md) for the complete list of variables.

## Methods

| Method | Description |
|--------|-------------|
| `client.init()` | Initializes the chat widget and attaches it to the target element |
| `client.open(openContext?)` | Opens the chat window. Accepts an optional `openContext` string describing where the chat is being opened from. It can be a structured value such as an SKU like `"123"`, or natural language like `"product page of product 123"` |
| `client.close()` | Closes the chat window |
| `client.registerCommand(command, callback)` | Registers a callback for a client-to-channel command (see [Commands](doc/commands.md)) |

## Full example

```html
<link
  href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&icon_names=add,arrow_forward,close,description,error,mic,pause,play_arrow,send,stop"
  rel="stylesheet"
/>

<button type="button" id="support-chat">Need help?</button>

<script src="https://chat-sdk-staging.yalochat.com/v0.0.1/sdk.js"></script>
<script>
  var client = new YaloChatSdk.YaloChatClient({
    channelId: 'your-channel-id',
    organizationId: 'your-organization-id',
    channelName: 'Support',
    target: 'support-chat',
    image: '/avatar.png',
    locale: 'es',
  });
  client.init();

  // Optionally open the chat automatically
  client.open();
</script>
```
