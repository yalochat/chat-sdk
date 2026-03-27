// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaUploadResponse _$MediaUploadResponseFromJson(Map<String, dynamic> json) =>
    MediaUploadResponse(
      id: json['id'] as String,
      signedUrl: json['signed_url'] as String,
      originalName: json['original_name'] as String,
      type: json['type'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$MediaUploadResponseToJson(
  MediaUploadResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'signed_url': instance.signedUrl,
  'original_name': instance.originalName,
  'type': instance.type,
  'metadata': instance.metadata,
  'created_at': instance.createdAt.toIso8601String(),
  'expires_at': instance.expiresAt.toIso8601String(),
};
