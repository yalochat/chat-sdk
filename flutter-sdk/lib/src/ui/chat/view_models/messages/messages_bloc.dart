// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cross_file/cross_file.dart';

import 'package:yalo_chat_flutter_sdk/domain/models/product/product.dart';
import 'package:yalo_chat_flutter_sdk/src/common/page.dart';
import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository.dart';
import 'package:yalo_chat_flutter_sdk/src/data/repositories/image/image_repository.dart';
import 'package:yalo_chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/button.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/constants.dart';
import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart' hide Page;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'messages_event.dart';
import 'messages_state.dart';

/// A Bloc for managing the chat messages in messages list
class MessagesBloc extends Bloc<MessagesEvent, MessagesState>
    with WidgetsBindingObserver {
  // Window between a user message being sent and the assistant reply we will
  // wait for before clearing the inline loading indicator.
  static const Duration awaitResponseTimeout = Duration(minutes: 1);

  final Clock blocClock;
  final ChatMessageRepository _chatMessageRepository;
  final ImageRepository _imageRepository;
  final YaloMessageRepository _yaloMessageRepository;
  // Optional context provided when the chat is opened. Forwarded to the
  // backend with the guidance card request so it can be tailored to where the
  // chat was launched from.
  final Map<String, dynamic>? _openContext;
  final Logger log = Logger('ChatViewModel');
  Timer? _awaitResponseTimer;
  // Ensures the guidance card is requested at most once per chat session, even
  // if the initial page is reloaded.
  bool _guidanceCardRequested = false;

  MessagesBloc({
    String name = '',
    required ChatMessageRepository chatMessageRepository,
    required ImageRepository imageRepository,
    required YaloMessageRepository yaloMessageRepository,
    Map<String, dynamic>? openContext,
    int pageSize = SdkConstants.defaultPageSize,
    Clock? clock,
  }) : blocClock = clock ?? Clock(),
       _chatMessageRepository = chatMessageRepository,
       _imageRepository = imageRepository,
       _yaloMessageRepository = yaloMessageRepository,
       _openContext = openContext,
       super(
         MessagesState(
           isConnected: false,
           isSystemTypingMessage: false,
           chatTitle: name,
           pageInfo: PageInfo(pageSize: pageSize),
         ),
       ) {
    WidgetsBinding.instance.addObserver(this);
    on<ChatLoadMessages>(_handleFetchMessages);
    on<ChatSubscribeToMessages>(_handleMessagesSubscription);
    on<ChatUpdateUserMessage>(_handleUpdateUserMessage);
    on<ChatSendTextMessage>(_handleSendTextMessage);
    on<ChatSendVoiceMessage>(_handleSendVoiceMessage);
    on<ChatSendImageMessage>(_handleSendImageMessage);
    on<ChatClearMessages>(_handleClearMessages);
    on<ChatRetryMessage>(_handleRetryMessage);
    on<ChatUpdateProductQuantity>(_handleUpdateProductQuantity);
    on<ChatAddProductToCart>(_handleAddProductToCart);
    on<ChatConfirmProductConfirmation>(_handleConfirmProductConfirmation);
    on<ChatToggleMessageExpand>(_handleToggleMessageExpand);
    on<ChatClearQuickReplies>(_handleClearQuickReplies);
    on<ChatAwaitResponseTimedOut>(_handleAwaitResponseTimedOut);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        log.info('App backgrounded, pausing polling');
        _yaloMessageRepository.pause();
      case AppLifecycleState.resumed:
        log.info('App foregrounded, resuming polling');
        _yaloMessageRepository.resume();
      default:
        break;
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _awaitResponseTimer?.cancel();
    return super.close();
  }

  // (Re)arms the timeout timer for the in-flight assistant reply. Callers are
  // expected to fold `isAwaitingResponse: true` into their own emit so that
  // only a single state change is published per send.
  void _scheduleAwaitTimeout() {
    _awaitResponseTimer?.cancel();
    _awaitResponseTimer = Timer(awaitResponseTimeout, () {
      if (isClosed) {
        return;
      }
      add(const ChatAwaitResponseTimedOut());
    });
  }

  // Cancels the timeout timer and clears the awaiting flag if it was set.
  void _stopAwaitingResponse(Emitter<MessagesState> emit) {
    _awaitResponseTimer?.cancel();
    _awaitResponseTimer = null;
    if (state.isAwaitingResponse) {
      emit(state.copyWith(isAwaitingResponse: false));
    }
  }

  void _handleAwaitResponseTimedOut(
    ChatAwaitResponseTimedOut event,
    Emitter<MessagesState> emit,
  ) {
    log.info('Await-response timer fired, clearing loading indicator');
    _stopAwaitingResponse(emit);
  }

  // Extracts the quick reply labels offered by a message, or an empty list when
  // the message is not an assistant message or carries no reply buttons.
  List<String> _quickRepliesFrom(ChatMessage message) {
    if (message.role != MessageRole.assistant) {
      return const [];
    }
    return message.buttons
        .where((b) => b.type == ButtonType.reply)
        .map((b) => b.text)
        .toList();
  }

  // Finds the quick replies that should currently show, scanning from the most
  // recent message. Assistant messages without reply buttons are skipped so the
  // last offered replies stay visible, but a user message clears them. Messages
  // arrive newest first.
  List<String> _quickRepliesFromHistory(List<ChatMessage> messages) {
    for (final ChatMessage message in messages) {
      if (message.role == MessageRole.user) {
        return const [];
      }
      final List<String> replies = _quickRepliesFrom(message);
      if (replies.isNotEmpty) {
        return replies;
      }
    }
    return const [];
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
        // FIXME: Create a new way to add messages preventing big copies
        final List<ChatMessage> messages = [
          ...state.messages,
          ...newMessages.result.data,
        ];
        // On the first load, surface the quick replies offered by the most
        // recent message that carries them so they survive closing and
        // reopening the chat. Pagination loads older messages, so it leaves the
        // replies untouched.
        final List<String> quickReplies =
            event.direction == PageDirection.initial && messages.isNotEmpty
            ? _quickRepliesFromHistory(messages)
            : state.quickReplies;
        emit(
          state.copyWith(
            chatStatus: ChatStatus.success,
            messages: messages,
            isLoading: false,
            quickReplies: quickReplies,
            pageInfo: newMessages.result.pageInfo.copyWith(
              prevCursor: state.pageInfo.cursor,
            ),
          ),
        );
        // On open, when the local database has no messages, ask the backend for
        // the guidance card to greet the user.
        if (event.direction == PageDirection.initial &&
            state.messages.isEmpty &&
            !_guidanceCardRequested) {
          _guidanceCardRequested = true;
          await _requestGuidanceCard();
        }
        break;
      case Error<Page<ChatMessage>>():
        emit(state.copyWith(chatStatus: ChatStatus.failure, isLoading: false));
        break;
    }
  }

  // Asks the backend for the guidance card. Failures are logged but do not
  // surface to the user, the chat simply stays empty.
  Future<void> _requestGuidanceCard() async {
    final String? context = _openContext != null
        ? jsonEncode(_openContext)
        : null;
    final Result<Unit> result = await _yaloMessageRepository
        .requestGuidanceCard(context: context);
    switch (result) {
      case Ok<Unit>():
        log.info('Guidance card requested');
      case Error<Unit>():
        log.severe('Unable to request guidance card', result.error);
    }
  }

  // Subscribes to the yalo messages, message stream. Incoming items are either
  // a regular ChatMessage (persisted and appended to the list) or a transient
  // ChatMessage.chatStatus that only updates the header.
  Future<void> _handleMessagesSubscription(
    ChatSubscribeToMessages event,
    Emitter<MessagesState> emit,
  ) async {
    log.info('Subscribing to yalo message, messages stream');
    final yaloMessages = _yaloMessageRepository
        .messages()
        .asyncMap<ChatMessage>((message) async {
          if (message.type == MessageType.chatStatus) {
            return message;
          }
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
        if (chatMessage.type == MessageType.chatStatus) {
          log.finest('Received chat status "${chatMessage.content}"');
          return state.copyWith(
            isSystemTypingMessage: chatMessage.content.isNotEmpty,
            chatStatusText: chatMessage.content,
          );
        }
        log.fine('Inserted message received with id ${chatMessage.id}');
        _awaitResponseTimer?.cancel();
        _awaitResponseTimer = null;
        // Quick replies persist until the user acts or a newer assistant
        // message offers its own. An assistant message without reply buttons
        // keeps the previously shown ones visible.
        final List<String> incomingReplies = _quickRepliesFrom(chatMessage);
        return state.copyWith(
          messages: [chatMessage, ...state.messages],
          quickReplies: incomingReplies.isNotEmpty
              ? incomingReplies
              : state.quickReplies,
          isAwaitingResponse: false,
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

    switch (result) {
      case Ok<ChatMessage>():
        log.info('Text message inserted successfully, id ${result.result.id}');
        _scheduleAwaitTimeout();
        emit(
          state.copyWith(
            // FIXME: Create a new way to track big message list copies
            messages: [result.result, ...state.messages],
            userMessage: '',
            isAwaitingResponse: true,
            quickReplies: const [],
          ),
        );
        final sendResult = await _yaloMessageRepository.sendMessage(
          result.result,
        );
        switch (sendResult) {
          case Ok():
            log.info('Text message sent successfully');
          case Error():
            log.severe('Failed to send text message', sendResult.error);
            await _markMessageAsError(result.result, emit);
        }
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
    int byteCount;
    try {
      byteCount = await XFile(event.audioData.fileName).length();
    } catch (e) {
      log.warning('Unable to get byte count for voice file', e);
      byteCount = 0;
    }
    final messageToInsert = ChatMessage.voice(
      role: MessageRole.user,
      timestamp: blocClock.now(),
      fileName: event.audioData.fileName,
      amplitudes: event.audioData.amplitudesFilePreview,
      duration: event.audioData.duration,
      byteCount: byteCount,
      mediaType: 'audio/wav',
    );
    Result<ChatMessage> result = await _chatMessageRepository.insertChatMessage(
      messageToInsert,
    );

    switch (result) {
      case Ok<ChatMessage>():
        log.info('Voice message inserted successfully, id ${result.result.id}');
        _scheduleAwaitTimeout();
        emit(
          state.copyWith(
            messages: [result.result, ...state.messages],
            isAwaitingResponse: true,
            quickReplies: const [],
          ),
        );
        final sendResult = await _yaloMessageRepository.sendMessage(
          result.result,
        );
        switch (sendResult) {
          case Ok():
            log.info('Voice message sent successfully');
          case Error():
            log.severe('Failed to send voice message', sendResult.error);
            await _markMessageAsError(result.result, emit);
        }
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
      byteCount: imageToInsert.bytes.length,
      mediaType: imageToInsert.mimeType,
    );
    Result<ChatMessage> result = await _chatMessageRepository.insertChatMessage(
      messageToInsert,
    );

    switch (result) {
      case Ok<ChatMessage>():
        log.info('Image message inserted successfully, id ${result.result.id}');
        _scheduleAwaitTimeout();
        emit(
          state.copyWith(
            messages: [result.result, ...state.messages],
            userMessage: '',
            isAwaitingResponse: true,
            quickReplies: const [],
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
        final sendResult = await _yaloMessageRepository.sendMessage(
          result.result,
        );
        switch (sendResult) {
          case Ok():
            log.info('Image message sent successfully');
          case Error():
            log.severe('Failed to send image message', sendResult.error);
            await _markMessageAsError(result.result, emit);
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

  // Flags a previously inserted user message as failed to deliver, both in
  // memory and in the local data source so the error survives reloads. Also
  // cancels the await-response timer (a failed delivery has no incoming reply
  // to wait for) and clears the loading flag in the same emit.
  Future<void> _markMessageAsError(
    ChatMessage message,
    Emitter<MessagesState> emit,
  ) async {
    final int index = state.messages.indexWhere((m) => m.id == message.id);
    if (index == -1) {
      log.warning('Unable to find message ${message.id} to mark as error');
      return;
    }
    final ChatMessage updatedMessage = state.messages[index].copyWith(
      status: MessageStatus.error,
    );
    final List<ChatMessage> newMessages = [...state.messages];
    newMessages[index] = updatedMessage;
    _awaitResponseTimer?.cancel();
    _awaitResponseTimer = null;
    emit(state.copyWith(messages: newMessages, isAwaitingResponse: false));

    final persistResult = await _chatMessageRepository.replaceChatMessage(
      updatedMessage,
    );
    switch (persistResult) {
      case Ok():
        log.info('Persisted error status for message ${message.id}');
        break;
      case Error():
        log.severe(
          'Unable to persist error status for message ${message.id}',
          persistResult.error,
        );
        break;
    }
  }

  // Retries delivery of a previously failed user message. Only messages with
  // MessageStatus.error are retried; other statuses are ignored.
  Future<void> _handleRetryMessage(
    ChatRetryMessage event,
    Emitter<MessagesState> emit,
  ) async {
    final int index = state.messages.indexWhere((m) => m.id == event.messageId);
    if (index == -1) {
      log.warning('Unable to find message ${event.messageId} to retry');
      return;
    }
    final ChatMessage message = state.messages[index];
    if (message.status != MessageStatus.error) {
      log.fine(
        'Skipping retry for message ${event.messageId}, status ${message.status}',
      );
      return;
    }

    final ChatMessage retrying = message.copyWith(
      status: MessageStatus.inProgress,
    );
    final List<ChatMessage> newMessages = [...state.messages];
    newMessages[index] = retrying;
    _scheduleAwaitTimeout();
    emit(state.copyWith(messages: newMessages, isAwaitingResponse: true));

    final persistResult = await _chatMessageRepository.replaceChatMessage(
      retrying,
    );
    switch (persistResult) {
      case Ok():
        log.info('Persisted retry status for message ${event.messageId}');
        break;
      case Error():
        log.severe(
          'Unable to persist retry status for message ${event.messageId}',
          persistResult.error,
        );
        break;
    }

    final sendResult = await _yaloMessageRepository.sendMessage(retrying);
    switch (sendResult) {
      case Ok():
        log.info('Retry succeeded for message ${event.messageId}');
        break;
      case Error():
        log.severe(
          'Retry failed for message ${event.messageId}',
          sendResult.error,
        );
        await _markMessageAsError(retrying, emit);
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

  // Marks a product as in the cart and forwards its absolute units and
  // subunits to the active cart as an update cart product request.
  Future<void> _handleAddProductToCart(
    ChatAddProductToCart event,
    Emitter<MessagesState> emit,
  ) async {
    final int messageIndex = state.messages.indexWhere(
      (message) => message.id == event.messageId,
    );
    if (messageIndex == -1) {
      log.warning('No message with id ${event.messageId} found');
      return;
    }
    final ChatMessage message = state.messages[messageIndex];
    final int productIndex = message.products.indexWhere(
      (p) => p.sku == event.productSku,
    );
    if (productIndex == -1) {
      log.warning(
        'No product with sku ${event.productSku} found '
        'in message ${event.messageId}',
      );
      return;
    }
    final Product product = message.products[productIndex].copyWith(
      inCart: true,
    );

    final List<Product> newProducts = [...message.products];
    newProducts[productIndex] = product;
    final ChatMessage updatedMessage = message.copyWith(products: newProducts);
    final List<ChatMessage> newMessages = [...state.messages];
    newMessages[messageIndex] = updatedMessage;

    final persistResult = await _chatMessageRepository.replaceChatMessage(
      updatedMessage,
    );
    switch (persistResult) {
      case Ok():
        emit(state.copyWith(messages: newMessages));
      case Error():
        log.severe('Unable to persist cart state', persistResult.error);
        emit(state.copyWith(chatStatus: ChatStatus.failedToUpdateMessage));
        return;
    }

    final sendResult = await _yaloMessageRepository.updateCartProduct(
      product.sku,
      product.unitsAdded,
      product.subunitsAdded,
    );
    if (sendResult case Error(:final error)) {
      log.severe('Unable to send updateCartProduct', error);
    }
  }

  // Marks a product confirmation card as confirmed and forwards the product's
  // units to the active cart. No-op if the card was already confirmed.
  Future<void> _handleConfirmProductConfirmation(
    ChatConfirmProductConfirmation event,
    Emitter<MessagesState> emit,
  ) async {
    final int index = state.messages.indexWhere(
      (message) => message.id == event.messageId,
    );
    if (index == -1) {
      log.warning('No confirmation message with id ${event.messageId} found');
      return;
    }
    final ChatMessage message = state.messages[index];
    if (message.status == MessageStatus.clicked) {
      log.info('Confirmation ${event.messageId} already confirmed');
      return;
    }
    if (message.products.isEmpty) {
      log.warning('Confirmation ${event.messageId} has no product to confirm');
      return;
    }

    final ChatMessage confirmed = message.copyWith(
      status: MessageStatus.clicked,
    );
    final List<ChatMessage> newMessages = [...state.messages];
    newMessages[index] = confirmed;
    emit(state.copyWith(messages: newMessages));

    final persistResult = await _chatMessageRepository.replaceChatMessage(
      confirmed,
    );
    switch (persistResult) {
      case Ok():
        log.info('Persisted confirmation for message ${event.messageId}');
      case Error():
        log.severe(
          'Unable to persist confirmation for message ${event.messageId}',
          persistResult.error,
        );
    }

    final Product product = confirmed.products.first;
    await _yaloMessageRepository.updateCartProduct(
      product.sku,
      product.unitsAdded,
      product.subunitsAdded,
    );
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
