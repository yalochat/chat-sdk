// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:test/test.dart';

void main() {
  group(ChatMessage, () {
    test('should return true when two equal chat messages are compared', () {
      final fixedTimestamp = DateTime(2025, 1, 1, 1);
      final chatMessage1 = ChatMessage(
        id: 0,
        role: MessageRole.user,
        type: MessageType.text,
        timestamp: fixedTimestamp,
      );
      final chatMessage2 = ChatMessage(
        id: 0,
        role: MessageRole.user,
        type: MessageType.text,
        timestamp: fixedTimestamp,
      );
      expect(chatMessage1.hashCode, equals(chatMessage2.hashCode));
      expect(chatMessage1, equals(chatMessage2));
    });

    test(
      'should return false when two different chat messages are compared',
      () {
        final fixedTimestamp = DateTime(2025, 1, 1, 1);
        final chatMessage1 = ChatMessage(
          id: 0,
          role: MessageRole.user,
          type: MessageType.text,
          timestamp: fixedTimestamp,
        );
        final chatMessage2 = ChatMessage(
          id: 0,
          role: MessageRole.assistant,
          type: MessageType.text,
          timestamp: fixedTimestamp,
        );
        expect(chatMessage1.hashCode, isNot(equals(chatMessage2.hashCode)));
        expect(chatMessage1, isNot(equals(chatMessage2)));
      },
    );

    test('should return different and equal objects with copyWith', () {
      final fixedTimestamp = DateTime(2025, 1, 1, 1);
      final chatMessage1 = ChatMessage(
        id: 0,
        role: MessageRole.user,
        type: MessageType.text,
        timestamp: fixedTimestamp,
      );
      final chatMessage2 = chatMessage1.copyWith();
      expect(chatMessage1, equals(chatMessage2));

      final chatMessage3 = chatMessage1.copyWith(id: 1);
      expect(chatMessage1, isNot(equals(chatMessage3.id)));
      expect(chatMessage1.role, equals(chatMessage3.role));
      expect(chatMessage1.type, equals(chatMessage3.type));
      expect(chatMessage1.timestamp, equals(chatMessage3.timestamp));
    });
  });
}
