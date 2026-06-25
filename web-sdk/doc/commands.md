# Commands

Commands let you handle client-to-channel actions locally instead of sending them through the default remote API. Use `registerCommand` to register a callback for a specific command. When that command is triggered by the chat UI, your callback runs instead of the built-in API call.

You can register commands before or after calling `init()`.

## Usage

```js
client.registerCommand('updateCartProduct', function (payload) {
  // payload: { sku: string, units: number, subunits?: number }
  console.log('Updating cart for', payload.sku, 'to', payload.units);
});

client.init();
```

## Available commands

- **`updateCartProduct`**: Triggered when the user confirms a product in a product message via "Add to cart". Callback payload: `{ sku: string, units: number, subunits?: number }`.
- **`clearCart`**: Triggered when the cart is cleared. Callback payload: `unknown`.

If a command has no registered callback, the SDK sends the action through the remote API as usual.

## Custom commands (channel to client)

Custom commands go the other way: the channel asks your page to run something. Use `onCommand` to register a handler keyed by a command id. When the channel sends a custom command request with a matching id, the SDK runs your handler and replies to the channel with the result.

You can register custom commands before or after calling `init()`.

```js
client.onCommand('refreshCatalog', function (payload) {
  // payload: the request payload string sent by the channel
  const { region } = JSON.parse(payload);
  reloadCatalogFor(region);
  // The returned string becomes the response payload sent back to the channel.
  return JSON.stringify({ status: 'reloaded' });
});

client.init();
```

Notes:

- The handler can be synchronous or return a promise. The SDK waits for it to settle before replying.
- The response status is `success` when the handler returns normally. If the handler throws or rejects, the SDK replies with an `error` status and an empty payload.
- If the handler returns nothing, the response payload is an empty string.
- When the channel sends a command id that has no registered handler, the SDK logs a warning and sends no response.
