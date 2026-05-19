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
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/yalo_sdk.dart';

final class YaloMessageRepositoryRemote implements YaloMessageRepository {
  final StreamController<ChatMessage> _messagesStreamController =
      StreamController();
  bool polling = false;
  bool _paused = false;
  final int pollingRate = 1;
  final int pollingRateWindow = 5;
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

  Future<void> _startPolling() async {
    polling = true;
    while (polling) {
      final timestamp =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - pollingRateWindow;
      final newMessagesResult = await messageService.fetchMessages(timestamp);
      switch (newMessagesResult) {
        case Ok():
          final sorted = newMessagesResult.result.toList()
            ..sort(
              (a, b) => a.date.toDateTime().compareTo(b.date.toDateTime()),
            );
          final translated = await Future.wait(
            sorted.map(
              (item) => pollMessageItemToChatMessage(
                item,
                mediaService: mediaService,
                directory: _directory,
              ),
            ),
          );
          final messages = translated.whereType<ChatMessage>();
          if (messages.isNotEmpty) {
            _emit(ChatMessage.chatStatus(timestamp: DateTime.now()));
            for (final message in messages) {
              if (message.wiId == null ||
                  cache.get(message.wiId!) != null) {
                continue;
              }
              cache.set(message.wiId!, true);
              _emit(message);
            }
          }
          break;
        case Error():
          log.severe(
            'Unable to fetch messages since $timestamp',
            newMessagesResult.error,
          );
          _emit(ChatMessage.chatStatus(timestamp: DateTime.now()));
          break;
      }
      await Future.delayed(Duration(seconds: pollingRate));
    }
  }

  @override
  void pause() {
    log.info('Polling paused');
    _paused = true;
    polling = false;
    _chatStatusTimer?.cancel();
    _chatStatusTimer = null;
  }

  @override
  void resume() {
    if (!_paused) {
      return;
    }
    log.info('Polling resumed');
    _paused = false;
    _startPolling();
  }

  @override
  void dispose() {
    polling = false;
    _paused = false;
    _chatStatusTimer?.cancel();
    _chatStatusTimer = null;
  }

  @override
  Stream<ChatMessage> messages() {
    _startPolling();
    return _messagesStreamController.stream.asBroadcastStream();
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
          log.fine("Media uploaded successfully with URL: '${result.signedUrl}'");
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
}
