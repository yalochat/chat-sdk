// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yalo_fetch_messages_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YaloFetchMessagesResponse _$YaloFetchMessagesResponseFromJson(
  Map<String, dynamic> json,
) => YaloFetchMessagesResponse(
  id: json['id'] as String,
  message: YaloMessage.fromJson(json['message'] as Map<String, dynamic>),
  date: json['date'] as String,
  userId: json['user_id'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$YaloFetchMessagesResponseToJson(
  YaloFetchMessagesResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'message': instance.message,
  'date': instance.date,
  'user_id': instance.userId,
  'status': instance.status,
};
