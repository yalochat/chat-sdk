# Icons

By default the chat renders its icons as font ligatures from Material Symbols Outlined, loaded by the host page. You can change the font or swap individual glyphs with CSS variables. See the [Icons theming section](theming.md#icons) for that approach.

## Overriding icons with your own SVGs

The `icons` configuration object lets you replace individual built-in icons with your own image. Pass a URL or a `data:` URI per icon:

```js
const client = new YaloChatClient({
  channelId: 'your-channel',
  organizationId: 'your-org',
  channelName: 'Support',
  target: '#chat-root',
  icons: {
    send: 'https://cdn.example.com/icons/send.svg',
    close:
      'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18" stroke="black" stroke-width="2"/></svg>',
  },
});
```

This is per icon. Icons you do not override keep the built-in font glyph. Each value is rendered as an image, sized to the same dimensions as the font icon it replaces.

## Color is not customizable when overriding

An overridden icon is rendered as an `<img>`, so its color is fixed by the SVG file itself. The theme color and the icon CSS variables do not apply to it. Provide the color you want inside your SVG (its `fill` or `stroke`).

- If you support a single theme, bake the color into the SVG and you are done.
- If you support light and dark themes, or let users change an accent color, ship a separate SVG per color and set the matching value in `icons`. The icon does not recolor itself at runtime.

When an icon is omitted, the SDK keeps its built-in font glyph, which does follow the theme color. Leave an icon out whenever the default is good enough.

## Available icons

- **`send`** (`string`): Send action button in the footer.
- **`mic`** (`string`): Microphone action button in the footer.
- **`attachment`** (`string`): File attachment button next to the input.
- **`close`** (`string`): Close button in the header and the cancel button while recording.
- **`play`** (`string`): Play control on voice messages.
- **`pause`** (`string`): Pause control on voice messages.
- **`document`** (`string`): Icon shown next to the file name on attachment messages.
- **`arrowForward`** (`string`): Arrow inside assistant link buttons.
- **`check`** (`string`): Confirmation icon shown after adding a product to the cart or confirming a product card.
- **`error`** (`string`): Icon shown next to messages that failed to send.

## Notes

- The value is only ever bound to an `<img src>` attribute. The SDK never injects it as markup, so no raw SVG string parsing (`innerHTML`) is involved and static analysis will not flag it as an injection sink.
- To use `data:` URIs, the host page's Content Security Policy must allow them in `img-src` (for example `img-src 'self' data:`). Remote URLs must be allowed by `img-src` as well.
