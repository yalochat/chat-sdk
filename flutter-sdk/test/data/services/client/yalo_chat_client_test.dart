// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/data/services/client/yalo_chat_client.dart';
import 'package:chat_flutter_sdk/domain/models/command/chat_command.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(YaloChatClient, () {
    late YaloChatClient client;

    const testName = 'test name';
    const testFlowKey = 'test-flow-key';
    const testOrganizationId = 'test-org-id';

    setUp(() {
      client = YaloChatClient(
        name: testName,
        channelId: testFlowKey,
        organizationId: testOrganizationId,
      );
    });

    group('registerCommand', () {
      test('registers a callback for a command', () {
        dynamic receivedPayload;
        client.registerCommand(
          ChatCommand.addToCart,
          (payload) => receivedPayload = payload,
        );

        expect(client.commands, hasLength(1));
        expect(client.commands.containsKey(ChatCommand.addToCart), isTrue);

        client.commands[ChatCommand.addToCart]!({'sku': '123', 'quantity': 2});
        expect(receivedPayload, equals({'sku': '123', 'quantity': 2}));
      });

      test('replaces callback when registering the same command', () {
        client.registerCommand(ChatCommand.addToCart, (_) {});
        client.registerCommand(ChatCommand.addToCart, (_) {});

        expect(client.commands, hasLength(1));
      });

      test('registers multiple different commands', () {
        client.registerCommand(ChatCommand.addToCart, (_) {});
        client.registerCommand(ChatCommand.removeFromCart, (_) {});
        client.registerCommand(ChatCommand.clearCart, (_) {});

        expect(client.commands, hasLength(3));
        expect(
          client.commands.keys,
          containsAll([
            ChatCommand.addToCart,
            ChatCommand.removeFromCart,
            ChatCommand.clearCart,
          ]),
        );
      });

      test('commands getter returns an unmodifiable map', () {
        client.registerCommand(ChatCommand.addToCart, (_) {});

        expect(
          () => client.commands[ChatCommand.clearCart] = (_) {},
          throwsUnsupportedError,
        );
      });
    });
  });
}
