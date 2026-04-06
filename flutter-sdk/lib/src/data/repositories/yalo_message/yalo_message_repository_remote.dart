// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_media/media_upload_response.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart'
    as proto;
import 'package:chat_flutter_sdk/src/data/services/yalo_media/yalo_media_service.dart';
import 'package:cross_file/cross_file.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:chat_flutter_sdk/yalo_sdk.dart';
import 'package:ecache/ecache.dart';
import 'package:fixnum/fixnum.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';

final class YaloMessageRepositoryRemote implements YaloMessageRepository {
  final StreamController<ChatMessage> _messagesStreamController =
      StreamController();
  final StreamController<ChatEvent> _typingEventsStreamController =
      StreamController();
  bool polling = false;
  bool _paused = false;
  final int pollingRate = 1;
  final int pollingRateWindow = 5;
  final cache = SimpleCache<String, bool>(capacity: 500);

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
  }) : _directory = directory ?? getTemporaryDirectory;

  Future<ChatMessage?> _translateMessageResponse(
    proto.PollMessageItem item,
  ) async {
    switch (item.message.whichPayload()) {
      case proto.SdkMessage_Payload.textMessageRequest:
        return ChatMessage.text(
          role: MessageRole.assistant,
          timestamp: item.date.toDateTime(),
          content: item.message.textMessageRequest.content.text,
          wiId: item.id,
        );
      case proto.SdkMessage_Payload.imageMessageRequest:
        final content = item.message.imageMessageRequest.content;
        final downloadResult = await mediaService.downloadMedia(
          content.mediaUrl,
        );
        switch (downloadResult) {
          case Ok(:final Uint8List result):
            final mimeType = content.mediaType.isNotEmpty
                ? content.mediaType
                : (lookupMimeType(content.mediaUrl) ?? 'image/jpeg');
            final ext = extensionFromMime(mimeType) ?? 'jpg';
            final dir = await _directory();
            final localPath = '${dir.path}/${const Uuid().v4()}.$ext';
            await File(localPath).writeAsBytes(result);
            return ChatMessage.image(
              role: MessageRole.assistant,
              timestamp: item.date.toDateTime(),
              content: content.text,
              fileName: localPath,
              mediaType: mimeType,
              byteCount: result.length,
              wiId: item.id,
            );
          case Error(:final error):
            log.severe(
              'Failed to download image for message ${item.id}',
              error,
            );
            return null;
        }
      case proto.SdkMessage_Payload.videoMessageRequest:
        final content = item.message.videoMessageRequest.content;
        final downloadResult = await mediaService.downloadMedia(
          content.mediaUrl,
        );
        switch (downloadResult) {
          case Ok(:final Uint8List result):
            final mimeType = content.mediaType.isNotEmpty
                ? content.mediaType
                : (lookupMimeType(content.mediaUrl) ?? 'video/mp4');
            final ext = extensionFromMime(mimeType) ?? 'mp4';
            final dir = await _directory();
            final localPath = '${dir.path}/${const Uuid().v4()}.$ext';
            await File(localPath).writeAsBytes(result);
            return ChatMessage.video(
              role: MessageRole.assistant,
              timestamp: item.date.toDateTime(),
              content: content.text,
              fileName: localPath,
              duration: content.duration.toInt(),
              mediaType: mimeType,
              byteCount: result.length,
              wiId: item.id,
            );
          case Error(:final error):
            log.severe(
              'Failed to download video for message ${item.id}',
              error,
            );
            return null;
        }
      case _:
        throw UnimplementedError();
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
            sorted.map(_translateMessageResponse),
          );
          final messages = translated.whereType<ChatMessage>();
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
  void pause() {
    log.info('Polling paused');
    _paused = true;
    polling = false;
  }

  @override
  void resume() {
    if (!_paused) return;
    log.info('Polling resumed');
    _paused = false;
    _startPolling();
  }

  @override
  void dispose() {
    polling = false;
    _paused = false;
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

    _typingEventsStreamController.sink.add(
      TypingStart(statusText: 'Writing message...'),
    );
    final timestamp = DateTime.now();
    MediaUploadResponse? mediaUploadResponse;
    if (chatMessage.type == MessageType.image ||
        chatMessage.type == MessageType.voice ||
        chatMessage.type == MessageType.video) {
      log.info(chatMessage.fileName);
      final uploadResult = await mediaService.uploadMedia(
        XFile(chatMessage.fileName!),
      );
      switch (uploadResult) {
        case Ok(:final result):
          mediaUploadResponse = result;
          log.fine(
            "Image uploaded successfully with URL: '${mediaUploadResponse.signedUrl}'",
          );
        case Error(:final error):
          log.severe("Unable to upload media", error);
          return Result.error(error);
      }
    }

    final requestToSend = switch (chatMessage.type) {
      MessageType.text => proto.SdkMessage(
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
      ),
      MessageType.image => proto.SdkMessage(
        correlationId: chatMessage.id.toString(),
        timestamp: Timestamp.fromDateTime(timestamp),
        imageMessageRequest: proto.ImageMessageRequest(
          content: proto.ImageMessage(
            timestamp: Timestamp.fromDateTime(chatMessage.timestamp),
            text: chatMessage.content,
            fileName: chatMessage.fileName,
            mediaUrl: mediaUploadResponse!.id,
            mediaType: chatMessage.mediaType,
            byteCount: Int64(chatMessage.byteCount!),
            status: messageStatus,
            role: proto.MessageRole.MESSAGE_ROLE_USER,
          ),
        ),
      ),
      MessageType.voice => proto.SdkMessage(
        correlationId: chatMessage.id.toString(),
        timestamp: Timestamp.fromDateTime(timestamp),
        voiceNoteMessageRequest: proto.VoiceNoteMessageRequest(
          content: proto.VoiceMessage(
            timestamp: Timestamp.fromDateTime(chatMessage.timestamp),
            fileName: chatMessage.fileName,
            mediaUrl: mediaUploadResponse!.id,
            amplitudesPreview: chatMessage.amplitudes,
            duration: chatMessage.duration?.toDouble(),
            mediaType: chatMessage.mediaType,
            byteCount: Int64(chatMessage.byteCount!),
            status: messageStatus,
            role: proto.MessageRole.MESSAGE_ROLE_USER,
          ),
        ),
      ),
      MessageType.video => proto.SdkMessage(
        correlationId: chatMessage.id.toString(),
        timestamp: Timestamp.fromDateTime(timestamp),
        videoMessageRequest: proto.VideoMessageRequest(
          content: proto.VideoMessage(
            timestamp: Timestamp.fromDateTime(chatMessage.timestamp),
            text: chatMessage.content,
            fileName: chatMessage.fileName,
            mediaUrl: mediaUploadResponse!.id,
            duration: chatMessage.duration?.toDouble(),
            mediaType: chatMessage.mediaType,
            byteCount: Int64(chatMessage.byteCount!),
            status: messageStatus,
            role: proto.MessageRole.MESSAGE_ROLE_USER,
          ),
        ),
      ),
      MessageType.product => null,
      MessageType.productCarousel => null,
      MessageType.promotion => null,
      MessageType.quickReply => null,
      MessageType.unknown => null,
    };

    if (requestToSend == null) {
      return Result.error(FormatException('Message type is yet not supported'));
    }

    return messageService.sendSdkMessage(requestToSend);
  }

  @override
  Future<void> executeActions() async {
    for (final action in yaloChatClient.actions) {
      action.action();
    }
  }
}
