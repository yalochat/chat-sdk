// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';
import 'package:yalo_chat_flutter_sdk/domain/models/product/product.dart';
import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_media/yalo_media_service.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/button.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart'
    as proto;
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pbenum.dart'
    as proto_enum;

final _log = Logger('SdkMessageMapper');

Future<ChatMessage?> pollMessageItemToChatMessage(
  proto.PollMessageItem item, {
  required YaloMediaService mediaService,
  required Future<Directory> Function() directory,
}) async {
  switch (item.message.whichPayload()) {
    case proto.SdkMessage_Payload.textMessageRequest:
      final request = item.message.textMessageRequest;
      return ChatMessage.text(
        role: MessageRole.assistant,
        timestamp: item.date.toDateTime(),
        content: request.content.text,
        header: request.hasHeader() ? request.header : null,
        footer: request.hasFooter() ? request.footer : null,
        buttons: request.buttons.map(_toDomainButton).toList(),
        wiId: item.id,
      );
    case proto.SdkMessage_Payload.imageMessageRequest:
      final request = item.message.imageMessageRequest;
      final content = request.content;
      final downloadResult = await mediaService.downloadMedia(content.mediaUrl);
      switch (downloadResult) {
        case Ok(:final Uint8List result):
          final mimeType = content.mediaType.isNotEmpty
              ? content.mediaType
              : (lookupMimeType(content.mediaUrl) ?? 'image/jpeg');
          final ext = extensionFromMime(mimeType) ?? 'jpg';
          final dir = await directory();
          final localPath = '${dir.path}/${const Uuid().v4()}.$ext';
          await File(localPath).writeAsBytes(result);
          return ChatMessage.image(
            role: MessageRole.assistant,
            timestamp: item.date.toDateTime(),
            content: content.text,
            fileName: localPath,
            mediaType: mimeType,
            byteCount: result.length,
            header: request.hasHeader() ? request.header : null,
            footer: request.hasFooter() ? request.footer : null,
            buttons: request.buttons.map(_toDomainButton).toList(),
            wiId: item.id,
          );
        case Error(:final error):
          _log.severe('Failed to download image for message ${item.id}', error);
          return null;
      }
    case proto.SdkMessage_Payload.videoMessageRequest:
      final request = item.message.videoMessageRequest;
      final content = request.content;
      final downloadResult = await mediaService.downloadMedia(content.mediaUrl);
      switch (downloadResult) {
        case Ok(:final Uint8List result):
          final mimeType = content.mediaType.isNotEmpty
              ? content.mediaType
              : (lookupMimeType(content.mediaUrl) ?? 'video/mp4');
          final ext = extensionFromMime(mimeType) ?? 'mp4';
          final dir = await directory();
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
            header: request.hasHeader() ? request.header : null,
            footer: request.hasFooter() ? request.footer : null,
            buttons: request.buttons.map(_toDomainButton).toList(),
            wiId: item.id,
          );
        case Error(:final error):
          _log.severe('Failed to download video for message ${item.id}', error);
          return null;
      }
    case proto.SdkMessage_Payload.productMessageRequest:
      final List<Product> products = item.message.productMessageRequest.products
          .map(_toDomainProduct)
          .toList();
      final bool isCarousel =
          item.message.productMessageRequest.orientation ==
          proto_enum
              .ProductMessageRequest_Orientation
              .ORIENTATION_HORIZONTAL;
      if (isCarousel) {
        return ChatMessage.carousel(
          role: MessageRole.assistant,
          timestamp: item.date.toDateTime(),
          products: products,
          wiId: item.id,
        );
      }
      return ChatMessage.product(
        role: MessageRole.assistant,
        timestamp: item.date.toDateTime(),
        products: products,
        wiId: item.id,
      );
    case _:
      return null;
  }
}

proto.SdkMessage? chatMessageToSdkMessage(
  ChatMessage chatMessage, {
  String? mediaId,
}) {
  final messageStatus = switch (chatMessage.status) {
    MessageStatus.delivered => proto.MessageStatus.MESSAGE_STATUS_DELIVERED,
    MessageStatus.read => proto.MessageStatus.MESSAGE_STATUS_READ,
    MessageStatus.error => proto.MessageStatus.MESSAGE_STATUS_ERROR,
    MessageStatus.sent => proto.MessageStatus.MESSAGE_STATUS_SENT,
    MessageStatus.inProgress => proto.MessageStatus.MESSAGE_STATUS_IN_PROGRESS,
  };
  final timestamp = DateTime.now();

  final protoButtons = chatMessage.buttons.map(_toProtoButton).toList();

  return switch (chatMessage.type) {
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
        header: chatMessage.header,
        footer: chatMessage.footer,
        buttons: protoButtons,
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
          mediaUrl: mediaId!,
          mediaType: chatMessage.mediaType,
          byteCount: Int64(chatMessage.byteCount!),
          status: messageStatus,
          role: proto.MessageRole.MESSAGE_ROLE_USER,
        ),
        header: chatMessage.header,
        footer: chatMessage.footer,
        buttons: protoButtons,
      ),
    ),
    MessageType.voice => proto.SdkMessage(
      correlationId: chatMessage.id.toString(),
      timestamp: Timestamp.fromDateTime(timestamp),
      voiceNoteMessageRequest: proto.VoiceNoteMessageRequest(
        content: proto.VoiceMessage(
          timestamp: Timestamp.fromDateTime(chatMessage.timestamp),
          fileName: chatMessage.fileName,
          mediaUrl: mediaId!,
          amplitudesPreview: chatMessage.amplitudes,
          duration: chatMessage.duration?.toDouble(),
          mediaType: chatMessage.mediaType,
          byteCount: Int64(chatMessage.byteCount!),
          status: messageStatus,
          role: proto.MessageRole.MESSAGE_ROLE_USER,
        ),
        header: chatMessage.header,
        footer: chatMessage.footer,
        buttons: protoButtons,
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
          mediaUrl: mediaId!,
          duration: chatMessage.duration?.toDouble(),
          mediaType: chatMessage.mediaType,
          byteCount: Int64(chatMessage.byteCount!),
          status: messageStatus,
          role: proto.MessageRole.MESSAGE_ROLE_USER,
        ),
        header: chatMessage.header,
        footer: chatMessage.footer,
        buttons: protoButtons,
      ),
    ),
    MessageType.product => null,
    MessageType.productCarousel => null,
    MessageType.promotion => null,
    MessageType.unknown => null,
  };
}

Button _toDomainButton(proto.Button b) {
  final ButtonType type;
  if (b.buttonType == proto_enum.ButtonType.BUTTON_TYPE_LINK) {
    type = ButtonType.link;
  } else if (b.buttonType == proto_enum.ButtonType.BUTTON_TYPE_POSTBACK) {
    type = ButtonType.postback;
  } else {
    type = ButtonType.reply;
  }
  return Button(
    text: b.text,
    type: type,
    url: b.hasUrl() ? b.url : null,
  );
}

proto.Button _toProtoButton(Button b) {
  return proto.Button(
    text: b.text,
    buttonType: switch (b.type) {
      ButtonType.reply => proto_enum.ButtonType.BUTTON_TYPE_REPLY,
      ButtonType.postback => proto_enum.ButtonType.BUTTON_TYPE_POSTBACK,
      ButtonType.link => proto_enum.ButtonType.BUTTON_TYPE_LINK,
    },
    url: b.url,
  );
}

Product _toDomainProduct(proto.Product p) {
  return Product(
    sku: p.sku,
    name: p.name,
    price: p.price,
    imagesUrl: p.imagesUrl.toList(),
    salePrice: p.hasSalePrice() ? p.salePrice : null,
    subunits: p.subunits,
    unitStep: p.unitStep,
    unitName: p.unitName,
    subunitName: p.hasSubunitName() ? p.subunitName : null,
    subunitStep: p.subunitStep,
    unitsAdded: p.unitsAdded,
    subunitsAdded: p.subunitsAdded,
  );
}
