// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yalo_text_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YaloTextMessage _$YaloTextMessageFromJson(Map<String, dynamic> json) =>
    YaloTextMessage(
      timestamp: (json['timestamp'] as num).toInt(),
      text: json['text'] as String,
      status: json['status'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$YaloTextMessageToJson(YaloTextMessage instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'text': instance.text,
      'status': instance.status,
      'role': instance.role,
    };
