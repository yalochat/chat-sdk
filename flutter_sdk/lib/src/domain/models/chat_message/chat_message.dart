// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/domain/models/product/product.dart';
import 'package:equatable/equatable.dart';

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
  product('product'),
  productCarousel('productCarousel'),
  promotion('promotion'),
  quickReply('quickReply'),

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

  // Products linked to the chat message
  final List<Product> products;

  // Used to indicate if the expanded version of a message should be displayed
  // this should not be persisted in DB
  final bool expand;

  final List<String> quickReplies;

  const ChatMessage({
    this.id,
    required this.role,
    required this.type,
    required this.timestamp,
    this.content = '',
    this.status = MessageStatus.inProgress,
    this.fileName,
    this.amplitudes,
    this.duration,
    this.products = const [],
    this.expand = false,
    this.quickReplies = const [],
  });

  const ChatMessage.text({
    this.id,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    required this.content,
    this.quickReplies = const [],
  }) : type = MessageType.text,
       amplitudes = null,
       fileName = null,
       duration = null,
       products = const [],
       expand = false;

  const ChatMessage.voice({
    this.id,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.inProgress,
    required this.fileName,
    required this.amplitudes,
    required this.duration,
    this.quickReplies = const [],
  }) : type = MessageType.voice,
       products = const [],
       content = '',
       expand = false;

  const ChatMessage.image({
    this.id,
    required this.role,
    required this.timestamp,
    required this.fileName,
    this.status = MessageStatus.inProgress,
    this.content = '',
    this.quickReplies = const [],
  }) : type = MessageType.image,
       amplitudes = null,
       duration = null,
       products = const [],
       expand = false;

  const ChatMessage.product({
    this.id,
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
       duration = null;

  const ChatMessage.carousel({
    this.id,
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
       duration = null;

  // Creates a copy of a chat message
  ChatMessage copyWith({
    int? id,
    MessageRole? role,
    String? content,
    MessageType? type,
    MessageStatus? status,
    String? fileName,
    List<double>? amplitudes,
    int? duration,
    List<Product>? products,
    bool? expand,
    List<String>? quickReplies,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      amplitudes: amplitudes ?? this.amplitudes,
      duration: duration ?? this.duration,
      products: products ?? this.products,
      expand: expand ?? this.expand,
      quickReplies: quickReplies ?? this.quickReplies,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Equatable props array
  @override
  List<Object?> get props => [
    id,
    role,
    content,
    type,
    status,
    fileName,
    amplitudes,
    duration,
    products,
    expand,
    quickReplies,
    timestamp,
  ];
}
