// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';

class ChatTheme {
  final Color? backgroundColor;
  final Color? userMessageColor;
  final Color? systemMessageColor;
  final Color? sendButtonColor;
  final Color? sendButtonStyle;
  final TextStyle? userMessageTextStyle;
  final TextStyle? systemMessageTextStyle;
  final TextStyle? hintTextStyle;
  final Icon sendButtonIcon = const Icon(Icons.send, key: Key("sendButtonIcon"));
  final Icon recordAudioIcon = const Icon(Icons.mic, key: Key("recordAudioIcon"));

  const ChatTheme({
    this.backgroundColor,
    this.userMessageColor,
    this.systemMessageColor,
    this.sendButtonColor,
    this.sendButtonStyle,
    this.userMessageTextStyle,
    this.systemMessageTextStyle,
    this.hintTextStyle,
  });

  const factory ChatTheme.defaultTheme() = _DefaultTheme;
}

class _DefaultTheme extends ChatTheme {
  const _DefaultTheme()
    : super(
        backgroundColor: SdkColors.backgroundColorLight,
        userMessageColor: SdkColors.userMessageColorLight,
        systemMessageColor: SdkColors.systemMessageColorLight,
        sendButtonColor: SdkColors.sendButtonColorLight,
        sendButtonStyle: SdkColors.sendButtonTextColorLight,
        hintTextStyle: const TextStyle(color: SdkColors.hintColorLight),
      );
}
