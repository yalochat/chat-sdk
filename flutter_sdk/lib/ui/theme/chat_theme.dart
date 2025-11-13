// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';

import 'colors.dart';

class ChatTheme {
  final Color backgroundColor;
  final Color appBarBackgroundColor;
  final Color userMessageColor;
  final Color systemMessageColor;
  final Color inputTextFieldColor;
  final Color inputTextFieldBorderColor;
  final Color sendButtonColor;
  final Color sendButtonStyle;
  final TextStyle userMessageTextStyle;
  final TextStyle systemMessageTextStyle;
  final TextStyle hintTextStyle;

  final AssetImage chatIconImage;
  final Icon sendButtonIcon;
  final Icon recordAudioIcon;
  final Icon shopIcon;
  final Icon cartIcon;

  const ChatTheme({
    this.backgroundColor = SdkColors.backgroundColorLight,
    this.appBarBackgroundColor = SdkColors.appBarBackgroundColorLight,
    this.userMessageColor = SdkColors.userMessageColorLight,
    this.systemMessageColor = SdkColors.systemMessageColorLight,
    this.inputTextFieldColor = SdkColors.inputTextFieldColorLight,
    this.inputTextFieldBorderColor = SdkColors.inputTextFieldBorderColorLight,
    this.sendButtonColor = SdkColors.sendButtonColorLight,
    this.sendButtonStyle = SdkColors.sendButtonTextColorLight,
    this.userMessageTextStyle = const TextStyle(
      color: SdkColors.userMessageColorLight,
    ),
    this.systemMessageTextStyle = const TextStyle(
      color: SdkColors.systemMessageColorLight,
    ),
    this.hintTextStyle = const TextStyle(color: SdkColors.hintColorLight),
    this.chatIconImage = const AssetImage(
      'assets/images/oris-icon.png',
      package: 'chat_flutter_sdk',
    ),
    this.sendButtonIcon = const Icon(
      Icons.send_outlined,
      key: Key("sendButtonIcon"),
    ),
    this.recordAudioIcon = const Icon(
      Icons.mic_none,
      key: Key("recordAudioIcon"),
    ),
    this.shopIcon = const Icon(Icons.storefront, color: Colors.black),
    this.cartIcon = const Icon(Icons.shopping_cart_outlined, color: Colors.black),
  });
}
