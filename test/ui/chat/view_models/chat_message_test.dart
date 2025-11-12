// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_message.dart';
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
          role: MessageRole.system,
          type: MessageType.text,
          timestamp: fixedTimestamp,
        );
        expect(chatMessage1.hashCode, isNot(equals(chatMessage2.hashCode)));
        expect(chatMessage1, isNot(equals(chatMessage2)));
      },
    );

  });
}
