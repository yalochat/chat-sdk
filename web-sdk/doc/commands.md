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

| Command | Triggered when | Callback payload |
|---------|---------------|-----------------|
| `updateCartProduct` | User confirms a product in a product message via "Add to cart" | `{ sku: string, units: number, subunits?: number }` |
| `clearCart` | Cart is cleared | `unknown` |
| `guidanceCard` | Guidance cards are requested | `unknown` |
| `addPromotion` | A promotion is applied | `unknown` |

If a command has no registered callback, the SDK sends the action through the remote API as usual.
