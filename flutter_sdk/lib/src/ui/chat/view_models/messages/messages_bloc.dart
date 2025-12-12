// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/image/image_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'messages_event.dart';
import 'messages_state.dart';

/// A Bloc for managing the chat state of the Chat Widget of the SDK.
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final Clock blocClock;
  final ChatMessageRepository _chatMessageRepository;
  final ImageRepository _imageRepository;
  final Logger log = Logger('ChatViewModel');

  MessagesBloc({
    String name = '',
    required ChatMessageRepository chatMessageRepository,
    required ImageRepository imageRepository,
    int pageSize = SdkConstants.defaultPageSize,
    Clock? clock,
  }) : blocClock = clock ?? Clock(),
       _chatMessageRepository = chatMessageRepository,
       _imageRepository = imageRepository,
       super(
         MessagesState(
           isConnected: false,
           isSystemTypingMessage: false,
           chatTitle: name,
           pageInfo: PageInfo(pageSize: pageSize),
         ),
       ) {
    on<ChatLoadMessages>(_handleFetchMessages);
    on<ChatStartTyping>(_handleStartTyping);
    on<ChatStopTyping>(_handleStopTyping);
    on<ChatUpdateUserMessage>(_handleUpdateUserMessage);
    on<ChatSendTextMessage>(_handleSendTextMessage);
    on<ChatSendVoiceMessage>(_handleSendVoiceMessage);
    on<ChatSendImageMessage>(_handleSendImageMessage);
    on<ChatClearMessages>(_handleClearMessages);
  }

  // Event that handles the pagination of messages
  Future<void> _handleFetchMessages(
    ChatLoadMessages event,
    Emitter<MessagesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    int? cursor;
    switch (event.direction) {
      case PageDirection.next:
        cursor = state.pageInfo.nextCursor;
        // No more pages
        if (cursor == null) {
          emit(state.copyWith(isLoading: false));
          return;
        }
      case PageDirection.initial:
      // Keep the cursor null
    }

    Result<Page<ChatMessage>> newMessages = await _chatMessageRepository
        .getChatMessagePageDesc(cursor, state.pageInfo.pageSize);
    switch (newMessages) {
      case Ok<Page<ChatMessage>>():
        emit(
          state.copyWith(
            chatStatus: ChatStatus.success,
            // FIXME: Create a new way to track big message list copies
            messages: [...state.messages, ...newMessages.result.data],
            isLoading: false,
            pageInfo: newMessages.result.pageInfo.copyWith(
              prevCursor: state.pageInfo.cursor,
            ),
          ),
        );
        break;
      case Error<Page<ChatMessage>>():
        emit(state.copyWith(chatStatus: ChatStatus.failure, isLoading: false));
        break;
    }
  }

  // Handles the event when the assistant starts typing.
  void _handleStartTyping(ChatStartTyping event, Emitter<MessagesState> emit) {
    if (!state.isSystemTypingMessage) {
      emit(
        state.copyWith(
          isSystemTypingMessage: true,
          chatStatusText: event.chatStatusText,
        ),
      );
    }
  }

  // Handles the event when the assistant stops typing.
  void _handleStopTyping(ChatStopTyping event, Emitter<MessagesState> emit) {
    if (state.isSystemTypingMessage) {
      emit(state.copyWith(isSystemTypingMessage: false, chatStatusText: ''));
    }
  }

  // Handles the event to update the user message
  void _handleUpdateUserMessage(
    ChatUpdateUserMessage event,
    Emitter<MessagesState> emit,
  ) {
    if (event.value != state.userMessage) {
      emit(state.copyWith(userMessage: event.value));
    }
  }

  // Handles the event when the user sends a text message
  Future<void> _handleSendTextMessage(
    ChatSendTextMessage event,
    Emitter<MessagesState> emit,
  ) async {
    log.info('Inserting text message');
    final String trimmedMessage = state.userMessage.trim();
    if (trimmedMessage.isEmpty) return;

    Result<ChatMessage> result = await _chatMessageRepository.insertChatMessage(
      ChatMessage.text(
        role: MessageRole.user,
        content: trimmedMessage,
        timestamp: blocClock.now(),
      ),
    );

    switch (result) {
      case Ok<ChatMessage>():
        log.info('Text message inserted successfully, id ${result.result.id}');
        emit(
          state.copyWith(
            // FIXME: Create a new way to track big message list copies
            messages: [result.result, ...state.messages],
            userMessage: '',
          ),
        );
        break;
      case Error<ChatMessage>():
        log.severe('Unable to insert text message', result.error);
        emit(state.copyWith(chatStatus: ChatStatus.failedMessageSent));
        break;
    }
  }

  // Handles sending voice messages
  Future<void> _handleSendVoiceMessage(
    ChatSendVoiceMessage event,
    Emitter<MessagesState> emit,
  ) async {
    log.info('Inserting voice message');
    Result<ChatMessage> result = await _chatMessageRepository.insertChatMessage(
      ChatMessage.voice(
        role: MessageRole.user,
        timestamp: blocClock.now(),
        fileName: event.audioData.fileName,
        amplitudes: event.audioData.amplitudesFilePreview,
        duration: event.audioData.duration,
      ),
    );
    switch (result) {
      case Ok<ChatMessage>():
        log.info('Voice message inserted successfully, id ${result.result.id}');
        emit(state.copyWith(messages: [result.result, ...state.messages]));
        break;
      case Error<ChatMessage>():
        log.severe('Failed to insert voice message', result.error);
        emit(state.copyWith(chatStatus: ChatStatus.failedMessageSent));
        break;
    }
  }

  // Handles sending image messages
  Future<void> _handleSendImageMessage(
    ChatSendImageMessage event,
    Emitter<MessagesState> emit,
  ) async {
    log.info('Inserting image message');
    ImageData imageToInsert;
    final imageData = await _imageRepository.saveImage(event.imageData);
    switch (imageData) {
      case Ok():
        log.info('Image saved successfully');
        imageToInsert = imageData.result;
        break;
      case Error():
        log.severe('Unable to permanently store image', imageData.error);
        emit(state.copyWith(chatStatus: ChatStatus.failedMessageSent));
        return;
    }

    Result<ChatMessage> result = await _chatMessageRepository.insertChatMessage(
      ChatMessage.image(
        role: MessageRole.user,
        timestamp: blocClock.now(),
        content: event.text,
        fileName: imageToInsert.path,
      ),
    );
    switch (result) {
      case Ok<ChatMessage>():
        log.info('Image message inserted successfully, id ${result.result.id}');
        emit(
          state.copyWith(
            messages: [result.result, ...state.messages],
            userMessage: '',
          ),
        );
        // free space from temporal space
        final deleteTmpImage = await _imageRepository.deleteImage(
          event.imageData,
        );
        switch (deleteTmpImage) {
          case Ok():
            log.info('Image removed from cache');
            break;
          case Error():
            log.severe('Unable to clean image from cache');
        }
        break;
      case Error<ChatMessage>():
        log.severe('Failed to insert voice message', result.error);
        final deleteImageRes = await _imageRepository.deleteImage(
          imageToInsert,
        );
        switch (deleteImageRes) {
          case Ok():
            log.info('Reverted storage from image');
            break;
          case Error():
            log.severe('Unable to delete image from disk, leaking memory');
            break;
        }
        emit(state.copyWith(chatStatus: ChatStatus.failedMessageSent));
        break;
    }
  }

  // Handles the event to clear messages.
  void _handleClearMessages(
    ChatClearMessages event,
    Emitter<MessagesState> emit,
  ) {
    if (state.messages.isEmpty) return;
    emit(state.copyWith(messages: []));
    // TODO: Add the repository to clear messages
  }
}
