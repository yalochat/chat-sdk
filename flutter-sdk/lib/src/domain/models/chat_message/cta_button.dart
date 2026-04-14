// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cta_button.g.dart';

// A button with text and URL used in CTA messages
@JsonSerializable()
class CTAButton extends Equatable {
  final String text;
  final String url;

  const CTAButton({required this.text, required this.url});

  factory CTAButton.fromJson(Map<String, dynamic> json) =>
      _$CTAButtonFromJson(json);

  Map<String, dynamic> toJson() => _$CTAButtonToJson(this);

  @override
  List<Object?> get props => [text, url];
}
