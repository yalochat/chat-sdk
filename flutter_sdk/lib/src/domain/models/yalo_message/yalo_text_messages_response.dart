// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part "yalo_text_messages_response.g.dart";

@JsonSerializable()
class YaloTextMessageResponse extends Equatable {

  final 

  const YaloTextMessagesResponse({required this.status});

  factory YaloTextMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$YaloTextMessagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$YaloTextMessagesResponseToJson(this);

  static List<YaloTextMessageResponse> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Message.fromJson(json)).toList();
  }

  @override
  List<Object?> get props => [status];
}

