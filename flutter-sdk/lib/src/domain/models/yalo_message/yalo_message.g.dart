// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yalo_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YaloMessage _$YaloMessageFromJson(Map<String, dynamic> json) =>
    YaloMessage(text: json['text'] as String, role: json['role'] as String);

Map<String, dynamic> _$YaloMessageToJson(YaloMessage instance) =>
    <String, dynamic>{'text': instance.text, 'role': instance.role};
