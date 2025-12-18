// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/audio/audio_data.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:test/test.dart';

void main() {
  group(MessagesEvent, () {
    group('ChatLoadMessages', () {
      test('should support equality comparision', () {
        final event1 = ChatLoadMessages();
        final event2 = ChatLoadMessages(direction: PageDirection.initial);
        final event3 = ChatLoadMessages(direction: PageDirection.next);

        expect(event1, equals(event2));
        expect(event3, isNot(equals(event1)));
      });
    });

    group(ChatSubscribeToEvents, () {
      test('should support equality comparison', () {
        final event1 = ChatSubscribeToEvents();
        final event2 = ChatSubscribeToEvents();

        expect(event1, equals(event2));
      });
    });

    group(ChatSubscribeToMessages, () {
      test('should support equality comparison', () {
        final event1 = ChatSubscribeToMessages();
        final event2 = ChatSubscribeToMessages();

        expect(event1, equals(event2));
      });
    });

    group(ChatUpdateUserMessage, () {
      test('should support equality comparison', () {
        const event1 = ChatUpdateUserMessage(value: 'message');
        const event2 = ChatUpdateUserMessage(value: 'message');
        const event3 = ChatUpdateUserMessage(value: 'different message');

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('should handle empty string value', () {
        const event = ChatUpdateUserMessage(value: '');

        expect(event.value, equals(''));
        expect(event.props, equals(['']));
      });
    });

    group(ChatSendTextMessage, () {
      test('should support equality comparison', () {
        final event1 = ChatSendTextMessage();
        final event2 = ChatSendTextMessage();

        expect(event1, equals(event2));
      });
    });

    group(ChatSendVoiceMessage, () {
      test('should support equality comparison', () {
        final event1 = ChatSendVoiceMessage(audioData: AudioData());
        final event2 = ChatSendVoiceMessage(audioData: AudioData());

        expect(event1, equals(event2));
      });
    });

    group(ChatSendImageMessage, () {
      test('should support equality comparison', () {
        final event1 = ChatSendImageMessage(
          imageData: ImageData(path: '', mimeType: ''),
          text: '',
        );
        final event2 = ChatSendImageMessage(
          imageData: ImageData(path: '', mimeType: ''),
          text: '',
        );

        expect(event1, equals(event2));
      });
    });

    group(ChatClearMessages, () {
      test('should support equality comparison', () {
        final event1 = ChatClearMessages();
        final event2 = ChatClearMessages();

        expect(event1, equals(event2));
      });
    });
  });
}
