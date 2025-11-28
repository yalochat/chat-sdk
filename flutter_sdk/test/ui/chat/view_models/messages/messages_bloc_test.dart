// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/exceptions/range_exception.dart';
import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository.dart';
import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class ChatMessageRepositoryMock extends Mock implements ChatMessageRepository {}

void main() {
  group(MessagesBloc, () {
    late ChatMessageRepository chatMessageRepository;

    setUpAll(() {
      registerFallbackValue(
        ChatMessage(
          id: 0,
          role: MessageRole.user,
          type: MessageType.text,
          content: 'Test message',
          timestamp: clock.now(),
        ),
      );
    });

    setUp(() {
      chatMessageRepository = ChatMessageRepositoryMock();
    });

    test('should have initial state with sane defaults', () {
      expect(
        MessagesBloc(chatMessageRepository: chatMessageRepository).state,
        equals(
          MessagesState(
            isConnected: false,
            isSystemTypingMessage: false,
            messages: const [],
            userMessage: '',
          ),
        ),
      );
    });

    group('typing states', () {
      blocTest<MessagesBloc, MessagesState>(
        'should emit isSystemTypingMessage to true and chat status Typing... when the bloc reports that the system is writing with a status message',
        build: () => MessagesBloc(chatMessageRepository: chatMessageRepository),
        act: (bloc) => bloc.add(ChatStartTyping(chatStatusText: 'Typing...')),
        expect: () => [
          isA<MessagesState>()
              .having(
                (state) => state.isSystemTypingMessage,
                'isSystemTypingMessage',
                equals(true),
              )
              .having(
                (state) => state.chatStatusText,
                'chatStatus',
                equals('Typing...'),
              ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit isSystemTypingMessage to true with empty status when the bloc reports that the system is writing without status message',
        build: () => MessagesBloc(chatMessageRepository: chatMessageRepository),
        act: (bloc) => bloc.add(ChatStartTyping()),
        expect: () => [
          isA<MessagesState>()
              .having(
                (state) => state.isSystemTypingMessage,
                'isSystemTypingMessage',
                equals(true),
              )
              .having(
                (state) => state.chatStatusText,
                'chatStatus',
                equals(''),
              ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit isSystemTypingMessage to false when the bloc reports that the system is not writing',
        build: () => MessagesBloc(chatMessageRepository: chatMessageRepository),
        seed: () => MessagesState(isSystemTypingMessage: true),
        act: (bloc) => bloc.add(ChatStopTyping()),
        expect: () => [
          isA<MessagesState>()
              .having(
                (state) => state.isSystemTypingMessage,
                'isSystemTypingMessage',
                equals(false),
              )
              .having(
                (state) => state.chatStatusText,
                'chatStatus',
                equals(''),
              ),
        ],
      );
    });

    group('sending messages', () {
      var fixedClock = Clock.fixed(DateTime.now());
      blocTest<MessagesBloc, MessagesState>(
        'should send message and clear user message when the message array is empty',
        build: () => MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          clock: fixedClock,
        ),
        seed: () => MessagesState(userMessage: 'Test message'),
        act: (bloc) {
          when(() => chatMessageRepository.insertChatMessage(any())).thenAnswer(
            (_) async => Result.ok(
              ChatMessage(
                id: 1,
                role: MessageRole.user,
                type: MessageType.text,
                content: 'Test message',
                timestamp: fixedClock.now(),
              ),
            ),
          );
          bloc.add(ChatSendMessage());
        },
        expect: () => [
          isA<MessagesState>()
              .having((state) => state.userMessage, 'userMessage', equals(''))
              .having(
                (state) => state.messages,
                'messages',
                contains(
                  ChatMessage(
                    id: 1,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test message',
                    timestamp: fixedClock.now(),
                  ),
                ),
              ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should append a message to the start of a message array when already has messages',
        build: () => MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          clock: fixedClock,
        ),
        seed: () => MessagesState(
          userMessage: 'Test message',
          messages: [
            ChatMessage(
              id: 3,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 3',
              timestamp: fixedClock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.assistant,
              type: MessageType.text,
              content: 'Test 2',
              timestamp: fixedClock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 1',
              timestamp: fixedClock.now(),
            ),
          ],
        ),
        act: (bloc) {
          when(() => chatMessageRepository.insertChatMessage(any())).thenAnswer(
            (_) async => Result.ok(
              ChatMessage(
                id: 4,
                role: MessageRole.user,
                type: MessageType.text,
                content: 'Test message',
                timestamp: fixedClock.now(),
              ),
            ),
          );
          bloc.add(ChatSendMessage());
        },
        expect: () => [
          isA<MessagesState>()
              .having((state) => state.userMessage, 'userMessage', equals(''))
              .having(
                (state) => state.messages.length,
                'messages length',
                equals(4),
              )
              .having(
                (state) => state.messages[0],
                'last inserted message',
                equals(
                  ChatMessage(
                    id: 4,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test message',
                    timestamp: fixedClock.now(),
                  ),
                ),
              ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should append a trimmed message to the start of a message list if it contains spaces on both ends',
        build: () => MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          clock: fixedClock,
        ),
        seed: () => MessagesState(
          userMessage: '        Test message        ',
          messages: [
            ChatMessage(
              id: 3,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 1',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 2',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 3',
              timestamp: clock.now(),
            ),
          ],
        ),
        act: (bloc) {
          when(() => chatMessageRepository.insertChatMessage(any())).thenAnswer(
            (_) async => Result.ok(
              ChatMessage(
                id: 4,
                role: MessageRole.user,
                type: MessageType.text,
                content: 'Test message',
                timestamp: fixedClock.now(),
              ),
            ),
          );
          bloc.add(ChatSendMessage());
        },
        expect: () => [
          isA<MessagesState>()
              .having((state) => state.userMessage, 'userMessage', equals(''))
              .having(
                (state) => state.messages.length,
                'messages length',
                equals(4),
              )
              .having(
                (state) => state.messages[0],
                'last inserted message',
                equals(
                  ChatMessage(
                    id: 4,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test message',
                    timestamp: fixedClock.now(),
                  ),
                ),
              ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit an error when the insertion of the message fails',
        build: () => MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          clock: fixedClock,
        ),
        seed: () => MessagesState(
          userMessage: 'Test message',
          messages: [
            ChatMessage(
              id: 3,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 1',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 2',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 3',
              timestamp: clock.now(),
            ),
          ],
        ),
        act: (bloc) {
          when(() => chatMessageRepository.insertChatMessage(any())).thenAnswer(
            (_) async =>
                Result.error(RangeException('Range exception', -1, 2, 3)),
          );
          bloc.add(ChatSendMessage());
        },
        expect: () => [
          isA<MessagesState>()
              .having(
                (state) => state.userMessage,
                'userMessage',
                equals('Test message'),
              )
              .having(
                (state) => state.messages.length,
                'messages length',
                equals(3),
              )
              .having(
                (state) => state.chatStatus,
                'chatStatus',
                equals(ChatStatus.failedMessageSent),
              )
              .having(
                (state) => state.messages[0],
                'last inserted message',
                isNot(
                  equals(
                    ChatMessage(
                      id: 4,
                      role: MessageRole.user,
                      type: MessageType.text,
                      content: 'Test message',
                      timestamp: fixedClock.now(),
                    ),
                  ),
                ),
              ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit nothing when adding empty messages to the message list',
        build: () => MessagesBloc(chatMessageRepository: chatMessageRepository),
        seed: () => MessagesState(
          userMessage: '',
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 1',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 2',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 3',
              timestamp: clock.now(),
            ),
          ],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit nothing when messages consists only of spaces',
        build: () => MessagesBloc(chatMessageRepository: chatMessageRepository),
        seed: () => MessagesState(
          userMessage: '                     ',
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 1',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 2',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 3',
              timestamp: clock.now(),
            ),
          ],
        ),
        act: (bloc) => bloc.add(ChatSendMessage()),
        expect: () => [],
      );
    });

    group('fetch messages', () {
      var fixedClock = Clock.fixed(DateTime.now());
      blocTest<MessagesBloc, MessagesState>(
        'should fetch messages from repository and set them up correctly',
        build: () => MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          clock: fixedClock,
        ),
        act: (bloc) {
          when(
            () => chatMessageRepository.getChatMessagePageDesc(
              null,
              SdkConstants.defaultPageSize,
            ),
          ).thenAnswer(
            (_) async => Result.ok(
              Page<ChatMessage>(
                data: [
                  ChatMessage(
                    id: 3,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test 1',
                    timestamp: fixedClock.now(),
                  ),
                  ChatMessage(
                    id: 2,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test 2',
                    timestamp: fixedClock.now(),
                  ),
                  ChatMessage(
                    id: 1,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test 3',
                    timestamp: fixedClock.now(),
                  ),
                ],
                pageInfo: PageInfo(pageSize: SdkConstants.defaultPageSize),
              ),
            ),
          );
          bloc.add(ChatLoadMessages(direction: PageDirection.initial));
        },
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.isLoading,
            'is loading',
            equals(true),
          ),
          isA<MessagesState>()
              .having(
                (state) => state.messages.length,
                'message count',
                equals(3),
              )
              .having(
                (state) => state.chatStatus,
                'chat status',
                equals(ChatStatus.success),
              )
              .having((state) => state.isLoading, 'loading', equals(false)),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should fetch next page of messages until there are no more pages from repository and set them up correctly',
        build: () =>
            MessagesBloc(chatMessageRepository: chatMessageRepository, pageSize: 3),
        act: (bloc) {
          final pageSize = 3;
          when(
            () => chatMessageRepository.getChatMessagePageDesc(null, pageSize),
          ).thenAnswer(
            (_) async => Result.ok(
              Page<ChatMessage>(
                data: [
                  ChatMessage(
                    id: 5,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test 1',
                    timestamp: fixedClock.now(),
                  ),
                  ChatMessage(
                    id: 4,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test 2',
                    timestamp: fixedClock.now(),
                  ),
                  ChatMessage(
                    id: 3,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test 3',
                    timestamp: fixedClock.now(),
                  ),
                ],
                pageInfo: PageInfo(
                  pageSize: pageSize,
                  nextCursor: 3,
                  cursor: null,
                ),
              ),
            ),
          );
          when(
            () => chatMessageRepository.getChatMessagePageDesc(3, pageSize),
          ).thenAnswer(
            (_) async => Result.ok(
              Page<ChatMessage>(
                data: [
                  ChatMessage(
                    id: 2,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test 1',
                    timestamp: fixedClock.now(),
                  ),
                  ChatMessage(
                    id: 1,
                    role: MessageRole.user,
                    type: MessageType.text,
                    content: 'Test 2',
                    timestamp: fixedClock.now(),
                  ),
                ],
                pageInfo: PageInfo(
                  pageSize: pageSize,
                  cursor: 3,
                  nextCursor: null,
                  prevCursor: null,
                ),
              ),
            ),
          );
          bloc.add(ChatLoadMessages(direction: PageDirection.initial));
          bloc.add(ChatLoadMessages(direction: PageDirection.next));
          bloc.add(ChatLoadMessages(direction: PageDirection.next));
        },
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.isLoading,
            'is loading',
            equals(true),
          ),
          isA<MessagesState>()
              .having(
                (state) => state.messages.length,
                'message count',
                equals(3),
              )
              .having(
                (state) => state.chatStatus,
                'chat status',
                equals(ChatStatus.success),
              )
              .having((state) => state.isLoading, 'loading', equals(false)),
          isA<MessagesState>().having(
            (state) => state.isLoading,
            'is loading',
            equals(true),
          ),
          isA<MessagesState>()
              .having(
                (state) => state.messages.length,
                'message count',
                equals(5),
              )
              .having(
                (state) => state.chatStatus,
                'chat status',
                equals(ChatStatus.success),
              )
              .having((state) => state.isLoading, 'loading', equals(false)),
          isA<MessagesState>().having(
            (state) => state.isLoading,
            'loading',
            equals(true),
          ),
          isA<MessagesState>().having(
            (state) => state.isLoading,
            'loading',
            equals(false),
          ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit a failure state when the message repository fails',
        build: () => MessagesBloc(chatMessageRepository: chatMessageRepository),
        act: (bloc) {
          when(
            () => chatMessageRepository.getChatMessagePageDesc(
              null,
              SdkConstants.defaultPageSize,
            ),
          ).thenAnswer(
            (_) async =>
                Result.error(RangeException('Range exception', -1, 2, 3)),
          );
          bloc.add(ChatLoadMessages());
        },
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.isLoading,
            'loading',
            equals(true),
          ),
          isA<MessagesState>()
              .having(
                (state) => state.chatStatus,
                'chat status',
                equals(ChatStatus.failure),
              )
              .having((state) => state.isLoading, 'loading', equals(false)),
        ],
      );
    });

    group('update message', () {
      blocTest<MessagesBloc, MessagesState>(
        'should update the user message if is different from current',
        build: () => MessagesBloc(chatMessageRepository: chatMessageRepository),
        act: (bloc) => bloc.add(ChatUpdateUserMessage(value: 'tres')),
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.userMessage,
            'userMessage',
            equals('tres'),
          ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should not emit if the user message is the same as the old one',
        build: () => MessagesBloc(chatMessageRepository: chatMessageRepository),
        seed: () => MessagesState(userMessage: 'tres'),
        act: (bloc) => bloc.add(ChatUpdateUserMessage(value: 'tres')),
        expect: () => [],
      );
    });

    group('clear messages', () {
      blocTest<MessagesBloc, MessagesState>(
        'should emit empty messages when chat cleared',
        build: () => MessagesBloc(chatMessageRepository: chatMessageRepository),
        seed: () => MessagesState(
          messages: [
            ChatMessage(
              id: 0,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 1',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 1,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 2',
              timestamp: clock.now(),
            ),
            ChatMessage(
              id: 2,
              role: MessageRole.user,
              type: MessageType.text,
              content: 'Test 3',
              timestamp: clock.now(),
            ),
          ],
        ),
        act: (bloc) => bloc.add(ChatClearMessages()),
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.messages,
            'messages',
            equals([]),
          ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should not emit if the messages were already empty',
        build: () => MessagesBloc(chatMessageRepository: chatMessageRepository),
        act: (bloc) => bloc.add(ChatClearMessages()),
        expect: () => [],
      );
    });
  });
}
