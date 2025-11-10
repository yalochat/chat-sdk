// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:test/test.dart';

void main() {
  group(ChatState, () {
    test("should return true because states are equal with default values", () {
      var chatState = ChatState();
      var newChatState = ChatState();
      expect(newChatState, equals(chatState));
    });

    test("should return false because states are not equal", () {
      var chatState = ChatState();
      var newChatState = ChatState(isConnected: true);
      expect(newChatState, isNot(equals(chatState)));
    });

    test("should have same hashcodes since objects are equal", () {
      var chatState = ChatState(
        messages: [
          ChatMessage(
            role: MessageRole.user,
            messageType: MessageType.text,
            textMessage: 'teeeest',
          ),
        ],
        isConnected: true,
        isUserRecordingAudio: true,
      );
      var newChatState = ChatState(
        messages: [
          ChatMessage(
            role: MessageRole.user,
            messageType: MessageType.text,
            textMessage: 'teeeest',
          ),
        ],
        isConnected: true,
        isUserRecordingAudio: true,
      );
      expect(newChatState.hashCode, equals(chatState.hashCode));
    });

    test(
      "should have different hashCodes because the objects are different",
      () {
        var chatState = ChatState(
          messages: [
            ChatMessage(
              role: MessageRole.user,
              messageType: MessageType.text,
              textMessage: 'teeeest',
            ),
          ],
          isConnected: true,
          isUserRecordingAudio: true,
        );
        var newChatState = ChatState(
          messages: [
            ChatMessage(
              role: MessageRole.user,
              messageType: MessageType.text,
              textMessage: 'teeeest2',
            ),
          ],
          isConnected: true,
          isUserRecordingAudio: true,
        );
        expect(newChatState.hashCode, isNot(equals(chatState.hashCode)));
      },
    );
  });
}
