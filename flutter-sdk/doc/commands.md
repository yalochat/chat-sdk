# Commands

Commands let you handle client-to-channel actions locally instead of sending them through the default remote API. Use `registerCommand` to register a callback for a specific command. When that command is triggered by the chat UI, your callback runs instead of the built-in API call.

You can register commands before or after adding the `Chat` widget.

## Usage

```dart
import 'package:yalo_chat_flutter_sdk/yalo_sdk.dart';

final client = YaloChatClient(
  name: 'My Chat',
  channelId: 'your-channel-id',
  organizationId: 'your-organization-id',
);

client.registerCommand(ChatCommand.addToCart, (payload) {
  // payload: { 'sku': String, 'quantity': double }
  print('Adding ${payload['quantity']} of ${payload['sku']}');
});

client.registerCommand(ChatCommand.removeFromCart, (payload) {
  // payload: { 'sku': String, 'quantity': double? }
  print('Removing ${payload['quantity']} of ${payload['sku']}');
});
```

## Available commands

- **`ChatCommand.addToCart`**: Triggered when the user increases a product quantity. Callback payload: `{ 'sku': String, 'quantity': double }`.
- **`ChatCommand.removeFromCart`**: Triggered when the user decreases a product quantity. Callback payload: `{ 'sku': String, 'quantity': double? }`.
- **`ChatCommand.updateCartProduct`**: Triggered when the user confirms a product confirmation card. Sets the absolute units and subunits for the product. Callback payload: `{ 'sku': String, 'units': double, 'subunits': double }`.
- **`ChatCommand.clearCart`**: Triggered when the cart is cleared. Callback payload: `null`.
- **`ChatCommand.guidanceCard`**: Triggered when guidance cards are requested. Callback payload: `null`.
- **`ChatCommand.addPromotion`**: Triggered when a promotion is applied. Callback payload: `{ 'promotionId': String }`.

If a command has no registered callback, the SDK sends the action through the remote API as usual.

## Custom commands

Custom commands go the other way: the channel asks your app to run something and waits for a reply. Use `onCommand` to register a handler under a command id of your choice. When the channel sends a custom command request whose `commandId` matches, the SDK runs your handler with the request payload, then sends the result back to the channel as the response.

You can register custom commands before or after adding the `Chat` widget.

```dart
import 'package:yalo_chat_flutter_sdk/yalo_sdk.dart';

final client = YaloChatClient(
  name: 'My Chat',
  channelId: 'your-channel-id',
  organizationId: 'your-organization-id',
);

client.onCommand('refreshCatalog', (payload) {
  // payload: the request payload string the channel sent
  final region = jsonDecode(payload)['region'] as String;
  reloadCatalogFor(region);
  // The string you return becomes the response payload.
  return jsonEncode({'status': 'reloaded'});
});
```

Notes:

- You choose the command id. The channel triggers your handler by sending a custom command request with the same id.
- The handler can be synchronous or return a `Future`. The SDK waits for it to settle before replying.
- The response status is success when the handler returns normally. If the handler throws, the SDK replies with an error status and an empty payload.
- If the handler returns `null`, the response payload is an empty string.
- When the channel sends a command id that has no registered handler, the SDK logs a warning and sends no response.
