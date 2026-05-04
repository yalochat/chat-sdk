// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:ecache/ecache.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/repositories/yalo_message/sdk_message_mapper.dart';
import 'package:yalo_chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_media/yalo_media_service.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service_websocket.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart'
    as proto;
import 'package:yalo_chat_flutter_sdk/yalo_sdk.dart';

final class YaloMessageRepositoryWebSocket implements YaloMessageRepository {
  final StreamController<ChatMessage> _messagesStreamController =
      StreamController<ChatMessage>.broadcast();
  final StreamController<ChatEvent> _typingEventsStreamController =
      StreamController<ChatEvent>.broadcast();
  final cache = SimpleCache<String, bool>(capacity: 500);

  final YaloChatClient yaloChatClient;
  final YaloMessageServiceWebSocket websocketService;
  final YaloMessageService messageService;
  final YaloMediaService mediaService;
  final Future<Directory> Function() _directory;
  final Logger log = Logger('YaloMessageRepositoryWebSocket');

  StreamSubscription<proto.PollMessageItem>? _subscription;
  bool _paused = false;

  YaloMessageRepositoryWebSocket({
    required this.yaloChatClient,
    required this.websocketService,
    required this.messageService,
    required this.mediaService,
    Future<Directory> Function()? directory,
  }) : _directory = directory ?? getTemporaryDirectory;

  @override
  Stream<ChatMessage> messages() {
    _subscribe();
    return _messagesStreamController.stream;
  }

  @override
  Stream<ChatEvent> events() => _typingEventsStreamController.stream;

  void _subscribe() {
    if (_subscription != null || _paused) return;
    _subscription = websocketService.messages().listen(
      _onItem,
      onError: (Object error) {
        log.severe('WebSocket stream error', error);
        if (!_typingEventsStreamController.isClosed) {
          _typingEventsStreamController.sink.add(TypingStop());
        }
      },
    );
  }

  Future<void> _onItem(proto.PollMessageItem item) async {
    final ChatMessage? message = await pollMessageItemToChatMessage(
      item,
      mediaService: mediaService,
      directory: _directory,
    );
    if (message == null) return;
    if (message.wiId == null || cache.get(message.wiId!) != null) return;
    cache.set(message.wiId!, true);
    if (_typingEventsStreamController.isClosed ||
        _messagesStreamController.isClosed) {
      return;
    }
    _typingEventsStreamController.sink.add(TypingStop());
    _messagesStreamController.sink.add(message);
  }

  @override
  Future<Result<Unit>> sendMessage(ChatMessage chatMessage) async {
    _typingEventsStreamController.sink.add(
      TypingStart(statusText: 'Writing message...'),
    );
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
    return websocketService.sendSdkMessage(requestToSend);
  }

  @override
  Future<Result<Unit>> addToCart(String sku, double quantity) async {
    final ChatCommandCallback? callback =
        yaloChatClient.commands[ChatCommand.addToCart];
    if (callback != null) {
      callback({'sku': sku, 'quantity': quantity});
      return Result.ok(Unit());
    }
    return messageService.addToCart(sku, quantity);
  }

  @override
  Future<Result<Unit>> removeFromCart(String sku, {double? quantity}) async {
    final ChatCommandCallback? callback =
        yaloChatClient.commands[ChatCommand.removeFromCart];
    if (callback != null) {
      callback({'sku': sku, 'quantity': quantity});
      return Result.ok(Unit());
    }
    return messageService.removeFromCart(sku, quantity: quantity);
  }

  @override
  Future<Result<Unit>> clearCart() async {
    final ChatCommandCallback? callback =
        yaloChatClient.commands[ChatCommand.clearCart];
    if (callback != null) {
      callback(null);
      return Result.ok(Unit());
    }
    return messageService.clearCart();
  }

  @override
  Future<Result<Unit>> addPromotion(String promotionId) async {
    final ChatCommandCallback? callback =
        yaloChatClient.commands[ChatCommand.addPromotion];
    if (callback != null) {
      callback({'promotionId': promotionId});
      return Result.ok(Unit());
    }
    return messageService.addPromotion(promotionId);
  }

  @override
  void pause() {
    log.info('Subscription paused');
    _paused = true;
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void resume() {
    if (!_paused) return;
    log.info('Subscription resumed');
    _paused = false;
    _subscribe();
  }

  @override
  void dispose() {
    _paused = false;
    _subscription?.cancel();
    _subscription = null;
    if (!_messagesStreamController.isClosed) {
      _messagesStreamController.close();
    }
    if (!_typingEventsStreamController.isClosed) {
      _typingEventsStreamController.close();
    }
  }
}
