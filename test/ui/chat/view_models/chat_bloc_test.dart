// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group(ChatBloc, () {
    late ChatBloc chatBloc;

    setUp(() {
      chatBloc = ChatBloc();
    });

    test('should have initial state with sane defaults', () {
      expect(
        chatBloc.state,
        equals(
          ChatState(
            isConnected: false,
            isUserRecordingAudio: false,
            isSystemTypingMessage: false,
            messages: const [],
            userMessage: '',
          ),
        ),
      );
    });

    group('typing states', () {
      blocTest<ChatBloc, ChatState>(
        'should emit isSystemTypingMessage to true when the bloc reports that the system is writing',
        build: () => chatBloc,
        act: (bloc) => bloc.add(ChatStartTyping()),
        expect: () => [
          isA<ChatState>().having(
            (state) => state.isSystemTypingMessage,
            'isSystemTypingMessage',
            equals(true),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should emit isSystemTypingMessage to false when the bloc reports that the system is not writing',
        build: () => chatBloc,
        seed: () => chatBloc.state.copyWith(isSystemTypingMessage: true),
        act: (bloc) => bloc.add(ChatStopTyping()),
        expect: () => [
          isA<ChatState>().having(
            (state) => state.isSystemTypingMessage,
            'isSystemTypingMessage',
            equals(false),
          ),
        ],
      );
    });

    group('sending messages', () {
      blocTest<ChatBloc, ChatState>(
        'should send message and clear user message',
        build: () => chatBloc,
        seed: () => chatBloc.state.copyWith(userMessage: 'Test message'),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [
          isA<ChatState>()
              .having((state) => state.userMessage, 'userMessage', equals(''))
              .having(
                (state) => state.messages,
                'messages',
                contains('Test message'),
              ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should append a message to the end of a message array',
        build: () => chatBloc,
        seed: () => chatBloc.state.copyWith(
          userMessage: 'Test message',
          messages: ['Test 1', 'test2', 'test4'],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [
          isA<ChatState>()
              .having((state) => state.userMessage, 'userMessage', equals(''))
              .having(
                (state) => state.messages,
                'messages',
                equals(['Test 1', 'test2', 'test4', 'Test message']),
              ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should append a message to the end of a message array',
        build: () => chatBloc,
        seed: () => chatBloc.state.copyWith(
          userMessage: 'Test message',
          messages: ['Test 1', 'test2', 'test4'],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [
          isA<ChatState>()
              .having((state) => state.userMessage, 'userMessage', equals(''))
              .having(
                (state) => state.messages,
                'messages',
                equals(['Test 1', 'test2', 'test4', 'Test message']),
              ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should append a trimmed message to the end of a message list if it contains spaces on both ends',
        build: () => chatBloc,
        seed: () => chatBloc.state.copyWith(
          userMessage: '        Test message        ',
          messages: ['Test 1', 'test2', 'test4'],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [
          isA<ChatState>()
              .having((state) => state.userMessage, 'userMessage', equals(''))
              .having(
                (state) => state.messages,
                'messages',
                equals(['Test 1', 'test2', 'test4', 'Test message']),
              ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should emit nothing when adding empty messages to the message list',
        build: () => chatBloc,
        seed: () => chatBloc.state.copyWith(
          userMessage: '',
          messages: ['Test 1', 'test2', 'test4'],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [],
      );

      blocTest<ChatBloc, ChatState>(
        'should emit nothing when messages consists only of spaces',
        build: () => chatBloc,
        seed: () => chatBloc.state.copyWith(
          userMessage: '                     ',
          messages: ['Test 1', 'test2', 'test4'],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [],
      );
    });

    group('update message', () {
      blocTest<ChatBloc, ChatState>(
        'should update the user message if is different from current',
        build: () => chatBloc,
        act: (bloc) => bloc.add(ChatUpdateUserMessage(value: 'tres')),
        expect: () => [
          isA<ChatState>().having(
            (state) => state.userMessage,
            'userMessage',
            equals('tres'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should not emit if the user message is the same as the old one',
        build: () => chatBloc,
        seed: () => chatBloc.state.copyWith(userMessage: 'tres'),
        act: (bloc) => bloc.add(ChatUpdateUserMessage(value: 'tres')),
        expect: () => [],
      );
    });

    group('clear messages', () {
      blocTest<ChatBloc, ChatState>(
        'should emit empty messages when chat cleared',
        build: () => chatBloc,
        seed: () => chatBloc.state.copyWith(messages: ["Test"]),
        act: (bloc) => bloc.add(ChatClearMessages()),
        expect: () => [
          isA<ChatState>().having(
            (state) => state.messages,
            'messages',
            equals([]),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should not emit if the messages were already empty',
        build: () => chatBloc,
        act: (bloc) => bloc.add(ChatClearMessages()),
        expect: () => [
        ],
      );
    });
  });
}
