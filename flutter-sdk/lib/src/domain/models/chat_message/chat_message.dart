// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/domain/models/product/product.dart';
import 'package:equatable/equatable.dart';

import 'cta_button.dart';

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
  quickReply('quickReply'),
  buttons('buttons'),
  cta('cta'),

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

  final List<String> quickReplies;

  // Optional header text shown above the message content
  final String? header;

  // Optional footer text shown below the message content
  final String? footer;

  // Reply buttons rendered for buttons messages
  final List<String> buttons;

  // CTA buttons (text + URL) rendered for cta messages
  final List<CTAButton> ctaButtons;

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
    this.quickReplies = const [],
    this.header,
    this.footer,
    this.buttons = const [],
    this.ctaButtons = const [],
  });

  const ChatMessage.text({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    required this.content,
    this.quickReplies = const [],
  }) : type = MessageType.text,
       amplitudes = null,
       fileName = null,
       duration = null,
       byteCount = null,
       mediaType = null,
       products = const [],
       expand = false,
       header = null,
       footer = null,
       buttons = const [],
       ctaButtons = const [];

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
    this.quickReplies = const [],
  }) : type = MessageType.voice,
       products = const [],
       content = '',
       expand = false,
       header = null,
       footer = null,
       buttons = const [],
       ctaButtons = const [];

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
    this.quickReplies = const [],
  }) : type = MessageType.video,
       amplitudes = null,
       products = const [],
       expand = false,
       header = null,
       footer = null,
       buttons = const [],
       ctaButtons = const [];

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
    this.quickReplies = const [],
  }) : type = MessageType.image,
       amplitudes = null,
       duration = null,
       products = const [],
       expand = false,
       header = null,
       footer = null,
       buttons = const [],
       ctaButtons = const [];

  const ChatMessage.product({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    this.products = const [],
    this.expand = false,
    this.quickReplies = const [],
  }) : type = MessageType.product,
       content = '',
       fileName = '',
       amplitudes = null,
       duration = null,
       byteCount = null,
       mediaType = null,
       header = null,
       footer = null,
       buttons = const [],
       ctaButtons = const [];

  const ChatMessage.carousel({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    this.products = const [],
    this.expand = false,
    this.quickReplies = const [],
  }) : type = MessageType.productCarousel,
       content = '',
       fileName = '',
       amplitudes = null,
       duration = null,
       byteCount = null,
       mediaType = null,
       header = null,
       footer = null,
       buttons = const [],
       ctaButtons = const [];

  const ChatMessage.buttons({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    this.content = '',
    this.header,
    this.footer,
    this.buttons = const [],
  }) : type = MessageType.buttons,
       fileName = null,
       amplitudes = null,
       duration = null,
       byteCount = null,
       mediaType = null,
       products = const [],
       expand = false,
       quickReplies = const [],
       ctaButtons = const [];

  const ChatMessage.cta({
    this.id,
    this.wiId,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    this.content = '',
    this.header,
    this.footer,
    this.ctaButtons = const [],
  }) : type = MessageType.cta,
       fileName = null,
       amplitudes = null,
       duration = null,
       byteCount = null,
       mediaType = null,
       products = const [],
       expand = false,
       quickReplies = const [],
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
    List<String>? quickReplies,
    DateTime? timestamp,
    String? header,
    String? footer,
    List<String>? buttons,
    List<CTAButton>? ctaButtons,
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
      quickReplies: quickReplies ?? this.quickReplies,
      timestamp: timestamp ?? this.timestamp,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      buttons: buttons ?? this.buttons,
      ctaButtons: ctaButtons ?? this.ctaButtons,
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
    quickReplies,
    timestamp,
    header,
    footer,
    buttons,
    ctaButtons,
  ];
}
