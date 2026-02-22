// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_message.dart';
import 'package:test/test.dart';

void main() {
  group(YaloMessage, () {
    test('fromJson', () {
      final message = YaloMessage.fromJson({'text': 'Hello', 'role': 'agent'});

      expect(message.text, 'Hello');
      expect(message.role, 'agent');
    });

    test('toJson', () {
      final json = const YaloMessage(text: 'Hello', role: 'agent').toJson();

      expect(json, {'text': 'Hello', 'role': 'agent'});
    });
  });
}
