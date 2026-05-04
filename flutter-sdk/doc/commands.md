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

| Command | Triggered when | Callback payload |
|---------|---------------|-----------------|
| `ChatCommand.addToCart` | User increases a product quantity | `{ 'sku': String, 'quantity': double }` |
| `ChatCommand.removeFromCart` | User decreases a product quantity | `{ 'sku': String, 'quantity': double? }` |
| `ChatCommand.clearCart` | Cart is cleared | `null` |
| `ChatCommand.guidanceCard` | Guidance cards are requested | `null` |
| `ChatCommand.addPromotion` | A promotion is applied | `{ 'promotionId': String }` |

If a command has no registered callback, the SDK sends the action through the remote API as usual.
