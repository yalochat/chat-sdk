// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart'
    as proto;
import 'package:chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:chat_flutter_sdk/yalo_sdk.dart';
import 'package:ecache/ecache.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

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
  final YaloMessageService messageService;
  final Logger log = Logger('YaloMessageRepositoryRemote');

  YaloMessageRepositoryRemote({
    required this.yaloChatClient,
    required this.messageService,
  });

  ChatMessage _translateMessageResponse(proto.PollMessageItem item) {
    // FIXME: detect other messages than text
    return ChatMessage.text(
      role: MessageRole.assistant,
      timestamp: item.date.toDateTime(),
      content: item.message.textMessageRequest.content.text,
      wiId: item.id,
    );
  }

  Future<void> _startPolling() async {
    polling = true;
    while (polling) {
      final timestamp =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - pollingRateWindow;
      final newMessagesResult = await messageService.fetchMessages(timestamp);
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
    final messageStatus = switch (chatMessage.status) {
      MessageStatus.delivered => proto.MessageStatus.MESSAGE_STATUS_DELIVERED,
      MessageStatus.read => proto.MessageStatus.MESSAGE_STATUS_READ,
      MessageStatus.error => proto.MessageStatus.MESSAGE_STATUS_ERROR,
      MessageStatus.sent => proto.MessageStatus.MESSAGE_STATUS_SENT,
      MessageStatus.inProgress =>
        proto.MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
    };
    if (chatMessage.type == MessageType.text) {
      _typingEventsStreamController.sink.add(
        TypingStart(statusText: 'Writing message...'),
      );
      final timestamp = DateTime.now();
      final request = proto.SdkMessage(
        correlationId: chatMessage.id.toString(),
        timestamp: Timestamp.fromDateTime(timestamp),
        textMessageRequest: proto.TextMessageRequest(
          content: proto.TextMessage(
            timestamp: Timestamp.fromDateTime(chatMessage.timestamp),
            text: chatMessage.content,
            status: messageStatus,
            role: proto.MessageRole.MESSAGE_ROLE_USER,
          ),
        ),
      );
      return messageService.sendSdkMessage(request);
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
