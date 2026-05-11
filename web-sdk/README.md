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

Add the icon font, place a sized container on your page, and initialize the client pointing at that container's id:

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
    <style>
      #yalo-chat {
        width: 400px;
        height: 600px;
      }
    </style>
  </head>
  <body>
    <div id="yalo-chat"></div>

    <script src="https://chat-sdk-staging.yalochat.com/v0.0.1/sdk.js"></script>
    <script>
      var client = new YaloChatSdk.YaloChatClient({
        channelId: 'your-channel-id',
        organizationId: 'your-organization-id',
        channelName: 'Chat Demo',
        target: 'yalo-chat',
      });
      client.init();
      client.open();
    </script>
  </body>
</html>
```

`target` is the `id` of an HTML element on the page. The chat renders inside that element and fills it. You own the container's size and position, so the SDK does not impose floating-popup behavior, anchors, or click handlers.

The chat is hidden until you call `client.open()`. Use `client.close()` to hide it.

### Floating popup pattern

If you want a classic FAB-and-popup, wrap the chat container and a toggle button in a shared parent. Putting the size on `yalo-chat-window` (rather than the container `div`) lets the container collapse to zero when the chat is hidden, so the FAB sits at the corner alone until the user opens the chat:

```html
<style>
  .chat-widget {
    position: fixed;
    bottom: 24px;
    right: 24px;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 8px;
    z-index: 1000;
  }
  yalo-chat-window {
    --yalo-chat-width: 400px;
    --yalo-chat-height: 600px;
  }
</style>

<div class="chat-widget">
  <div id="yalo-chat"></div>
  <button type="button" id="chat-fab">Chat with us</button>
</div>

<script>
  var client = new YaloChatSdk.YaloChatClient({
    channelId: 'your-channel-id',
    organizationId: 'your-organization-id',
    channelName: 'Support',
    target: 'yalo-chat',
  });
  client.init();

  document.getElementById('chat-fab').addEventListener('click', () => {
    if (client.chatWindowEl?.open) {
      client.close();
    } else {
      client.open();
    }
  });
</script>
```

The chat container is listed first inside `.chat-widget` so column-flex places it above the FAB. When `yalo-chat-window` is hidden, the wrapper collapses around the button alone; when open, the chat appears above the button.

## Configuration

| Property             | Type       | Required | Description                                   |
|----------------------|------------|----------|-----------------------------------------------|
| `channelId`          | `string`   | Yes      | Your channel identifier                       |
| `organizationId`     | `string`   | Yes      | Your organization identifier                  |
| `channelName`        | `string`   | Yes      | Name displayed in the chat header             |
| `target`             | `string`   | Yes      | ID of the HTML element the chat renders inside |
| `image`              | `string`   | No       | URL for the channel avatar image              |
| `locale`             | `string`   | No       | Locale for the chat UI (e.g. `"es"`, `"en"`)  |
| `icons`              | `SdkIcons` | No       | Custom icon overrides (see below)             |
| `audioWaveformColor` | `string`   | No       | Color for the audio waveform visualization    |
| `userId`             | `string`   | No       | Your own user identifier. When provided, the chat session is linked to your user. |
| `openContext`        | `string`   | No       | Context describing where the chat is being opened from. Can be a structured value such as an SKU like `"123"`, or natural language like `"product page of product 123"`. Fixed for the lifetime of the chat instance. |

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
| `client.init()` | Initializes the chat widget and attaches it inside the target element. The chat starts hidden. |
| `client.open()` | Shows the chat window. Uses the `openContext` from the config. |
| `client.close()` | Hides the chat window. |
| `client.registerCommand(command, callback)` | Registers a callback for a client-to-channel command (see [Commands](doc/commands.md)) |
