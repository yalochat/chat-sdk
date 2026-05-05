# Theming

The Webchat SDK exposes CSS custom properties (variables) that let you customize the look and feel of the chat widget without modifying its internals. Set these variables on the `:root` selector or on a parent element wrapping the chat widget.

## Usage

Override any variable in your own stylesheet:

```css
:root {
  --yalo-chat-send-btn-background: #6200ee;
  --yalo-chat-header-background: #6200ee;
  --yalo-chat-header-color: #ffffff;
  --yalo-chat-font: 'Inter', sans-serif;
}
```

Every variable includes a built-in fallback, so the widget renders correctly even if no overrides are provided.

## Variables reference

### Window

```css
:root {
  /* Background color of the main chat window body. */
  --yalo-chat-background: #ffffff;

  /* Border radius applied to the chat window corners.
     Controls how rounded the widget frame appears. */
  --yalo-chat-corner-radius: 12px;

  /* Font family used across the entire chat widget.
     Set this to match your site typography. */
  --yalo-chat-font: sans-serif;
}
```

### Spacing

```css
:root {
  /* Vertical gap between stacked UI elements (messages, sections).
     Increase to give the chat a more spacious layout. */
  --yalo-chat-column-item-space: 8px;

  /* Horizontal gap between inline UI elements (icons, buttons).
     Increase to widen the space between side-by-side items. */
  --yalo-chat-row-item-space: 8px;
}
```

### Header

```css
:root {
  /* Background color of the chat header bar
     where the channel name is displayed. */
  --yalo-chat-header-background: #f1f5fc;

  /* Text color for the channel name and status text in the header. */
  --yalo-chat-header-color: #010101;

  /* Color of the close button icon in the header. */
  --yalo-chat-close-btn-color: #010101;
}
```

### Text input

```css
:root {
  /* Full border shorthand for the message input field.
     Accepts any valid CSS border value (width, style, color). */
  --yalo-chat-input-border: 1px solid #e8e8e8;

  /* Border radius of the message input field.
     The default produces a pill shape.
     Lower values make it more rectangular. */
  --yalo-chat-input-border-radius: 25.5px;

  /* Font size of the text typed into the message input field. */
  --yalo-chat-input-font-size: 16px;
}
```

### Buttons

```css
:root {
  /* Background color of the send button.
     Also used as the accent color for links inside assistant messages. */
  --yalo-chat-send-btn-background: #2207f1;

  /* Icon/text color inside the send button. */
  --yalo-chat-send-btn-color: white;

  /* Color of the attachment (file picker) button next to the input field. */
  --yalo-chat-attachment-button-color: #7c8086;
}
```

### Messages

```css
:root {
  /* Background color of message bubbles sent by the user.
     Assistant message bubbles are transparent by default. */
  --yalo-chat-user-message-background: #f9fafc;

  /* Color of the error icon shown on messages that failed to send. */
  --yalo-chat-user-message-error-color: #a01600;

  /* Text color of the "Not delivered" label
     shown below messages that failed to send. */
  --yalo-chat-user-message-error-text-color: #461a1a;
}
```

### Loading and typing indicators

```css
:root {
  /* Border color of the loading spinner shown while content
     (messages, images, videos) is being fetched. */
  --yalo-chat-spinner-color: #2207f1;

  /* Color of the animated dots displayed as a typing indicator
     when the assistant is composing a response. */
  --yalo-chat-dot-color: #2207f1;
}
```

### Voice and audio

```css
:root {
  /* Color of the audio waveform bars shown while recording
     or playing back a voice message. */
  --yalo-chat-waveform-color: #2207f1;

  /* Color of the play/pause button on voice message bubbles. */
  --yalo-chat-play-button-color: #7c8086;

  /* Color of the close (cancel) button displayed
     on the waveform recorder overlay. */
  --yalo-chat-waveform-close-button-color: #7c8086;

  /* Color of the elapsed-time text displayed
     next to the waveform while recording. */
  --yalo-chat-waveform-timer-color: #7c8086;
}
```

### Attachments

```css
:root {
  /* Color of the file-type icon shown inside attachment message bubbles. */
  --yalo-chat-attachment-icon-color: #7c8086;
}
```

### Assistant messages

```css
:root {
  /* Color of links and link buttons inside assistant messages. */
  --yalo-chat-link-button-color: #2207f1;

  /* Font weight of the optional header rendered above an assistant message body. */
  --yalo-chat-message-header-font-weight: bold;

  /* Text color of the optional footer rendered below an assistant message body. */
  --yalo-chat-message-footer-color: #7c8086;

  /* Font size of the optional footer rendered below an assistant message body. */
  --yalo-chat-message-footer-font-size: 0.75em;
}
```

### Message buttons

Buttons attached to assistant messages, rendered below the body.

```css
:root {
  /* Border color around each button. */
  --yalo-chat-buttons-border-color: #9db1c8;

  /* Gap between buttons. */
  --yalo-chat-buttons-gap: 0.5rem;

  /* Padding inside each button. */
  --yalo-chat-buttons-padding: 0.5rem;

  /* Border radius for each button. */
  --yalo-chat-buttons-border-radius: 0.5rem;

  /* Background color for each button. */
  --yalo-chat-buttons-background: transparent;

  /* Text color for each button. */
  --yalo-chat-buttons-color: #111111;

  /* Font size for button text. */
  --yalo-chat-buttons-font-size: 0.875rem;
}
```

### Product messages

```css
:root {
  /* Background color for product cards. */
  --yalo-chat-product-message-card-background: #ffffff;

  /* Border color for product cards. */
  --yalo-chat-product-message-card-border-color: #dde4ec;

  /* Border radius for product cards. */
  --yalo-chat-product-message-card-radius: 1rem;

  /* Padding inside product cards. */
  --yalo-chat-product-message-card-padding: 1rem;

  /* Gap between product cards. */
  --yalo-chat-product-message-gap: 1rem;

  /* Color of the "Show more/less" toggle button. */
  --yalo-chat-product-message-expand-color: #2207f1;
}
```

### Product cards

```css
:root {
  /* Color of the product title text. */
  --yalo-chat-product-title-color: #111111;

  /* Font size for the product title. */
  --yalo-chat-product-title-size: 1rem;

  /* Color of the subunits label text. */
  --yalo-chat-product-subunits-color: #7c8086;

  /* Font size for the subunits label. */
  --yalo-chat-product-subunits-size: 0.875rem;

  /* Border radius for the product image. */
  --yalo-chat-product-image-radius: 0.125em;

  /* Gap between the product image and product details. */
  --yalo-chat-product-gap: 0.5rem;
}
```

### Product pricing

```css
:root {
  /* Background color of the price pill. */
  --yalo-chat-product-price-background: #eef2f7;

  /* Text color for the product price. */
  --yalo-chat-product-price-color: #111111;

  /* Color of the struck-through original price. */
  --yalo-chat-product-price-strike-color: #7c8086;

  /* Color of the per-subunit price text. */
  --yalo-chat-product-price-per-subunit-color: #7c8086;

  /* Padding inside the price pill. */
  --yalo-chat-product-price-padding: 0.3125em;

  /* Border radius of the price pill. */
  --yalo-chat-product-price-radius: 2.0625em;

  /* Gap between price elements. */
  --yalo-chat-product-price-gap: 0.5em;

  /* Font size for price text. */
  --yalo-chat-product-price-font-size: 0.875rem;
}
```

### Numeric input

```css
:root {
  /* Color of the increment/decrement button icons. */
  --yalo-chat-numeric-icon-color: #334155;

  /* Text color for the numeric input value. */
  --yalo-chat-numeric-text-color: #111111;

  /* Border color for the numeric input field. */
  --yalo-chat-numeric-border-color: #dde4ec;

  /* Border radius for the numeric input field. */
  --yalo-chat-numeric-radius: 0.5rem;

  /* Padding inside the numeric input field. */
  --yalo-chat-numeric-padding: 0.25rem;

  /* Gap between the input and its buttons. */
  --yalo-chat-numeric-gap: 0.5rem;

  /* Font size for the numeric input text. */
  --yalo-chat-numeric-font-size: 0.875rem;
}
```

### Positioning

These variables are set automatically at runtime based on the target element's position. You generally do not need to override them, but you can if you want to place the widget at a fixed location.

```css
:root {
  /* Distance from the bottom edge of the viewport to the chat window. */
  --yalo-chat-inset-bottom: 80px;

  /* Distance from the right edge of the viewport to the chat window. */
  --yalo-chat-inset-right: 24px;
}
```

## Full theming example

```html
<style>
  :root {
    /* Brand colors */
    --yalo-chat-send-btn-background: #6200ee;
    --yalo-chat-send-btn-color: #ffffff;
    --yalo-chat-header-background: #6200ee;
    --yalo-chat-header-color: #ffffff;
    --yalo-chat-close-btn-color: #ffffff;

    /* Typography */
    --yalo-chat-font: 'Inter', sans-serif;
    --yalo-chat-input-font-size: 14px;

    /* Rounder corners */
    --yalo-chat-corner-radius: 16px;
    --yalo-chat-input-border-radius: 8px;

    /* Loading indicators match brand */
    --yalo-chat-spinner-color: #6200ee;
    --yalo-chat-dot-color: #6200ee;
    --yalo-chat-waveform-color: #6200ee;
  }
</style>
```
