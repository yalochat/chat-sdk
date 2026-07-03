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

## Custom commands

Custom commands go the other way: the channel asks your page to run something and waits for a reply. Use `onCommand` to register a handler under a command id of your choice. When the channel sends a custom command request whose `commandId` matches, the SDK runs your handler with the request payload, then sends the result back to the channel as the response.

You can register custom commands before or after calling `init()`.

```js
client.onCommand('refreshCatalog', function (payload) {
  // payload: the request payload string the channel sent
  const { region } = JSON.parse(payload);
  reloadCatalogFor(region);
  // The string you return becomes the response payload.
  return JSON.stringify({ status: 'reloaded' });
});

client.init();
```

Notes:

- You choose the command id. The channel triggers your handler by sending a custom command request with the same id.
- The handler can be synchronous or return a promise. The SDK waits for it to settle before replying.
- The response status is `success` when the handler returns normally. If the handler throws or rejects, the SDK replies with an `error` status and an empty payload.
- If the handler returns nothing, the response payload is an empty string.
- When the channel sends a command id that has no registered handler, the SDK logs a warning and sends no response.

## Returning the cart

`getCart` is a typed variant of a custom command. The channel asks your page for the products in its cart and the SDK replies with a typed cart response instead of a plain string. Register it with `onCommand` under the `getCart` id.

```js
client.onCommand('getCart', function (request) {
  // request: { cursor?: string, pageSize?: number }
  // Return the products in the current page of your cart.
  return {
    products: [
      {
        sku: 'WATER-1L',
        name: 'Water 1L',
        price: 12.5,
        imagesUrl: ['https://cdn.example.com/water.png'],
        subunits: 6,
        unitStep: 1,
        unitName: '{amount, plural, one {case} other {cases}}',
        subunitStep: 1,
        unitsAdded: 2,
        subunitsAdded: 0,
      },
    ],
    // pageInfo is optional. Include it to support pagination.
    pageInfo: { pageSize: 20, nextCursor: 'page-2' },
  };
});

client.init();
```

The request the handler receives has these fields:

- `cursor` (string, optional): the page the channel wants. Omitted for the first page.
- `pageSize` (number, optional): the maximum number of products the channel wants in the page.

Each product in the response has these fields:

- `sku` (string): unique product identifier.
- `name` (string): product name shown as the title.
- `price` (number): base price.
- `imagesUrl` (string array): image URLs for the product.
- `salePrice` (number, optional): sale price. Takes precedence over `price` when present.
- `subunits` (number): units contained in one unit, for example bottles inside a case.
- `unitStep` (number): increment used when changing the unit quantity.
- `unitName` (string): unit name in ICU message format, using the `amount` argument for plurals, for example `{amount, plural, one {case} other {cases}}`.
- `subunitName` (string, optional): subunit name in the same ICU format.
- `subunitStep` (number): increment used when changing the subunit quantity.
- `unitsAdded` (number): units currently in the cart.
- `subunitsAdded` (number): subunits currently in the cart.

The optional `pageInfo` describes the returned page:

- `pageSize` (number): number of products requested per page.
- `cursor` (string, optional): cursor that produced this page.
- `nextCursor` (string, optional): cursor to pass in the next request. Omitted on the last page.
- `prevCursor` (string, optional): cursor to fetch the previous page. Omitted on the first page.

Notes:

- The handler receives the request with the page `cursor` and `pageSize` the channel asked for. Omit `pageInfo` in the response when your cart is not paginated.
- The handler can be synchronous or return a promise. The SDK waits for it to settle before replying.
- The response status is `success` when the handler returns normally. If the handler throws or rejects, the SDK replies with an `error` status and an empty product list.
- When the channel asks for the cart and no `getCart` handler is registered, the SDK logs a warning and sends no response.

## Registering through the queue

If you open the chat through the `window.yaloOpen` queue instead of holding a `YaloChatClient` reference, declare the same callbacks inline in the configuration. Use `registerCommands` for client-to-channel commands and `onCommand` for custom commands. The SDK registers them before the chat window opens.

```js
window.yaloOpen = window.yaloOpen || [];
window.yaloOpen.push({
  channelId: 'your-channel-id',
  organizationId: 'your-organization-id',
  channelName: 'Support',
  target: 'yalo-chat',
  registerCommands: {
    updateCartProduct: function (payload) {
      // same callback as client.registerCommand('updateCartProduct', ...)
    },
  },
  onCommand: {
    refreshCatalog: function (payload) {
      // same handler as client.onCommand('refreshCatalog', ...)
      return JSON.stringify({ status: 'reloaded' });
    },
    getCart: function (request) {
      // same handler as client.onCommand('getCart', ...)
      // Return the products from your own cart. See the schema above.
      return { products: [] };
    },
  },
});
```
