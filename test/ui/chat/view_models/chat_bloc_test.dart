// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group(ChatBloc, () {
    test('should have initial state with sane defaults', () {
      expect(
        ChatBloc().state,
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
        'should emit isSystemTypingMessage to true and chat status Typing... when the bloc reports that the system is writing with a status message',
        build: () => ChatBloc(),
        act: (bloc) => bloc.add(ChatStartTyping(chatStatus: 'Typing...')),
        expect: () => [
          isA<ChatState>()
              .having(
                (state) => state.isSystemTypingMessage,
                'isSystemTypingMessage',
                equals(true),
              )
              .having(
                (state) => state.chatStatus,
                'chatStatus',
                equals('Typing...'),
              ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should emit isSystemTypingMessage to true with empty status when the bloc reports that the system is writing without status message',
        build: () => ChatBloc(),
        act: (bloc) => bloc.add(ChatStartTyping()),
        expect: () => [
          isA<ChatState>()
              .having(
                (state) => state.isSystemTypingMessage,
                'isSystemTypingMessage',
                equals(true),
              )
              .having((state) => state.chatStatus, 'chatStatus', equals('')),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should emit isSystemTypingMessage to false when the bloc reports that the system is not writing',
        build: () => ChatBloc(),
        seed: () => ChatState(isSystemTypingMessage: true),
        act: (bloc) => bloc.add(ChatStopTyping()),
        expect: () => [
          isA<ChatState>()
              .having(
                (state) => state.isSystemTypingMessage,
                'isSystemTypingMessage',
                equals(false),
              )
              .having((state) => state.chatStatus, 'chatStatus', equals('')),
        ],
      );
    });

    group('sending messages', () {
      var fixedClock = Clock.fixed(DateTime.now());
      blocTest<ChatBloc, ChatState>(
        'should send message and clear user message when the message array is empty',
        build: () => ChatBloc(clock: fixedClock),
        seed: () => ChatState(userMessage: 'Test message'),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [
          isA<ChatState>()
              .having((state) => state.userMessage, 'userMessage', equals(''))
              .having(
                (state) => state.messages,
                'messages',
                contains(
                  ChatMessage(
                    id: 0,
                    role: MessageRole.user,
                    type: MessageType.text,
                    text: 'Test message',
                    timestamp: fixedClock.now(),
                  ),
                ),
              ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should append a message to the end of a message array when already has messages',
        build: () => ChatBloc(clock: fixedClock),
        seed: () => ChatState(
          userMessage: 'Test message',
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 1',
              timestamp: fixedClock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.system,
              type: MessageType.text,
              text: 'Test 2',
              timestamp: fixedClock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 3',
              timestamp: fixedClock.now(),
            ),
          ],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [
          isA<ChatState>()
              .having((state) => state.userMessage, 'userMessage', equals(''))
              .having(
                (state) => state.messages.length,
                'messages length',
                equals(4),
              )
              .having(
                (state) => state.messages[state.messages.length - 1],
                'last inserted message',
                equals(
                  ChatMessage(
                    id: 3,
                    role: MessageRole.user,
                    type: MessageType.text,
                    text: 'Test message',
                    timestamp: fixedClock.now(),
                  ),
                ),
              ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should append a trimmed message to the end of a message list if it contains spaces on both ends',
        build: () => ChatBloc(clock: fixedClock),
        seed: () => ChatState(
          userMessage: '        Test message        ',
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 1',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 2',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 3',
              timestamp: clock.now(),
            ),
          ],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [
          isA<ChatState>()
              .having((state) => state.userMessage, 'userMessage', equals(''))
              .having(
                (state) => state.messages.length,
                'messages length',
                equals(4),
              )
              .having(
                (state) => state.messages[state.messages.length - 1],
                'last inserted message',
                equals(
                  ChatMessage(
                    id: 3,
                    role: MessageRole.user,
                    type: MessageType.text,
                    text: 'Test message',
                    timestamp: fixedClock.now(),
                  ),
                ),
              ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'should emit nothing when adding empty messages to the message list',
        build: () => ChatBloc(),
        seed: () => ChatState(
          userMessage: '',
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 1',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 2',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 3',
              timestamp: clock.now(),
            ),
          ],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [],
      );

      blocTest<ChatBloc, ChatState>(
        'should emit nothing when messages consists only of spaces',
        build: () => ChatBloc(),
        seed: () => ChatState(
          userMessage: '                     ',
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 1',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 2',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 3',
              timestamp: clock.now(),
            ),
          ],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [],
      );
    });

    group('update message', () {
      blocTest<ChatBloc, ChatState>(
        'should update the user message if is different from current',
        build: () => ChatBloc(),
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
        build: () => ChatBloc(),
        seed: () => ChatState(userMessage: 'tres'),
        act: (bloc) => bloc.add(ChatUpdateUserMessage(value: 'tres')),
        expect: () => [],
      );
    });

    group('clear messages', () {
      blocTest<ChatBloc, ChatState>(
        'should emit empty messages when chat cleared',
        build: () => ChatBloc(),
        seed: () => ChatState(
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 1',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 2',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.user,
              type: MessageType.text,
              text: 'Test 3',
              timestamp: clock.now(),
            ),
          ],
        ),
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
        build: () => ChatBloc(),
        act: (bloc) => bloc.add(ChatClearMessages()),
        expect: () => [],
      );
    });
  });
}
