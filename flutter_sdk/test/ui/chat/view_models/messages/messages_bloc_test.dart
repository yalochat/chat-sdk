// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

import 'package:chat_flutter_sdk/src/common/exceptions/range_exception.dart';
import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/image/image_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/audio/audio_data.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatMessageRepository extends Mock implements ChatMessageRepository {}

class MockImageRepository extends Mock implements ImageRepository {}

class MockYaloMessageRepository extends Mock implements YaloMessageRepository {}

void main() {
  group(MessagesBloc, () {
    late ChatMessageRepository chatMessageRepository;
    late ImageRepository imageRepository;
    late YaloMessageRepository yaloMessageRepository;
    late MessagesBloc bloc;

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
      registerFallbackValue(
        ImageData(path: 'test/test.png', mimeType: 'image/png'),
      );
    });

    setUp(() {
      chatMessageRepository = MockChatMessageRepository();
      imageRepository = MockImageRepository();
      yaloMessageRepository = MockYaloMessageRepository();

      bloc = MessagesBloc(
        chatMessageRepository: chatMessageRepository,
        imageRepository: imageRepository,
        yaloMessageRepository: yaloMessageRepository,
      );

      when(
        () => yaloMessageRepository.sendMessage(any()),
      ).thenAnswer((_) async => Result.ok(Unit()));
    });

    test('should have initial state with sane defaults', () {
      expect(
        MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          imageRepository: imageRepository,
          yaloMessageRepository: yaloMessageRepository,
        ).state,
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

    group('sending messages', () {
      var fixedClock = Clock.fixed(DateTime.now());
      blocTest<MessagesBloc, MessagesState>(
        'should send a text message and clear user message when the message array is empty',
        build: () => MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          imageRepository: imageRepository,
          yaloMessageRepository: yaloMessageRepository,
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
          bloc.add(ChatSendTextMessage());
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
          imageRepository: imageRepository,
          yaloMessageRepository: yaloMessageRepository,
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
          bloc.add(ChatSendTextMessage());
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
          imageRepository: imageRepository,
          yaloMessageRepository: yaloMessageRepository,
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
          bloc.add(ChatSendTextMessage());
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
          imageRepository: imageRepository,
          yaloMessageRepository: yaloMessageRepository,
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
          bloc.add(ChatSendTextMessage());
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
        build: () => bloc,
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
        act: (bloc) => bloc.add(ChatSendTextMessage()),
        expect: () => [],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit nothing when messages consists only of spaces',
        build: () => bloc,
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
        act: (bloc) => bloc.add(ChatSendTextMessage()),
        expect: () => [],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should add a voice message successfully',
        build: () => bloc,
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
        act: (bloc) {
          when(() => chatMessageRepository.insertChatMessage(any())).thenAnswer(
            (_) async => Result.ok(
              ChatMessage.voice(
                id: 3,
                role: MessageRole.user,
                timestamp: fixedClock.now(),
                fileName: 'test.wav',
                amplitudes: [-13, -10, 0.0],
                duration: 3,
              ),
            ),
          );
          bloc.add(
            ChatSendVoiceMessage(
              audioData: AudioData(
                amplitudesFilePreview: [-13, -10, 0.0],
                fileName: 'test.wav',
                duration: 3,
              ),
            ),
          );
        },
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.messages[0],
            'last inserted message',
            equals(
              ChatMessage.voice(
                id: 3,
                role: MessageRole.user,
                timestamp: fixedClock.now(),
                fileName: 'test.wav',
                amplitudes: [-13, -10, 0.0],
                duration: 3,
              ),
            ),
          ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit an error when voice message insertion fails',
        build: () => bloc,
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
          ],
        ),
        act: (bloc) {
          when(
            () => chatMessageRepository.insertChatMessage(any()),
          ).thenAnswer((_) async => Result.error(Exception('test error')));
          bloc.add(
            ChatSendVoiceMessage(
              audioData: AudioData(
                amplitudesFilePreview: [-13, -10, 0.0],
                fileName: 'test.wav',
                duration: 3,
              ),
            ),
          );
        },
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.chatStatus,
            'chat status',
            equals(ChatStatus.failedMessageSent),
          ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should add a image message successfully',
        build: () => bloc,
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
        act: (bloc) {
          when(() => chatMessageRepository.insertChatMessage(any())).thenAnswer(
            (_) async => Result.ok(
              ChatMessage.image(
                id: 3,
                role: MessageRole.user,
                timestamp: fixedClock.now(),
                content: 'test',
                fileName: 'test.jpg',
              ),
            ),
          );
          final stubData = ImageData(path: 'test.jpg', mimeType: 'image/jpeg');
          when(() => imageRepository.saveImage(stubData)).thenAnswer(
            (_) async =>
                Result.ok(ImageData(path: 'test2.png', mimeType: 'image/png')),
          );

          when(
            () => imageRepository.deleteImage(stubData),
          ).thenAnswer((_) async => Result.ok(Unit()));
          bloc.add(ChatSendImageMessage(imageData: stubData, text: 'test'));
        },
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.messages[0],
            'last inserted message',
            equals(
              ChatMessage.image(
                id: 3,
                role: MessageRole.user,
                timestamp: fixedClock.now(),
                content: 'test',
                fileName: 'test.jpg',
              ),
            ),
          ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit an error when image message insertion fails',
        build: () => bloc,
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
          ],
        ),
        act: (bloc) {
          final stubData = ImageData(path: 'test.jpg', mimeType: 'image/jpeg');
          final newStubData = ImageData(
            path: 'test2.png',
            mimeType: 'image/png',
          );
          when(
            () => imageRepository.saveImage(stubData),
          ).thenAnswer((_) async => Result.ok(newStubData));
          when(
            () => chatMessageRepository.insertChatMessage(any()),
          ).thenAnswer((_) async => Result.error(Exception('test error')));

          when(
            () => imageRepository.deleteImage(newStubData),
          ).thenAnswer((_) async => Result.ok(Unit()));

          bloc.add(
            ChatSendImageMessage(
              imageData: ImageData(path: 'test.jpg', mimeType: 'image/jpeg'),
              text: 'teeest',
            ),
          );
        },
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.chatStatus,
            'chat status',
            equals(ChatStatus.failedMessageSent),
          ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should continue if deleting temporal image fails',
        build: () => bloc,
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
          ],
        ),
        act: (bloc) {
          when(() => chatMessageRepository.insertChatMessage(any())).thenAnswer(
            (_) async => Result.ok(
              ChatMessage.image(
                id: 3,
                role: MessageRole.user,
                timestamp: fixedClock.now(),
                content: 'test',
                fileName: 'test.jpg',
              ),
            ),
          );

          final stubData = ImageData(path: 'test.jpg', mimeType: 'image/jpeg');
          final newStubData = ImageData(
            path: 'test2.png',
            mimeType: 'image/png',
          );
          when(
            () => imageRepository.saveImage(stubData),
          ).thenAnswer((_) async => Result.ok(newStubData));

          when(() => imageRepository.deleteImage(stubData)).thenAnswer(
            (_) async => Result.error(Exception('Failed to delete temp image')),
          );

          bloc.add(
            ChatSendImageMessage(
              imageData: ImageData(path: 'test.jpg', mimeType: 'image/jpeg'),
              text: 'test',
            ),
          );
        },
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.messages[0],
            'last inserted message',
            equals(
              ChatMessage.image(
                id: 3,
                role: MessageRole.user,
                timestamp: fixedClock.now(),
                content: 'test',
                fileName: 'test.jpg',
              ),
            ),
          ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit an error when saving an image fails',
        build: () => bloc,
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
          ],
        ),
        act: (bloc) {
          when(() => imageRepository.saveImage(any())).thenAnswer(
            (_) async => Result<ImageData>.error(Exception('test error')),
          );

          bloc.add(
            ChatSendImageMessage(
              imageData: ImageData(path: 'test.jpg', mimeType: 'image/jpeg'),
              text: 'test',
            ),
          );
        },
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.chatStatus,
            'chat status',
            equals(ChatStatus.failedMessageSent),
          ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should still emit an error when the reversal operation of save image fails and the insertion fails',
        build: () => bloc,
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
        act: (bloc) {
          final stubData = ImageData(path: 'test.jpg', mimeType: 'image/jpeg');
          when(() => imageRepository.saveImage(stubData)).thenAnswer(
            (_) async =>
                Result.ok(ImageData(path: 'test2.png', mimeType: 'image/png')),
          );
          when(() => chatMessageRepository.insertChatMessage(any())).thenAnswer(
            (_) async => Result<ChatMessage>.error(Exception('test error')),
          );

          when(() => imageRepository.deleteImage(any())).thenAnswer(
            (_) async => Result<Unit>.error(Exception('leaking memory')),
          );
          bloc.add(ChatSendImageMessage(imageData: stubData, text: 'test'));
        },
        expect: () => [
          isA<MessagesState>().having(
            (state) => state.chatStatus,
            'chat status',
            equals(ChatStatus.failedMessageSent),
          ),
        ],
      );
    });

    group('fetch messages', () {
      var fixedClock = Clock.fixed(DateTime.now());
      blocTest<MessagesBloc, MessagesState>(
        'should fetch messages from repository and set them up correctly',
        build: () => MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          imageRepository: imageRepository,
          yaloMessageRepository: yaloMessageRepository,
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
        'fetch next page of messages until there are no more pages from repository and set them up correctly',
        build: () => MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          imageRepository: imageRepository,
          yaloMessageRepository: yaloMessageRepository,
          pageSize: 3,
        ),
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
        build: () => bloc,
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
        build: () => bloc,
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
        build: () => bloc,
        seed: () => MessagesState(userMessage: 'tres'),
        act: (bloc) => bloc.add(ChatUpdateUserMessage(value: 'tres')),
        expect: () => [],
      );
    });

    group('subscribe yalo messages', () {
      late StreamController<ChatMessage> fakeStream;
      var fixedClock = Clock.fixed(DateTime.now());
      setUp(() {
        fakeStream = StreamController();
      });

      tearDown(() {
        fakeStream.close();
      });

      blocTest<MessagesBloc, MessagesState>(
        'should receive assistant messages correctly',
        build: () => MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          imageRepository: imageRepository,
          yaloMessageRepository: yaloMessageRepository,
          clock: fixedClock,
        ),
        act: (bloc) {
          final chatMessageStub = ChatMessage(
            role: MessageRole.assistant,
            type: MessageType.text,
            content: 'Test message',
            timestamp: fixedClock.now(),
          );
          when(
            () => yaloMessageRepository.messages(),
          ).thenAnswer((_) => fakeStream.stream.asBroadcastStream());
          when(
            () => chatMessageRepository.insertChatMessage(chatMessageStub),
          ).thenAnswer((_) async => Result.ok(chatMessageStub.copyWith(id: 1)));
          bloc.add(ChatSubscribeToMessages());

          fakeStream.sink.add(chatMessageStub);
        },
        expect: () => [
          isA<MessagesState>().having(
            (s) => s.messages,
            'messages',
            contains(
              ChatMessage(
                id: 1,
                role: MessageRole.assistant,
                type: MessageType.text,
                content: 'Test message',
                timestamp: fixedClock.now(),
              ),
            ),
          ),
        ],
      );

      blocTest<MessagesBloc, MessagesState>(
        'should emit an error if the assistant message insertion fails',
        build: () => MessagesBloc(
          chatMessageRepository: chatMessageRepository,
          imageRepository: imageRepository,
          yaloMessageRepository: yaloMessageRepository,
          clock: fixedClock,
        ),
        act: (bloc) {
          final chatMessageStub = ChatMessage(
            role: MessageRole.assistant,
            type: MessageType.text,
            content: 'Test message',
            timestamp: fixedClock.now(),
          );
          when(
            () => yaloMessageRepository.messages(),
          ).thenAnswer((_) => fakeStream.stream.asBroadcastStream());
          when(
            () => chatMessageRepository.insertChatMessage(chatMessageStub),
          ).thenAnswer((_) async => Result.error(Exception('test exception')));
          bloc.add(ChatSubscribeToMessages());
          fakeStream.sink.add(chatMessageStub);
        },
        expect: () => [
          isA<MessagesState>().having(
            (s) => s.chatStatus,
            'chat status',
            equals(ChatStatus.failedToReceiveMessage),
          ),
        ],
      );
    });

    group('subscribe chat events', () {
      late StreamController<ChatEvent> fakeStream;
      setUp(() {
        fakeStream = StreamController();
      });

      tearDown(() {
        fakeStream.close();
      });

      blocTest<MessagesBloc, MessagesState>(
        'should emit status text when the repository sends start typing messages events from yalo message',
        build: () => bloc,
        act: (bloc) {
          when(
            () => yaloMessageRepository.events(),
          ).thenAnswer((_) => fakeStream.stream.asBroadcastStream());

          bloc.add(ChatSubscribeToEvents());

          fakeStream.sink.add(TypingStart(statusText: 'Writing a message..'));
          fakeStream.sink.add(TypingStop());
        },
        expect: () => [
          isA<MessagesState>()
              .having(
                (s) => s.isSystemTypingMessage,
                'typing flag',
                equals(true),
              )
              .having(
                (s) => s.chatStatusText,
                'chat status text',
                'Writing a message..',
              ),
          isA<MessagesState>()
              .having(
                (s) => s.isSystemTypingMessage,
                'typing flag',
                equals(false),
              )
              .having((s) => s.chatStatusText, 'chat status text', equals('')),
        ],
      );
    });

    group('clear messages', () {
      blocTest<MessagesBloc, MessagesState>(
        'should emit empty messages when chat cleared',
        build: () => bloc,
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
        build: () => bloc,
        act: (bloc) => bloc.add(ChatClearMessages()),
        expect: () => [],
      );
    });
  });
}
