// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

// A button with text and URL used in CTA messages
class CTAButton extends Equatable {
  final String text;
  final String url;

  const CTAButton({required this.text, required this.url});

  @override
  List<Object?> get props => [text, url];
}
