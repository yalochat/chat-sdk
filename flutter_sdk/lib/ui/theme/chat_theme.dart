// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';

class ChatTheme {
  final Color backgroundColor;
  final Color appBarBackgroundColor;
  final Color userMessageColor;
  final Color systemMessageColor;
  final Color inputTextFieldColor;
  final Color inputTextFieldBorderColor;
  final Color sendButtonColor;
  final Color sendButtonStyle;
  final Color waveColor;
  final Color attachmentPickerBackgroundColor;
  final TextStyle modalHeaderStyle;
  final TextStyle userMessageTextStyle;
  final TextStyle systemMessageTextStyle;
  final TextStyle hintTextStyle;
  final TextStyle timerTextStyle;

  final AssetImage chatIconImage;
  final Icon sendButtonIcon;
  final Icon recordAudioIcon;
  final Icon shopIcon;
  final Icon cartIcon;
  final Icon cancelRecordingIcon;
  final Icon closeModalIcon;
  final Icon playAudioIcon;
  final Icon pauseAudioIcon;
  final Icon attachIcon;
  final Icon cameraIcon;
  final Icon galleryIcon;

  const ChatTheme({
    this.backgroundColor = SdkColors.backgroundColorLight,
    this.appBarBackgroundColor = SdkColors.appBarBackgroundColorLight,
    this.userMessageColor = SdkColors.userMessageColorLight,
    this.systemMessageColor = SdkColors.systemMessageColorLight,
    this.inputTextFieldColor = SdkColors.inputTextFieldColorLight,
    this.inputTextFieldBorderColor = SdkColors.inputTextFieldBorderColorLight,
    this.sendButtonColor = SdkColors.sendButtonColorLight,
    this.attachmentPickerBackgroundColor =
        SdkColors.attachmentPickerBackgroundColorLight,
    this.sendButtonStyle = SdkColors.sendButtonTextColorLight,
    this.waveColor = SdkColors.waveColorLight,
    this.userMessageTextStyle = const TextStyle(
      color: SdkColors.userMessageTextColorLight,
    ),
    this.systemMessageTextStyle = const TextStyle(
      color: SdkColors.systemMessageColorLight,
    ),
    this.modalHeaderStyle = const TextStyle(
      color: SdkColors.modalHeaderColorLight,
      fontSize: SdkConstants.titleFontSize,
      fontWeight: FontWeight.bold,
    ),
    this.hintTextStyle = const TextStyle(color: SdkColors.hintColorLight),
    this.timerTextStyle = const TextStyle(color: SdkColors.timerColoLight),
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
    this.cartIcon = const Icon(
      Icons.shopping_cart_outlined,
      color: Colors.black,
    ),
    this.cancelRecordingIcon = const Icon(
      Icons.close,
      color: SdkColors.messageControlIconColor,
    ),
    this.closeModalIcon = const Icon(
      Icons.close,
      color: SdkColors.messageControlIconColor,
    ),
    this.playAudioIcon = const Icon(
      Icons.play_arrow_rounded,
      color: SdkColors.messageControlIconColor,
    ),
    this.pauseAudioIcon = const Icon(
      Icons.pause_rounded,
      color: SdkColors.messageControlIconColor,
    ),
    this.attachIcon = const Icon(
      Icons.add,
      color: SdkColors.messageControlIconColor,
    ),
    this.cameraIcon = const Icon(
      Icons.photo_camera,
      color: SdkColors.messageControlIconColor,
    ),
    this.galleryIcon = const Icon(
      Icons.insert_photo,
      color: SdkColors.messageControlIconColor,
    ),
  });
}
