// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message_request.dart';
import 'package:test/test.dart';

void main() {
  group(YaloTextMessageRequest, () {
    const content = YaloTextMessage(
      timestamp: 1700000000,
      text: 'Hello',
      status: 'delivered',
      role: 'agent',
    );

    test('fromJson', () {
      final request = YaloTextMessageRequest.fromJson({
        'timestamp': 1700000000,
        'content': {
          'timestamp': 1700000000,
          'text': 'Hello',
          'status': 'delivered',
          'role': 'agent',
        },
      });

      expect(request.timestamp, 1700000000);
      expect(request.content, content);
    });

    test('toJson', () {
      final json = const YaloTextMessageRequest(
        timestamp: 1700000000,
        content: content,
      ).toJson();

      expect(json['timestamp'], 1700000000);
      expect(json['content'], content);
    });

    test('equality', () {
      const request1 = YaloTextMessageRequest(
        timestamp: 1700000000,
        content: content,
      );

      const request2 = YaloTextMessageRequest(
        timestamp: 1700000000,
        content: content,
      );

      const request3 = YaloTextMessageRequest(
        timestamp: 1700000001,
        content: content,
      );

      expect(request1, equals(request2));
      expect(request1, isNot(equals(request3)));
    });
  });
}
