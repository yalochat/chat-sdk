// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message_request.dart';
import 'package:chat_flutter_sdk/yalo_sdk.dart';
import 'package:ecache/ecache.dart';
import 'package:logging/logging.dart';

import '../../../domain/models/yalo_message/yalo_fetch_messages_response.dart';

final class YaloMessageRepositoryRemote implements YaloMessageRepository {
  final StreamController<ChatMessage> _messagesStreamController =
      StreamController();
  final StreamController<ChatEvent> _typingEventsStreamController =
      StreamController();
  bool polling = false;
  final int pollingRate = 1;
  final int pollingRateWindow = 5;
  final cache = SimpleCache<String, bool>(capacity: 500);

  final YaloChatClient yaloChatClient;
  final Logger log = Logger('YaloMessageRepositoryRemote');

  YaloMessageRepositoryRemote({required this.yaloChatClient});

  ChatMessage _translateMessageResponse(YaloFetchMessagesResponse item) {
    // FIXME: detect other messages than text
    return ChatMessage.text(
      role: MessageRole.values.firstWhere(
        (role) => role.role == item.message.role,
        orElse: () => MessageRole.assistant,
      ),
      timestamp: DateTime.parse(item.date),
      content: item.message.text,
      wiId: item.id,
    );
  }

  Future<void> _startPolling() async {
    polling = true;
    while (polling) {
      final timestamp =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - pollingRateWindow;
      final newMessagesResult = await yaloChatClient.fetchMessages(timestamp);
      switch (newMessagesResult) {
        case Ok():
          final messagesResult = newMessagesResult.result;
          final messages = messagesResult.map(_translateMessageResponse);
          if (messages.isNotEmpty) {
            _typingEventsStreamController.sink.add(TypingStop());
            await _messagesStreamController.sink.addStream(
              Stream.fromIterable(
                messages.where((message) {
                  if (message.wiId == null ||
                      cache.get(message.wiId!) != null) {
                    return false;
                  }

                  cache.set(message.wiId!, true);
                  return true;
                }),
              ),
            );
          }
          break;
        case Error():
          log.severe(
            'Unable to fetch messages since $timestamp',
            newMessagesResult.error,
          );
          _typingEventsStreamController.sink.add(TypingStop());
          break;
      }
      await Future.delayed(Duration(seconds: pollingRate));
    }
  }

  @override
  void dispose() {
    polling = false;
  }

  @override
  Stream<ChatEvent> events() =>
      _typingEventsStreamController.stream.asBroadcastStream();

  @override
  Stream<ChatMessage> messages() {
    _startPolling();
    return _messagesStreamController.stream.asBroadcastStream();
  }

  @override
  Future<Result<Unit>> sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.type == MessageType.text) {
      _typingEventsStreamController.sink.add(
        TypingStart(statusText: 'Writing message...'),
      );
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final request = YaloTextMessageRequest(
        timestamp: timestamp,
        content: YaloTextMessage(
          timestamp: chatMessage.timestamp.millisecondsSinceEpoch ~/ 1000,
          text: chatMessage.content,
          status: chatMessage.status.status,
          role: chatMessage.role.role,
        ),
      );
      return yaloChatClient.sendTextMessage(request);
    }
    return Result.error(FormatException('Message type is not supported'));
  }

  @override
  Future<void> executeActions() async {
    for (final action in yaloChatClient.actions) {
      action.action();
    }
  }
}
