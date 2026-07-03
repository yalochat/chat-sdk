// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:ecache/ecache.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:yalo_chat_flutter_sdk/src/common/exceptions/state_exception.dart';
import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/repositories/yalo_message/sdk_message_mapper.dart';
import 'package:yalo_chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_media/yalo_media_service.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart'
    as proto;
import 'package:yalo_chat_flutter_sdk/yalo_sdk.dart';

final class YaloMessageRepositoryRemote implements YaloMessageRepository {
  final StreamController<ChatMessage> _messagesStreamController =
      StreamController<ChatMessage>.broadcast();
  final cache = SimpleCache<String, bool>(capacity: 500);
  // Safety net: if the backend leaves the chat status non-empty and goes
  // silent (no further messages of any kind), drop the header after this delay.
  final Duration chatStatusTimeout;
  Timer? _chatStatusTimer;

  final YaloChatClient yaloChatClient;
  final YaloMessageService messageService;
  final YaloMediaService mediaService;
  final Future<Directory> Function() _directory;
  final Logger log = Logger('YaloMessageRepositoryRemote');

  StreamSubscription<proto.PollMessageItem>? _subscription;
  bool _paused = false;

  YaloMessageRepositoryRemote({
    required this.yaloChatClient,
    required this.messageService,
    required this.mediaService,
    Future<Directory> Function()? directory,
    this.chatStatusTimeout = const Duration(seconds: 15),
  }) : _directory = directory ?? getTemporaryDirectory;

  // A non-empty chat status arms a timer that clears the chat status if the
  // backend goes silent; any subsequent emission cancels it.
  void _emit(ChatMessage message) {
    if (_messagesStreamController.isClosed) {
      return;
    }
    _messagesStreamController.sink.add(message);
    _chatStatusTimer?.cancel();
    _chatStatusTimer = null;
    if (message.type == MessageType.chatStatus && message.content.isNotEmpty) {
      _chatStatusTimer = Timer(chatStatusTimeout, () {
        if (_messagesStreamController.isClosed) {
          return;
        }
        _messagesStreamController.sink.add(
          ChatMessage.chatStatus(timestamp: DateTime.now()),
        );
      });
    }
  }

  @override
  Stream<ChatMessage> messages() {
    _subscribe();
    return _messagesStreamController.stream;
  }

  void _subscribe() {
    if (_subscription != null || _paused) {
      return;
    }
    _subscription = messageService.messages().listen(
      _onItem,
      onError: (Object error) {
        log.severe('Message stream error', error);
        _emit(ChatMessage.chatStatus(timestamp: DateTime.now()));
      },
    );
  }

  Future<void> _onItem(proto.PollMessageItem item) async {
    if (item.message.hasCustomCommandRequest()) {
      await _handleCustomCommand(item.message);
      return;
    }
    final ChatMessage? message = await pollMessageItemToChatMessage(
      item,
      mediaService: mediaService,
      directory: _directory,
    );
    if (message == null) {
      return;
    }
    if (message.type == MessageType.chatStatus) {
      _emit(message);
      return;
    }
    if (message.wiId == null || cache.get(message.wiId!) != null) {
      return;
    }
    cache.set(message.wiId!, true);
    _emit(ChatMessage.chatStatus(timestamp: DateTime.now()));
    _emit(message);
  }

  // Looks up a handler registered by the consumer for the request's command id.
  // If found, runs it and replies with the result; otherwise logs a warning and
  // sends nothing.
  Future<void> _handleCustomCommand(proto.SdkMessage message) async {
    final proto.CustomCommandRequest request = message.customCommandRequest;
    final CustomCommandCallback? handler =
        yaloChatClient.commands[request.commandId] as CustomCommandCallback?;
    if (handler == null) {
      log.warning('Received unregistered command: ${request.commandId}');
      return;
    }
    try {
      final String payload = await handler(request.payload) ?? '';
      await _sendCustomCommandResponse(
        message.correlationId,
        proto.ResponseStatus.RESPONSE_STATUS_SUCCESS,
        payload,
      );
    } catch (error) {
      log.severe('Custom command handler threw: ${request.commandId}', error);
      await _sendCustomCommandResponse(
        message.correlationId,
        proto.ResponseStatus.RESPONSE_STATUS_ERROR,
        '',
      );
    }
  }

  Future<void> _sendCustomCommandResponse(
    String correlationId,
    proto.ResponseStatus status,
    String payload,
  ) async {
    final DateTime timestamp = DateTime.now();
    final proto.SdkMessage response = proto.SdkMessage(
      correlationId: correlationId,
      timestamp: Timestamp.fromDateTime(timestamp),
      customCommandResponse: proto.CustomCommandResponse(
        status: status,
        payload: payload,
        timestamp: Timestamp.fromDateTime(timestamp),
      ),
    );
    final Result<Unit> result = await messageService.sendSdkMessage(response);
    if (result case Error(:final error)) {
      log.severe('Unable to send custom command response', error);
    }
  }

  @override
  Future<Result<Unit>> sendMessage(ChatMessage chatMessage) async {
    String? mediaId;
    if (chatMessage.type == MessageType.image ||
        chatMessage.type == MessageType.voice ||
        chatMessage.type == MessageType.video) {
      final uploadResult = await mediaService.uploadMedia(
        XFile(chatMessage.fileName!),
      );
      switch (uploadResult) {
        case Ok(:final result):
          mediaId = result.id;
        case Error(:final error):
          log.severe('Unable to upload media', error);
          return Result.error(error);
      }
    }

    final requestToSend = chatMessageToSdkMessage(
      chatMessage,
      mediaId: mediaId,
    );
    if (requestToSend == null) {
      return Result.error(FormatException('Message type is yet not supported'));
    }
    return messageService.sendSdkMessage(requestToSend);
  }

  @override
  Future<Result<Unit>> addToCart(String sku, double quantity) async {
    final ChatCommandCallback? callback =
        yaloChatClient.commands[ChatCommand.addToCart] as ChatCommandCallback?;
    if (callback != null) {
      callback({'sku': sku, 'quantity': quantity});
      return Result.ok(Unit());
    }
    final DateTime timestamp = DateTime.now();
    final proto.SdkMessage request = proto.SdkMessage(
      correlationId: 'add-to-cart-$sku-${timestamp.millisecondsSinceEpoch}',
      timestamp: Timestamp.fromDateTime(timestamp),
      addToCartRequest: proto.AddToCartRequest(
        sku: sku,
        quantity: quantity,
        timestamp: Timestamp.fromDateTime(timestamp),
      ),
    );
    return messageService.sendSdkMessage(request);
  }

  @override
  Future<Result<Unit>> removeFromCart(String sku, {double? quantity}) async {
    final ChatCommandCallback? callback =
        yaloChatClient.commands[ChatCommand.removeFromCart]
            as ChatCommandCallback?;
    if (callback != null) {
      callback({'sku': sku, 'quantity': quantity});
      return Result.ok(Unit());
    }
    final DateTime timestamp = DateTime.now();
    final proto.RemoveFromCartRequest removeRequest =
        proto.RemoveFromCartRequest(
          sku: sku,
          timestamp: Timestamp.fromDateTime(timestamp),
        );
    if (quantity != null) {
      removeRequest.quantity = quantity;
    }
    final proto.SdkMessage request = proto.SdkMessage(
      correlationId:
          'remove-from-cart-$sku-${timestamp.millisecondsSinceEpoch}',
      timestamp: Timestamp.fromDateTime(timestamp),
      removeFromCartRequest: removeRequest,
    );
    return messageService.sendSdkMessage(request);
  }

  @override
  Future<Result<Unit>> updateCartProduct(
    String sku,
    double units,
    double subunits,
  ) async {
    final ChatCommandCallback? callback =
        yaloChatClient.commands[ChatCommand.updateCartProduct]
            as ChatCommandCallback?;
    if (callback != null) {
      callback({'sku': sku, 'units': units, 'subunits': subunits});
      return Result.ok(Unit());
    }
    final DateTime timestamp = DateTime.now();
    final proto.SdkMessage request = proto.SdkMessage(
      correlationId:
          'update-cart-product-$sku-${timestamp.millisecondsSinceEpoch}',
      timestamp: Timestamp.fromDateTime(timestamp),
      updateCartProductRequest: proto.UpdateCartProductRequest(
        sku: sku,
        units: units,
        subunits: subunits,
        timestamp: Timestamp.fromDateTime(timestamp),
      ),
    );
    return messageService.sendSdkMessage(request);
  }

  @override
  Future<Result<Unit>> clearCart() async {
    final ChatCommandCallback? callback =
        yaloChatClient.commands[ChatCommand.clearCart] as ChatCommandCallback?;
    if (callback != null) {
      callback(null);
      return Result.ok(Unit());
    }
    final DateTime timestamp = DateTime.now();
    final proto.SdkMessage request = proto.SdkMessage(
      correlationId: 'clear-cart-${timestamp.millisecondsSinceEpoch}',
      timestamp: Timestamp.fromDateTime(timestamp),
      clearCartRequest: proto.ClearCartRequest(
        timestamp: Timestamp.fromDateTime(timestamp),
      ),
    );
    return messageService.sendSdkMessage(request);
  }

  @override
  Future<Result<Unit>> addPromotion(String promotionId) async {
    final DateTime timestamp = DateTime.now();
    final proto.SdkMessage request = proto.SdkMessage(
      correlationId:
          'add-promotion-$promotionId-${timestamp.millisecondsSinceEpoch}',
      timestamp: Timestamp.fromDateTime(timestamp),
      addPromotionRequest: proto.AddPromotionRequest(
        promotionId: promotionId,
        timestamp: Timestamp.fromDateTime(timestamp),
      ),
    );
    return messageService.sendSdkMessage(request);
  }

  @override
  Future<Result<Unit>> goToCart() async {
    final ChatCommandCallback? callback =
        yaloChatClient.commands[ChatCommand.goToCart] as ChatCommandCallback?;
    if (callback != null) {
      callback(null);
      return Result.ok(Unit());
    }
    log.warning('No goToCart command registered');
    return Result.error(StateException('No goToCart command registered'));
  }

  @override
  Future<Result<Unit>> requestGuidanceCard({String? context}) async {
    final DateTime timestamp = DateTime.now();
    final proto.SdkMessage request = proto.SdkMessage(
      correlationId: 'guidance-card-${timestamp.millisecondsSinceEpoch}',
      timestamp: Timestamp.fromDateTime(timestamp),
      guidanceCardRequest: proto.GuidanceCardRequest(
        timestamp: Timestamp.fromDateTime(timestamp),
        context: context,
      ),
    );
    return messageService.sendSdkMessage(request);
  }

  @override
  void pause() {
    log.info('Subscription paused');
    _paused = true;
    _subscription?.cancel();
    _subscription = null;
    _chatStatusTimer?.cancel();
    _chatStatusTimer = null;
    messageService.pause();
  }

  @override
  void resume() {
    if (!_paused) {
      return;
    }
    log.info('Subscription resumed');
    _paused = false;
    messageService.resume();
    _subscribe();
  }

  @override
  void dispose() {
    _paused = false;
    _subscription?.cancel();
    _subscription = null;
    _chatStatusTimer?.cancel();
    _chatStatusTimer = null;
    messageService.dispose();
    if (!_messagesStreamController.isClosed) {
      _messagesStreamController.close();
    }
  }
}
