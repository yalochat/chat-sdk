// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:json_annotation/json_annotation.dart';

part 'media_upload_response.g.dart';

@JsonSerializable()
class MediaUploadResponse {
  final String id;

  @JsonKey(name: 'signed_url')
  final String signedUrl;

  @JsonKey(name: 'original_name')
  final String originalName;

  final String type;

  final Map<String, dynamic> metadata;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  const MediaUploadResponse({
    required this.id,
    required this.signedUrl,
    required this.originalName,
    required this.type,
    required this.metadata,
    required this.createdAt,
    required this.expiresAt,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$MediaUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MediaUploadResponseToJson(this);
}
