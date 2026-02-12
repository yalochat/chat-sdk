// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_message.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'yalo_fetch_messages_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class YaloFetchMessagesResponse extends Equatable {
  final String id;
  final YaloMessage message;
  final String date;
  final String userId;
  final String status;

  const YaloFetchMessagesResponse({
    required this.id,
    required this.message,
    required this.date,
    required this.userId,
    required this.status,
  });

  factory YaloFetchMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$YaloFetchMessagesResponseFromJson(json);

  static List<YaloFetchMessagesResponse> fromJsonList(List<dynamic> jsonList) =>
      jsonList
          .map(
            (json) => YaloFetchMessagesResponse.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();

  Map<String, dynamic> toJson() => _$YaloFetchMessagesResponseToJson(this);

  @override
  List<Object?> get props => [id, message, date, userId];
}
