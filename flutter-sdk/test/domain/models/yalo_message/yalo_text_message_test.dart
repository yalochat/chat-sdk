// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message.dart';
import 'package:test/test.dart';

void main() {
  group(YaloTextMessage, () {
    test('fromJson', () {
      final message = YaloTextMessage.fromJson({
        'timestamp': 1700000000,
        'text': 'Hello',
        'status': 'delivered',
        'role': 'agent',
      });

      expect(message.timestamp, 1700000000);
      expect(message.text, 'Hello');
      expect(message.status, 'delivered');
      expect(message.role, 'agent');
    });

    test('toJson', () {
      final json = const YaloTextMessage(
        timestamp: 1700000000,
        text: 'Hello',
        status: 'delivered',
        role: 'agent',
      ).toJson();

      expect(json['timestamp'], 1700000000);
      expect(json['text'], 'Hello');
      expect(json['status'], 'delivered');
      expect(json['role'], 'agent');
    });
  });
}
