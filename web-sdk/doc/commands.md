# Commands

Commands are actions the chat can invoke on your page. Use `registerCommand` to register a handler for a command id. When the chat triggers that command, your handler runs.

You can register commands before or after calling `init()`.

## Usage

```js
client.registerCommand('updateCartProduct', function (payload) {
  // payload: { sku: string, units: number, subunits?: number }
  console.log('Updating cart for', payload.sku, 'to', payload.units);
});

client.init();
```

## Built-in commands

- **`updateCartProduct`**: Triggered when the user confirms a product in a product message via "Add to cart", or through the confirm button in a product confirmation message. Callback payload: `{ sku: string, units: number, subunits?: number }`. The handler can be synchronous or return a promise. While it runs, the button that triggered it shows a loading state. If the handler throws or rejects, the product is not marked as added and the button becomes clickable again.
- **`clearCart`**: Triggered when the cart is cleared. Callback payload: `unknown`.
- **`goToCart`**: Triggered when the user asks to open the cart from the chat. The callback receives no payload and returns nothing. Use it to redirect the user to your cart page. When this command is registered, a footer link appears in a product confirmation message after the user confirms it, and clicking that footer runs your handler.
- **`getCart`**: Triggered when the channel asks your page for the products in its cart. The handler receives the cart request and returns the cart products (see [Returning the cart](#returning-the-cart)).

If a built-in command has no registered handler, the SDK sends the action through the remote API as usual. There are two exceptions:

- `goToCart`: navigation only makes sense in your page, so the SDK logs a warning and does nothing.
- `getCart`: only your page knows the cart contents, so the SDK logs a warning and sends no response.

## Custom commands

Any other command id is a custom command: the channel asks your page to run something and waits for a reply. Register a handler under a command id of your choice. When the channel sends a custom command request whose `commandId` matches, the SDK runs your handler with the request payload, then sends the result back to the channel as the response.

```js
client.registerCommand('refreshCatalog', function (payload) {
  // payload: the request payload string the channel sent
  const { region } = JSON.parse(payload);
  reloadCatalogFor(region);
  // The string you return becomes the response payload.
  return JSON.stringify({ status: 'reloaded' });
});

client.init();
```

Notes:

- You choose the command id. The channel triggers your handler by sending a custom command request with the same id. Built-in command ids are reserved, so pick a different id for your custom commands.
- The handler can be synchronous or return a promise. The SDK waits for it to settle before replying.
- The response status is `success` when the handler returns normally. If the handler throws or rejects, the SDK replies with an `error` status and an empty payload.
- If the handler returns nothing, the response payload is an empty string.
- When the channel sends a command id that has no registered handler, the SDK logs a warning and sends no response.

## Returning the cart

`getCart` is a typed built-in command. The channel asks your page for the products in its cart and the SDK replies with a typed cart response instead of a plain string.

```js
client.registerCommand('getCart', function (request) {
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

If you open the chat through the `window.yaloOpen` queue instead of holding a `YaloChatClient` reference, declare the same handlers inline in the configuration under `registerCommands`. The SDK registers them before the chat window opens.

```js
window.yaloOpen = window.yaloOpen || [];
window.yaloOpen.push({
  channelId: 'your-channel-id',
  organizationId: 'your-organization-id',
  channelName: 'Support',
  target: 'yalo-chat',
  registerCommands: {
    updateCartProduct: function (payload) {
      // same handler as client.registerCommand('updateCartProduct', ...)
    },
    refreshCatalog: function (payload) {
      // same handler as client.registerCommand('refreshCatalog', ...)
      return JSON.stringify({ status: 'reloaded' });
    },
    getCart: function (request) {
      // same handler as client.registerCommand('getCart', ...)
      // Return the products from your own cart. See the schema above.
      return { products: [] };
    },
  },
});
```
