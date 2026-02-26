// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_fetch_messages_response.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_message.dart';
import 'package:test/test.dart';

void main() {
  group(YaloFetchMessagesResponse, () {
    final json = <String, dynamic>{
      'id': 'msg-1',
      'message': {'text': 'Hello', 'role': 'agent'},
      'date': '2024-01-01T00:00:00Z',
      'user_id': 'user-abc',
      'status': 'delivered',
    };

    test('fromJson', () {
      final response = YaloFetchMessagesResponse.fromJson(json);

      expect(response.id, 'msg-1');
      expect(response.message, const YaloMessage(text: 'Hello', role: 'agent'));
      expect(response.date, '2024-01-01T00:00:00Z');
      expect(response.userId, 'user-abc');
      expect(response.status, 'delivered');
    });

    test('toJson maps userId to user_id', () {
      final response = YaloFetchMessagesResponse.fromJson(json);

      expect(response.toJson()['user_id'], 'user-abc');
    });

    test('fromJsonList', () {
      final result = YaloFetchMessagesResponse.fromJsonList([
        json,
        {...json, 'id': 'msg-2'},
      ]);

      expect(result, hasLength(2));
      expect(result[0].id, 'msg-1');
      expect(result[1].id, 'msg-2');
    });

    test('fromJsonList with empty input', () {
      expect(YaloFetchMessagesResponse.fromJsonList([]), isEmpty);
    });

    test('equality', () {
      const response1 = YaloFetchMessagesResponse(
        id: 'msg-1',
        message: YaloMessage(text: 'Hello', role: 'agent'),
        date: '2024-01-01T00:00:00Z',
        userId: 'user-abc',
        status: 'delivered',
      );

      const response2 = YaloFetchMessagesResponse(
        id: 'msg-1',
        message: YaloMessage(text: 'Hello', role: 'agent'),
        date: '2024-01-01T00:00:00Z',
        userId: 'user-abc',
        status: 'delivered',
      );

      const response3 = YaloFetchMessagesResponse(
        id: 'msg-2',
        message: YaloMessage(text: 'Hello', role: 'agent'),
        date: '2024-01-01T00:00:00Z',
        userId: 'user-abc',
        status: 'delivered',
      );

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });
  });
}
