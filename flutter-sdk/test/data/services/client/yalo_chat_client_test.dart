// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/data/services/client/yalo_chat_client.dart';
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

    group('registerAction', () {
      test('adds an action with the correct name and callback', () {
        bool wasCalled = false;
        client.registerAction('myAction', () => wasCalled = true);

        expect(client.actions, hasLength(1));
        expect(client.actions.first.name, equals('myAction'));

        client.actions.first.action();
        expect(wasCalled, isTrue);
      });

      test('accumulates multiple actions in registration order', () {
        client.registerAction('first', () {});
        client.registerAction('second', () {});
        client.registerAction('third', () {});

        expect(client.actions, hasLength(3));
        expect(
          client.actions.map((a) => a.name),
          equals(['first', 'second', 'third']),
        );
      });
    });
  });
}
