// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'yalo_text_message.g.dart';

@JsonSerializable()
class YaloTextMessage extends Equatable {
  final int timestamp;
  final String text;
  final String status;
  final String role;
  const YaloTextMessage({
    required this.timestamp,
    required this.text,
    required this.status,
    required this.role,
  });

  factory YaloTextMessage.fromJson(Map<String, dynamic> json) =>
      _$YaloTextMessageFromJson(json);

  Map<String, dynamic> toJson() => _$YaloTextMessageToJson(this);

  @override
  List<Object?> get props => [timestamp, text, status, role];
}
