// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_event.dart';
import 'package:clock/clock.dart';
import 'package:test/test.dart';

void main() {
  group(AudioEvent, () {
    test('AudioAmplitudeSubscribe should be equatable', () {
      final event1 = AudioAmplitudeSubscribe();
      final event2 = AudioAmplitudeSubscribe();

      expect(event1, equals(event2));
      expect(event1.props, isEmpty);
    });

    test('AudioStartRecording should be equatable', () {
      final event1 = AudioStartRecording();
      final event2 = AudioStartRecording();

      expect(event1, equals(event2));
      expect(event1.props, isEmpty);
    });

    test('AudioStopRecording should be equatable', () {
      final event1 = AudioStopRecording();
      final event2 = AudioStopRecording();

      expect(event1, equals(event2));
      expect(event1.props, isEmpty);
    });

    test('AudioPlay should be equatable with same message', () {
      final fixedClock = Clock.fixed(clock.now());
      final message = ChatMessage(
        role: MessageRole.user,
        type: MessageType.image,
        timestamp: fixedClock.now(),
      );
      final event1 = AudioPlay(message: message);
      final event2 = AudioPlay(message: message);

      expect(event1, equals(event2));
      expect(event1.props, equals([message]));
    });

    test('AudioPlay should not be equal with different messages', () {
      final fixedClock = Clock.fixed(clock.now());
      final message1 = ChatMessage(
        role: MessageRole.user,
        type: MessageType.image,
        timestamp: fixedClock.now(),
      );
      final message2 = ChatMessage(
        role: MessageRole.user,
        type: MessageType.voice,
        timestamp: fixedClock.now(),
      );
      final event1 = AudioPlay(message: message1);
      final event2 = AudioPlay(message: message2);

      expect(event1, isNot(equals(event2)));
    });

    test('AudioStop should be equatable', () {
      final event1 = AudioStop();
      final event2 = AudioStop();

      expect(event1, equals(event2));
      expect(event1.props, isEmpty);
    });

    test('AudioCompletedSubscribe should be equatable', () {
      final event1 = AudioCompletedSubscribe();
      final event2 = AudioCompletedSubscribe();

      expect(event1, equals(event2));
      expect(event1.props, isEmpty);
    });
  });
}
