// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'yalo_message.g.dart';

@JsonSerializable()
class YaloMessage extends Equatable {
  final String text;
  final String role;

  const YaloMessage({
    required this.text,
    required this.role,
  });

  factory YaloMessage.fromJson(Map<String, dynamic> json) =>
      _$YaloMessageFromJson(json);

  Map<String, dynamic> toJson() => _$YaloMessageToJson(this);

  @override
  List<Object?> get props => [text, role];
}

