// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'button.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Button _$ButtonFromJson(Map<String, dynamic> json) => Button(
  text: json['text'] as String,
  type: $enumDecode(_$ButtonTypeEnumMap, json['type']),
  url: json['url'] as String?,
);

Map<String, dynamic> _$ButtonToJson(Button instance) => <String, dynamic>{
  'text': instance.text,
  'type': _$ButtonTypeEnumMap[instance.type]!,
  'url': instance.url,
};

const _$ButtonTypeEnumMap = {
  ButtonType.reply: 'REPLY',
  ButtonType.postback: 'POSTBACK',
  ButtonType.link: 'LINK',
};
