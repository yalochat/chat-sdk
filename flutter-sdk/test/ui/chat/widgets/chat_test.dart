// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/data/services/client/yalo_chat_client.dart';
import 'package:chat_flutter_sdk/ui/chat/widgets/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(Chat, () {
    testWidgets('renders', (tester) async {
      final client = YaloChatClient(
        name: 'Test',
        channelId: 'ch-1',
        organizationId: 'org-1',
      );
      await tester.pumpWidget(MaterialApp(home: Chat(client: client)));
    });
  });
}
