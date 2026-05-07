// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/domain/models/product/product.dart';
import 'package:equatable/equatable.dart';

import 'button.dart';

enum MessageRole {
  user('USER'),
  assistant('AGENT');

  final String role;

  const MessageRole(this.role);
}

enum MessageType {
  text('text'),
  image('image'),
  voice('voice'),
  video('video'),
  product('product'),
  productCarousel('productCarousel'),
  promotion('promotion'),

  unknown('unknown');

  final String type;
  const MessageType(this.type);
}

enum MessageStatus {
  delivered('DELIVERED'),
  read('READ'),
  error('ERROR'),
  sent('SENT'),
  inProgress('IN_PROGRESS');

  final String status;
  const MessageStatus(this.status);
}

// A class that represents a chat message in the chat
class ChatMessage extends Equatable {
  final int? id;
  final String? wiId;
  final MessageRole role;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;

  // Attached file name to resource of the message
  // for images the image file path, and for audios the audio path
  final String? fileName;

  // Audio amplitudes preview
  final List<double>? amplitudes;
  // Audio duration in ms
  final int? duration;

  // File size in bytes (for image and voice messages)
  final int? byteCount;

  // MIME type of the media file (for image and voice messages)
  final String? mediaType;

  // Products linked to the chat message
  final List<Product> products;

  // Used to indicate if the expanded version of a message should be displayed
  // this should not be persisted in DB
  final bool expand;

  // Optional header text shown above the message content
  final String? header;

  // Optional footer text shown below the message content
  final String? footer;

  // Buttons attached to the message, matching the proto Button schema.
  final List<Button> buttons;

  const ChatMessage({
    this.id,
    this.wiId,
    required this.role,
    required this.type,
    required this.timestamp,
    this.content = '',
    this.status = MessageStatus.inProgress,
    this.fileName,
    this.amplitudes,
    this.duration,
    this.byteCount,
    this.mediaType,
    this.products = const [],
    this.expand = false,
    this.header,
    this.footer,
    this.buttons = const [],
  });

  const ChatMessage.text({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    required this.content,
    this.header,
    this.footer,
    this.buttons = const [],
  }) : type = MessageType.text,
       amplitudes = null,
       fileName = null,
       duration = null,
       byteCount = null,
       mediaType = null,
       products = const [],
       expand = false;

  const ChatMessage.voice({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    required this.fileName,
    required this.amplitudes,
    required this.duration,
    required this.byteCount,
    required this.mediaType,
    this.header,
    this.footer,
    this.buttons = const [],
  }) : type = MessageType.voice,
       products = const [],
       content = '',
       expand = false;

  const ChatMessage.video({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    required this.fileName,
    required this.duration,
    required this.byteCount,
    required this.mediaType,
    this.status = MessageStatus.inProgress,
    this.content = '',
    this.header,
    this.footer,
    this.buttons = const [],
  }) : type = MessageType.video,
       amplitudes = null,
       products = const [],
       expand = false;

  const ChatMessage.image({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    required this.fileName,
    this.status = MessageStatus.inProgress,
    this.content = '',
    required this.byteCount,
    required this.mediaType,
    this.header,
    this.footer,
    this.buttons = const [],
  }) : type = MessageType.image,
       amplitudes = null,
       duration = null,
       products = const [],
       expand = false;

  const ChatMessage.product({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    this.products = const [],
    this.expand = false,
  }) : type = MessageType.product,
       content = '',
       fileName = '',
       amplitudes = null,
       duration = null,
       byteCount = null,
       mediaType = null,
       header = null,
       footer = null,
       buttons = const [];

  const ChatMessage.carousel({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    this.products = const [],
    this.expand = false,
  }) : type = MessageType.productCarousel,
       content = '',
       fileName = '',
       amplitudes = null,
       duration = null,
       byteCount = null,
       mediaType = null,
       header = null,
       footer = null,
       buttons = const [];

  // Creates a copy of a chat message
  ChatMessage copyWith({
    int? id,
    String? wiId,
    MessageRole? role,
    String? content,
    MessageType? type,
    MessageStatus? status,
    String? fileName,
    List<double>? amplitudes,
    int? duration,
    int? byteCount,
    String? mediaType,
    List<Product>? products,
    bool? expand,
    DateTime? timestamp,
    String? header,
    String? footer,
    List<Button>? buttons,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      wiId: wiId ?? this.wiId,
      role: role ?? this.role,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      amplitudes: amplitudes ?? this.amplitudes,
      duration: duration ?? this.duration,
      byteCount: byteCount ?? this.byteCount,
      mediaType: mediaType ?? this.mediaType,
      products: products ?? this.products,
      expand: expand ?? this.expand,
      timestamp: timestamp ?? this.timestamp,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      buttons: buttons ?? this.buttons,
    );
  }

  // Equatable props array
  @override
  List<Object?> get props => [
    id,
    wiId,
    role,
    content,
    type,
    status,
    fileName,
    amplitudes,
    duration,
    byteCount,
    mediaType,
    products,
    expand,
    timestamp,
    header,
    footer,
    buttons,
  ];
}
