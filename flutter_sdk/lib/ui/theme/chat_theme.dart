// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';

class ChatTheme {
  final Color backgroundColor;
  final Color cardBackgroundColor;
  final Color cardBorderColor;
  final Color appBarBackgroundColor;
  final Color userMessageColor;
  final Color systemMessageColor;
  final Color inputTextFieldColor;
  final Color inputTextFieldBorderColor;
  final Color sendButtonColor;
  final Color sendButtonStyle;
  final Color waveColor;
  final Color attachmentPickerBackgroundColor;
  final Color actionIconColor;
  final Color cancelRecordingIconColor;
  final Color closeModalIconColor;
  final Color playAudioIconColor;
  final Color pauseAudioIconColor;
  final Color attachIconColor;
  final Color cameraIconColor;
  final Color galleryIconColor;
  final Color trashIconColor;
  final Color currencyIconColor;
  final Color numericControlIconColor;
  final Color imagePlaceholderBackgroundColor;
  final Color imagePlaceholderIconColor;
  final Color productPriceBackgroundColor;
  final Color pricePerSubunitColor;

  final TextStyle modalHeaderStyle;
  final TextStyle userMessageTextStyle;
  final TextStyle assistantMessageTextStyle;
  final TextStyle systemMessageTextStyle;
  final TextStyle hintTextStyle;
  final TextStyle timerTextStyle;
  final TextStyle productTitleStyle;
  final TextStyle productSubunitsStyle;
  final TextStyle productPriceStyle;
  final TextStyle productSalePriceStrikeStyle;
  final TextStyle pricePerSubunitStyle;
  final TextStyle expandControlsStyle;

  final ImageProvider? chatIconImage;
  final IconData sendButtonIcon;
  final IconData recordAudioIcon;
  final IconData shopIcon;
  final IconData cartIcon;
  final IconData cancelRecordingIcon;
  final IconData closeModalIcon;
  final IconData playAudioIcon;
  final IconData pauseAudioIcon;
  final IconData attachIcon;
  final IconData cameraIcon;
  final IconData galleryIcon;
  final IconData trashIcon;
  final IconData imagePlaceHolderIcon;
  final IconData currencyIcon;
  final IconData addIcon;
  final IconData removeIcon;

  const ChatTheme({
    // Colors
    this.backgroundColor = SdkColors.backgroundColorLight,
    this.cardBackgroundColor = SdkColors.backgroundColorLight,
    this.cardBorderColor = SdkColors.cardBorderColorLight,
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
    this.actionIconColor = Colors.black,
    this.cancelRecordingIconColor = SdkColors.messageControlIconColorLight,
    this.closeModalIconColor = SdkColors.messageControlIconColorLight,
    this.playAudioIconColor = SdkColors.messageControlIconColorLight,
    this.pauseAudioIconColor = SdkColors.messageControlIconColorLight,
    this.attachIconColor = SdkColors.messageControlIconColorLight,
    this.cameraIconColor = SdkColors.messageControlIconColorLight,
    this.galleryIconColor = SdkColors.messageControlIconColorLight,
    this.trashIconColor = SdkColors.iconWithBackdropColorLight,
    this.currencyIconColor = SdkColors.priceColorLight,
    this.numericControlIconColor = SdkColors.messageControlIconColorLight,
    this.imagePlaceholderIconColor = SdkColors.messageControlIconColorLight,
    this.imagePlaceholderBackgroundColor = SdkColors.imagePlaceHolderColorLight,
    this.productPriceBackgroundColor = SdkColors.discountBackgroundColorLight,
    this.pricePerSubunitColor = SdkColors.productCardSubtitleColorLight,

    // Text Styles
    this.userMessageTextStyle = const TextStyle(
      color: SdkColors.userMessageTextColorLight,
    ),
    this.assistantMessageTextStyle = const TextStyle(
      color: SdkColors.assistantMessageTextColorLight,
      fontSize: SdkConstants.titleFontSize,
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
    this.productTitleStyle = const TextStyle(
      color: SdkColors.assistantMessageTextColorLight,
      fontSize: SdkConstants.cardTitleFontSize,
      fontWeight: FontWeight.bold,
    ),
    this.productSubunitsStyle = const TextStyle(
      color: SdkColors.productCardSubtitleColorLight,
      fontSize: SdkConstants.cardSubtitleFontSize,
    ),
    this.productPriceStyle = const TextStyle(
      color: SdkColors.priceColorLight,
      fontWeight: FontWeight.bold,
    ),
    this.productSalePriceStrikeStyle = const TextStyle(
      color: SdkColors.discountStrikeColorLight,
      decoration: TextDecoration.lineThrough,
    ),
    this.pricePerSubunitStyle = const TextStyle(
      color: SdkColors.pricePerUnitColorLight,
    ),
    this.expandControlsStyle = const TextStyle(
      color: SdkColors.expandControlColorLight,
    ),

    // Icons
    this.chatIconImage,
    this.sendButtonIcon = Icons.send_outlined,
    this.recordAudioIcon = Icons.mic_none,
    this.shopIcon = Icons.storefront,
    this.cartIcon = Icons.shopping_cart_outlined,
    this.cancelRecordingIcon = Icons.close,
    this.closeModalIcon = Icons.close,
    this.playAudioIcon = Icons.play_arrow_rounded,
    this.pauseAudioIcon = Icons.pause_rounded,
    this.attachIcon = Icons.add,
    this.cameraIcon = Icons.photo_camera,
    this.galleryIcon = Icons.insert_photo,
    this.trashIcon = Icons.delete_outline,
    this.imagePlaceHolderIcon = Icons.image,
    this.currencyIcon = Icons.toll,
    this.addIcon = Icons.add,
    this.removeIcon = Icons.remove,
  });
}
