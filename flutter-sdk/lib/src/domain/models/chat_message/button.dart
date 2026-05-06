// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'button.g.dart';

// Mirrors the proto ButtonType enum. Discriminates how a button behaves
// when tapped: REPLY sends back the button text, POSTBACK sends a payload,
// LINK opens the url externally.
enum ButtonType {
  @JsonValue('REPLY')
  reply('REPLY'),
  @JsonValue('POSTBACK')
  postback('POSTBACK'),
  @JsonValue('LINK')
  link('LINK');

  final String value;
  const ButtonType(this.value);
}

// A single tappable option attached to a message, matching the proto Button
// schema. url is required when type is link and ignored otherwise.
@JsonSerializable()
class Button extends Equatable {
  final String text;
  final ButtonType type;
  final String? url;

  const Button({required this.text, required this.type, this.url});

  factory Button.fromJson(Map<String, dynamic> json) => _$ButtonFromJson(json);

  Map<String, dynamic> toJson() => _$ButtonToJson(this);

  @override
  List<Object?> get props => [text, type, url];
}
