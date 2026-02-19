// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:math';

import 'package:chat_flutter_sdk/domain/models/product/product.dart';
import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/image/image_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:clock/clock.dart';
import 'package:ecache/ecache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'messages_event.dart';
import 'messages_state.dart';

/// A Bloc for managing the chat messages in messages list
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final Clock blocClock;
  final ChatMessageRepository _chatMessageRepository;
  final ImageRepository _imageRepository;
  final YaloMessageRepository _yaloMessageRepository;
  final Logger log = Logger('ChatViewModel');

  MessagesBloc({
    String name = '',
    required ChatMessageRepository chatMessageRepository,
    required ImageRepository imageRepository,
    required YaloMessageRepository yaloMessageRepository,
    int pageSize = SdkConstants.defaultPageSize,
    Clock? clock,
  }) : blocClock = clock ?? Clock(),
       _chatMessageRepository = chatMessageRepository,
       _imageRepository = imageRepository,
       _yaloMessageRepository = yaloMessageRepository,
       super(
         MessagesState(
           isConnected: false,
           isSystemTypingMessage: false,
           chatTitle: name,
           pageInfo: PageInfo(pageSize: pageSize),
         ),
       ) {
    on<ChatLoadMessages>(_handleFetchMessages);
    on<ChatSubscribeToEvents>(_handleEventsSubscription);
    on<ChatSubscribeToMessages>(_handleMessagesSubscription);
    on<ChatUpdateUserMessage>(_handleUpdateUserMessage);
    on<ChatSendTextMessage>(_handleSendTextMessage);
    on<ChatSendVoiceMessage>(_handleSendVoiceMessage);
    on<ChatSendImageMessage>(_handleSendImageMessage);
    on<ChatClearMessages>(_handleClearMessages);
    on<ChatUpdateProductQuantity>(_handleUpdateProductQuantity);
    on<ChatToggleMessageExpand>(_handleToggleMessageExpand);
    on<ChatClearQuickReplies>(_handleClearQuickReplies);
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
            // FIXME: Create a new way to add messages preventing big copies
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

  // Subscribe to the yalo messages events stream
  Future<void> _handleEventsSubscription(
    ChatSubscribeToEvents event,
    Emitter<MessagesState> emit,
  ) async {
    log.info('Subscribing to yalo messages events channel');
    final yaloMessageEvents = _yaloMessageRepository.events();
    await emit.forEach(
      yaloMessageEvents,
      onData: (chatEvent) {
        log.fine('Received chat event $chatEvent');
        final result = switch (chatEvent) {
          TypingStart() => state.copyWith(
            isSystemTypingMessage: true,
            chatStatusText: chatEvent.statusText,
          ),
          TypingStop() => state.copyWith(
            isSystemTypingMessage: false,
            chatStatusText: '',
          ),
        };

        return result;
      },
    );
  }

  // Subscribes to the yalo messages, message stream
  Future<void> _handleMessagesSubscription(
    ChatSubscribeToMessages event,
    Emitter<MessagesState> emit,
  ) async {
    log.info('Subscribing to yalo message, messages stream');
    final yaloMessages = _yaloMessageRepository
        .messages()
        .asyncMap<ChatMessage>((message) async {
          assert(
            message.role == MessageRole.assistant,
            'Subscription must only receive assistant messages',
          );
          log.info('Inserting incoming chat message to db');
          final result = await _chatMessageRepository.insertChatMessage(
            message,
          );
          switch (result) {
            case Ok<ChatMessage>():
            return result.result;
            case Error<ChatMessage>():
            throw result.error;
          }
        });

    await emit.forEach(
      yaloMessages,
      onData: (chatMessage) {
        log.fine('Inserted message received with id ${chatMessage.id}');
        return state.copyWith(
          messages: [chatMessage, ...state.messages],
          quickReplies: chatMessage.quickReplies.isEmpty
              ? null
              : chatMessage.quickReplies,
        );
      },
      onError: (error, stackTrace) {
        log.severe('Unable to add chat message', error);
        return state.copyWith(chatStatus: ChatStatus.failedToReceiveMessage);
      },
    );
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
    final String trimmedMessage =
        event.text?.trim() ?? state.userMessage.trim();
    if (trimmedMessage.isEmpty) return;

    final messageToInsert = ChatMessage.text(
      role: MessageRole.user,
      content: trimmedMessage,
      timestamp: blocClock.now(),
    );
    Result<ChatMessage> result = await _chatMessageRepository.insertChatMessage(
      messageToInsert,
    );
    _yaloMessageRepository.sendMessage(messageToInsert);
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
    final messageToInsert = ChatMessage.voice(
      role: MessageRole.user,
      timestamp: blocClock.now(),
      fileName: event.audioData.fileName,
      amplitudes: event.audioData.amplitudesFilePreview,
      duration: event.audioData.duration,
    );
    Result<ChatMessage> result = await _chatMessageRepository.insertChatMessage(
      messageToInsert,
    );
    _yaloMessageRepository.sendMessage(messageToInsert);
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

    final messageToInsert = ChatMessage.image(
      role: MessageRole.user,
      timestamp: blocClock.now(),
      content: event.text,
      fileName: imageToInsert.path,
    );
    Result<ChatMessage> result = await _chatMessageRepository.insertChatMessage(
      messageToInsert,
    );

    _yaloMessageRepository.sendMessage(messageToInsert);
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

  // Handles the event to update product quantity.
  void _handleUpdateProductQuantity(
    ChatUpdateProductQuantity event,
    Emitter<MessagesState> emit,
  ) async {
    log.info(
      'Updating message with id ${event.messageId} with quantity ${event.quantity}',
    );
    final messageIndex = state.messages.indexWhere(
      (message) => message.id == event.messageId,
    );

    ChatMessage messageToUpdate = state.messages[messageIndex];
    assert(
      event.productSku != '',
      'Invalid product sku, sku must be a non empty string',
    );

    final productIndex = messageToUpdate.products.indexWhere(
      (p) => p.sku == event.productSku,
    );
    final product = messageToUpdate.products[productIndex];

    List<Product> newProducts = [...messageToUpdate.products];

    switch (event.unitType) {
      case UnitType.unit:
        newProducts[productIndex] = product.copyWith(
          unitsAdded: max(event.quantity, 0),
        );
        break;
      case UnitType.subunit:
        final subunitsAdded = max(event.quantity, 0);
        final subunitsMod = subunitsAdded % product.subunits;
        final extraUnits = subunitsAdded ~/ product.subunits;
        newProducts[productIndex] = product.copyWith(
          unitsAdded: product.unitsAdded + extraUnits,
          subunitsAdded: subunitsMod,
        );
        break;
    }

    List<ChatMessage> newMessages = [...state.messages];
    messageToUpdate = messageToUpdate.copyWith(products: newProducts);
    newMessages[messageIndex] = messageToUpdate;

    final updateResult = await _chatMessageRepository.replaceChatMessage(
      messageToUpdate,
    );
    switch (updateResult) {
      case Ok():
        log.info(
          'Message updated successfully, result: ${updateResult.result}',
        );
        emit(state.copyWith(messages: newMessages));
      case Error():
        log.info('Unable to update message', updateResult.error);
        emit(state.copyWith(chatStatus: ChatStatus.failedToUpdateMessage));
    }
  }

  // Handles toggle expand for messages
  void _handleToggleMessageExpand(
    ChatToggleMessageExpand event,
    Emitter<MessagesState> emit,
  ) {
    log.info('Expanding message with id ${event.messageId}');

    final messageIndex = state.messages.indexWhere(
      (m) => m.id == event.messageId,
    );

    if (messageIndex == -1) {
      log.warning('No msesage with id ${event.messageId} found');
      return;
    }

    final message = state.messages[messageIndex];

    final ChatMessage updatedMessage = message.copyWith(
      expand: !message.expand,
    );
    List<ChatMessage> newMessages = [...state.messages];
    newMessages[messageIndex] = updatedMessage;
    log.info('Message expanded successfully');
    emit(state.copyWith(messages: newMessages));
  }

  // Handles the removals of quick replies
  void _handleClearQuickReplies(
    ChatClearQuickReplies event,
    Emitter<MessagesState> emit,
  ) {
    log.info('Clearing quick replies from GUI');
    emit(state.copyWith(quickReplies: const []));
  }
}
