// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'yalo_text_message.dart';

part 'yalo_text_message_request.g.dart';

@JsonSerializable()
class YaloTextMessageRequest extends Equatable {
  final int timestamp;
  final YaloTextMessage content;
  const YaloTextMessageRequest({
    required this.timestamp,
    required this.content,
  });

  factory YaloTextMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$YaloTextMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$YaloTextMessageRequestToJson(this);

  @override
  List<Object?> get props => [timestamp, content];
}
