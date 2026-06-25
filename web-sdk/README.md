# Webchat SDK

Yalo Webchat SDK lets you embed a chat widget into any website with a single script tag.

## Table of contents

- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
  - [Script URL](#script-url)
    - [Subresource Integrity](#subresource-integrity)
    - [Content Security Policy](#content-security-policy)
  - [Floating popup pattern](#floating-popup-pattern)
  - [Open via queue (`window.yaloOpen`)](#open-via-queue-windowyaloopen)
- [Configuration](#configuration)
- [Theming](#theming)
- [Methods](#methods)

## Prerequisites

The SDK uses [Material Symbols Outlined](https://fonts.google.com/icons) for its default icons. Add the following stylesheet to your page's `<head>`:

```html
<link
  href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&icon_names=add,arrow_forward,check,close,description,error,mic,pause,play_arrow,send,stop"
  rel="stylesheet"
/>
```

You can swap the icon font or any individual glyph through CSS variables. See the [Theming API](doc/theming.md#icons) for the full list.

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
      href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&icon_names=add,arrow_forward,check,close,description,error,mic,pause,play_arrow,send,stop"
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

    <script src="https://chat-sdk.yalochat.com/latest/sdk.js"></script>
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

### Script URL

The example above uses `/latest/sdk.js`, which always serves the most recent release. If you need a stable, reproducible build, pin to a specific version instead:

```html
<script src="https://chat-sdk.yalochat.com/v1.0.0/sdk.js"></script>
```

Replace `v1.0.0` with the version you want to lock to. Available versions are listed on the [GitHub releases page](https://github.com/yalochat/chat-sdk/releases).

#### Subresource Integrity

For pinned versions you can opt into [Subresource Integrity (SRI)](https://developer.mozilla.org/docs/Web/Security/Subresource_Integrity) so the browser refuses to execute the bundle if its bytes do not match the published hash:

```html
<script
  src="https://chat-sdk.yalochat.com/v1.0.0/sdk.js"
  integrity="sha384-REPLACE_WITH_PUBLISHED_HASH"
  crossorigin="anonymous"
></script>
```

The integrity value for each release is published alongside the bundle at `https://chat-sdk.yalochat.com/v{version}/sdk.js.sri`. Fetch it once and paste the contents into the `integrity` attribute.

SRI is not supported on `/latest/sdk.js` because that URL points to a moving target. Pin to a specific version if you need integrity checks.

#### Content Security Policy

If your host page sets a [Content Security Policy](https://developer.mozilla.org/docs/Web/HTTP/Headers/Content-Security-Policy), it must allow the origins the SDK loads from and connects to. A minimal policy that covers the script bundle, the Material Symbols font, the chat backend, and inline media playback looks like this:

```
Content-Security-Policy:
  script-src  'self' https://chat-sdk.yalochat.com;
  style-src   'self' https://fonts.googleapis.com;
  font-src    'self' https://fonts.gstatic.com;
  img-src     'self' blob: https://storage.googleapis.com;
  media-src   'self' blob:;
  connect-src 'self' https://api2-ww-us-001.yalochat.com wss://api2-ww-us-001.yalochat.com;
```

The SDK keeps a live connection over both `https://` and `wss://` against the same host, so `connect-src` must include both schemes. The `blob:` entries are required so the chat can display image, audio, and video messages.

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

  var isOpen = false;
  client.init({
    onOpen: () => {
      isOpen = true;
    },
    onClose: () => {
      isOpen = false;
    },
  });

  document.getElementById('chat-fab').addEventListener('click', () => {
    if (isOpen) {
      client.close();
    } else {
      client.open();
    }
  });
</script>
```

The chat container is listed first inside `.chat-widget` so column-flex places it above the FAB. When `yalo-chat-window` is hidden, the wrapper collapses around the button alone; when open, the chat appears above the button.

### Open via queue (`window.yaloOpen`)

If you can't guarantee the order in which the SDK script and your configuration script run (for example, when loading the SDK through a tag manager or another async loader), you can declare a `window.yaloOpen` array and push configuration objects to it. The SDK drains any items already in the array when it loads, and opens a chat window for any item pushed afterwards.

```html
<div id="yalo-chat"></div>

<script>
  window.yaloOpen = window.yaloOpen || [];
  window.yaloOpen.push({
    channelId: 'your-channel-id',
    organizationId: 'your-organization-id',
    channelName: 'Support',
    target: 'yalo-chat',
  });
</script>

<script src="https://chat-sdk.yalochat.com/latest/sdk.js"></script>
```

After the SDK loads, `window.yaloOpen.push(config)` keeps working and opens a new chat window for each pushed configuration. Each pushed configuration creates and opens an independent `YaloChatClient` instance.

Each pushed configuration also accepts the `onOpen` and `onClose` callbacks that `client.init(options)` supports. Add them alongside the configuration properties and the SDK forwards them to `init`:

```html
<script>
  window.yaloOpen = window.yaloOpen || [];
  window.yaloOpen.push({
    channelId: 'your-channel-id',
    organizationId: 'your-organization-id',
    channelName: 'Support',
    target: 'yalo-chat',
    onOpen: () => console.log('chat opened'),
    onClose: () => console.log('chat closed'),
  });
</script>
```

The target element referenced by `config.target` must exist in the DOM at the time the configuration is processed. Place the script after the target element or wrap the push in your own `DOMContentLoaded` handler if needed.

## Configuration

Required properties:

- **`channelId`** (`string`): Your channel identifier.
- **`organizationId`** (`string`): Your organization identifier.
- **`channelName`** (`string`): Name displayed in the chat header.
- **`target`** (`string`): ID of the HTML element the chat renders inside.

Optional properties:

- **`image`** (`string`): URL for the channel avatar image.
- **`locale`** (`string`): Locale for the chat UI (e.g. `"es"`, `"en"`).
- **`audioWaveformColor`** (`string`): Color for the audio waveform visualization.
- **`userId`** (`string`): Your own user identifier. When provided, the chat session is linked to your user.
- **`openContext`** (`object`): Context describing where the chat is being opened from. Provide any key/value pairs you want the channel to receive, for example `{ source: 'product-page', sku: '123' }`. Fixed for the lifetime of the chat instance.
- **`hideCloseButton`** (`boolean`): When `true`, the close button is not rendered in the chat header. Useful when the chat is embedded full-screen or hosted in a surface that already provides its own close affordance. You can also hide it from CSS with the `--yalo-chat-close-btn-display: none` variable.
- **`hideHeader`** (`boolean`): When `true`, the chat header is not rendered. Use this when the surrounding page already shows the channel name and avatar, or when embedding the chat in a layout that supplies its own header. You can also hide it from CSS with the `--yalo-chat-header-display: none` variable.
- **`hideAttachmentButton`** (`boolean`): When `true`, the file attachment button is not rendered in the footer. Users cannot send images or files from the chat.
- **`hideVoiceButton`** (`boolean`): When `true`, the microphone affordance is removed: the action button always shows the send icon and only sends text. Users cannot record or send voice messages.
- **`sessionMode`** (`"shared" | "perContext" | "ephemeral"`): Controls how the conversation is scoped and whether it is remembered between visits.
  - `"shared"` (default): the conversation is remembered across visits on the same browser, and `openContext` does not affect which conversation is shown.
  - `"perContext"`: the conversation is remembered but scoped by `openContext`. Two tabs opened with the same `openContext` share a conversation, while different `openContext` values start a fresh conversation.
  - `"ephemeral"`: the conversation is not remembered. It starts fresh each time and nothing is left behind once the page is closed.
- **`logLevel`** (`"debug" | "info" | "warn" | "error"`): Controls how verbose the chat is in the browser console. Defaults to `"warn"`, which keeps the console quiet outside of warnings and errors. Raise to `"debug"` or `"info"` when investigating integration issues.

## Theming

The widget can be fully customized with CSS custom properties. See the [Theming API](doc/theming.md) for the complete list of variables.

## Methods

- **`client.init(options?)`**: Initializes the chat widget and attaches it inside the target element. The chat starts hidden. `options.onOpen` runs every time the chat opens, `options.onClose` runs every time it closes (whether the user pressed the close button or your code called `close()`).
- **`client.open()`**: Shows the chat window. Uses the `openContext` from the config.
- **`client.close()`**: Hides the chat window.
- **`client.registerCommand(command, callback)`**: Registers a callback for a client-to-channel command (see [Commands](doc/commands.md)).
- **`client.onCommand(commandId, handler)`**: Registers a handler for a channel-to-client command. The handler runs when the channel requests that command id, and its return value is sent back as the response (see [Commands](doc/commands.md)).
- **`client.dispose()`**: Removes the chat widget from the page and releases its resources. Call this before navigating away in single page apps. The client can be re-initialized with `init()` after disposal.
