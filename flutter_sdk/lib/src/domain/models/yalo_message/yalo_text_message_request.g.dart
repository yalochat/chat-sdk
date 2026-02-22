// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yalo_text_message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YaloTextMessageRequest _$YaloTextMessageRequestFromJson(
  Map<String, dynamic> json,
) => YaloTextMessageRequest(
  timestamp: (json['timestamp'] as num).toInt(),
  content: YaloTextMessage.fromJson(json['content'] as Map<String, dynamic>),
);

Map<String, dynamic> _$YaloTextMessageRequestToJson(
  YaloTextMessageRequest instance,
) => <String, dynamic>{
  'timestamp': instance.timestamp,
  'content': instance.content,
};
