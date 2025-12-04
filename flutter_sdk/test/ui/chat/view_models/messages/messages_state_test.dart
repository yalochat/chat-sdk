// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:clock/clock.dart';
import 'package:test/test.dart';

void main() {
  group(MessagesState, () {
    test("should return true because states are equal with default values", () {
      var chatState = MessagesState();
      var newMessagesState = MessagesState();
      expect(newMessagesState, equals(chatState));
    });

    test("should return false because states are not equal", () {
      var chatState = MessagesState();
      var newMessagesState = MessagesState(isConnected: true);
      expect(newMessagesState, isNot(equals(chatState)));
    });

    test(
      "should have same hashcodes since objects are equal",
      () => withClock(Clock.fixed(DateTime.now()), () {
        var chatState = MessagesState(
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'teeeest',
              timestamp: clock.now()
            ),
          ],
          isConnected: true,
        );
        var newMessagesState = MessagesState(
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'teeeest',
              timestamp: clock.now()
            ),
          ],
          isConnected: true,
        );
        expect(newMessagesState.hashCode, equals(chatState.hashCode));
      }),
    );

    test(
      "should have different hashCodes because the objects are different",
      () {
        var chatState = MessagesState(
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'teeeest',
              timestamp: clock.now()
            ),
          ],
          isConnected: true,
        );
        var newMessagesState = MessagesState(
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              timestamp: clock.now(),
              content: 'teeeest2',
            ),
          ],
          isConnected: true,
        );
        expect(newMessagesState.hashCode, isNot(equals(chatState.hashCode)));
      },
    );
  });
}
