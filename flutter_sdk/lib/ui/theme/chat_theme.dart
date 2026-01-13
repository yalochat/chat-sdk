// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';

// A class to customize the branding of the chat screen
class ChatTheme {
  final Color backgroundColor;
  final Color cardBackgroundColor;
  final Color cardBorderColor;
  final Color appBarBackgroundColor;
  final Color userMessageColor;
  final Color inputTextFieldColor;
  final Color inputTextFieldBorderColor;
  final Color sendButtonColor;
  final Color sendButtonForegroundColor;
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
  final Color pickerButtonBorderColor;

  final TextStyle modalHeaderStyle;
  final TextStyle userMessageTextStyle;
  final TextStyle assistantMessageTextStyle;
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
    this.inputTextFieldColor = SdkColors.inputTextFieldColorLight,
    this.inputTextFieldBorderColor = SdkColors.inputTextFieldBorderColorLight,
    this.sendButtonColor = SdkColors.sendButtonColorLight,
    this.attachmentPickerBackgroundColor =
        SdkColors.attachmentPickerBackgroundColorLight,
    this.sendButtonForegroundColor = SdkColors.sendButtonTextColorLight,
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
    this.pickerButtonBorderColor = SdkColors.pickerButtonBorderColor,

    // Text Styles
    this.userMessageTextStyle = const TextStyle(
      color: SdkColors.userMessageTextColorLight,
    ),
    this.assistantMessageTextStyle = const TextStyle(
      color: SdkColors.assistantMessageTextColorLight,
      fontSize: SdkConstants.titleFontSize,
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

  ChatTheme copyWith({
    Color? backgroundColor,
    Color? cardBackgroundColor,
    Color? cardBorderColor,
    Color? appBarBackgroundColor,
    Color? userMessageColor,
    Color? inputTextFieldColor,
    Color? inputTextFieldBorderColor,
    Color? sendButtonColor,
    Color? sendButtonForegroundColor,
    Color? waveColor,
    Color? attachmentPickerBackgroundColor,
    Color? actionIconColor,
    Color? cancelRecordingIconColor,
    Color? closeModalIconColor,
    Color? playAudioIconColor,
    Color? pauseAudioIconColor,
    Color? attachIconColor,
    Color? cameraIconColor,
    Color? galleryIconColor,
    Color? trashIconColor,
    Color? currencyIconColor,
    Color? numericControlIconColor,
    Color? imagePlaceholderBackgroundColor,
    Color? imagePlaceholderIconColor,
    Color? productPriceBackgroundColor,
    Color? pricePerSubunitColor,
    Color? pickerButtonBorderColor,
    TextStyle? modalHeaderStyle,
    TextStyle? userMessageTextStyle,
    TextStyle? assistantMessageTextStyle,
    TextStyle? hintTextStyle,
    TextStyle? timerTextStyle,
    TextStyle? productTitleStyle,
    TextStyle? productSubunitsStyle,
    TextStyle? productPriceStyle,
    TextStyle? productSalePriceStrikeStyle,
    TextStyle? pricePerSubunitStyle,
    TextStyle? expandControlsStyle,
    ImageProvider? chatIconImage,
    IconData? sendButtonIcon,
    IconData? recordAudioIcon,
    IconData? shopIcon,
    IconData? cartIcon,
    IconData? cancelRecordingIcon,
    IconData? closeModalIcon,
    IconData? playAudioIcon,
    IconData? pauseAudioIcon,
    IconData? attachIcon,
    IconData? cameraIcon,
    IconData? galleryIcon,
    IconData? trashIcon,
    IconData? imagePlaceHolderIcon,
    IconData? currencyIcon,
    IconData? addIcon,
    IconData? removeIcon,
  }) {
    return ChatTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      appBarBackgroundColor:
          appBarBackgroundColor ?? this.appBarBackgroundColor,
      userMessageColor: userMessageColor ?? this.userMessageColor,
      inputTextFieldColor: inputTextFieldColor ?? this.inputTextFieldColor,
      inputTextFieldBorderColor:
          inputTextFieldBorderColor ?? this.inputTextFieldBorderColor,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      sendButtonForegroundColor:
          sendButtonForegroundColor ?? this.sendButtonForegroundColor,
      waveColor: waveColor ?? this.waveColor,
      attachmentPickerBackgroundColor:
          attachmentPickerBackgroundColor ??
          this.attachmentPickerBackgroundColor,
      actionIconColor: actionIconColor ?? this.actionIconColor,
      cancelRecordingIconColor:
          cancelRecordingIconColor ?? this.cancelRecordingIconColor,
      closeModalIconColor: closeModalIconColor ?? this.closeModalIconColor,
      playAudioIconColor: playAudioIconColor ?? this.playAudioIconColor,
      pauseAudioIconColor: pauseAudioIconColor ?? this.pauseAudioIconColor,
      attachIconColor: attachIconColor ?? this.attachIconColor,
      cameraIconColor: cameraIconColor ?? this.cameraIconColor,
      galleryIconColor: galleryIconColor ?? this.galleryIconColor,
      trashIconColor: trashIconColor ?? this.trashIconColor,
      currencyIconColor: currencyIconColor ?? this.currencyIconColor,
      numericControlIconColor:
          numericControlIconColor ?? this.numericControlIconColor,
      imagePlaceholderBackgroundColor:
          imagePlaceholderBackgroundColor ??
          this.imagePlaceholderBackgroundColor,
      imagePlaceholderIconColor:
          imagePlaceholderIconColor ?? this.imagePlaceholderIconColor,
      productPriceBackgroundColor:
          productPriceBackgroundColor ?? this.productPriceBackgroundColor,
      pricePerSubunitColor: pricePerSubunitColor ?? this.pricePerSubunitColor,
      pickerButtonBorderColor:
          pickerButtonBorderColor ?? this.pickerButtonBorderColor,

      modalHeaderStyle: modalHeaderStyle ?? this.modalHeaderStyle,
      userMessageTextStyle: userMessageTextStyle ?? this.userMessageTextStyle,
      assistantMessageTextStyle:
          assistantMessageTextStyle ?? this.assistantMessageTextStyle,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      timerTextStyle: timerTextStyle ?? this.timerTextStyle,
      productTitleStyle: productTitleStyle ?? this.productTitleStyle,
      productSubunitsStyle: productSubunitsStyle ?? this.productSubunitsStyle,
      productPriceStyle: productPriceStyle ?? this.productPriceStyle,
      productSalePriceStrikeStyle:
          productSalePriceStrikeStyle ?? this.productSalePriceStrikeStyle,
      pricePerSubunitStyle: pricePerSubunitStyle ?? this.pricePerSubunitStyle,
      expandControlsStyle: expandControlsStyle ?? this.expandControlsStyle,
      chatIconImage: chatIconImage ?? this.chatIconImage,
      sendButtonIcon: sendButtonIcon ?? this.sendButtonIcon,
      recordAudioIcon: recordAudioIcon ?? this.recordAudioIcon,
      shopIcon: shopIcon ?? this.shopIcon,
      cartIcon: cartIcon ?? this.cartIcon,
      cancelRecordingIcon: cancelRecordingIcon ?? this.cancelRecordingIcon,
      closeModalIcon: closeModalIcon ?? this.closeModalIcon,
      playAudioIcon: playAudioIcon ?? this.playAudioIcon,
      pauseAudioIcon: pauseAudioIcon ?? this.pauseAudioIcon,
      attachIcon: attachIcon ?? this.attachIcon,
      cameraIcon: cameraIcon ?? this.cameraIcon,
      galleryIcon: galleryIcon ?? this.galleryIcon,
      trashIcon: trashIcon ?? this.trashIcon,
      imagePlaceHolderIcon: imagePlaceHolderIcon ?? this.imagePlaceHolderIcon,
      currencyIcon: currencyIcon ?? this.currencyIcon,
      addIcon: addIcon ?? this.addIcon,
      removeIcon: removeIcon ?? this.removeIcon,
    );
  }

  // Creates a ChatTheme from Material App ThemeData, optional chatTheme lets
  // create a base theme that the colors will be overriden by ThemeData values
  factory ChatTheme.fromThemeData(ThemeData themeData, ChatTheme? chatTheme) {
    final baseTheme = chatTheme ?? ChatTheme();
    return baseTheme.copyWith(
      backgroundColor: themeData.colorScheme.surface,

      // App Bar
      appBarBackgroundColor: themeData.colorScheme.surface,
      actionIconColor: themeData.colorScheme.onSurface,

      // User messages
      userMessageColor: themeData.colorScheme.surfaceContainerHighest,
      userMessageTextStyle: baseTheme.userMessageTextStyle.copyWith(
        color: themeData.colorScheme.onSurface,
      ),

      // Assistant messages
      assistantMessageTextStyle: baseTheme.assistantMessageTextStyle.copyWith(
        color: themeData.colorScheme.onSurface,
      ),

      // Main text input
      inputTextFieldColor: themeData.colorScheme.surface,
      inputTextFieldBorderColor: themeData.colorScheme.outline,
      attachmentPickerBackgroundColor: themeData.colorScheme.surface,
      pickerButtonBorderColor: themeData.colorScheme.onSurfaceVariant,
      cancelRecordingIconColor: themeData.colorScheme.onSurfaceVariant,
      attachIconColor: themeData.colorScheme.onSurfaceVariant,
      cameraIconColor: themeData.colorScheme.onSurfaceVariant,
      galleryIconColor: themeData.colorScheme.onSurfaceVariant,

      modalHeaderStyle: baseTheme.modalHeaderStyle.copyWith(
        color: themeData.colorScheme.onSurface,
      ),
      hintTextStyle: baseTheme.hintTextStyle.copyWith(
        color: themeData.colorScheme.onSurface,
      ),
      timerTextStyle: baseTheme.timerTextStyle.copyWith(
        color: themeData.colorScheme.onSurface,
      ),

      // Main button
      sendButtonColor: themeData.colorScheme.primary,
      sendButtonForegroundColor: themeData.colorScheme.onPrimary,

      // Audio wave component
      waveColor: themeData.colorScheme.primary,
      playAudioIconColor: themeData.colorScheme.onSurfaceVariant,
      pauseAudioIconColor: themeData.colorScheme.onSurfaceVariant,

      // Product card
      cardBackgroundColor: themeData.colorScheme.surface,
      cardBorderColor: themeData.colorScheme.outline,
      currencyIconColor: themeData.colorScheme.onSurfaceVariant,
      numericControlIconColor: themeData.colorScheme.onSurfaceVariant,
      imagePlaceholderIconColor: themeData.colorScheme.onSurfaceVariant,
      imagePlaceholderBackgroundColor: themeData.colorScheme.surfaceContainerHighest,
      productPriceBackgroundColor: themeData.colorScheme.tertiaryContainer,
      pricePerSubunitColor: themeData.colorScheme.onSurfaceVariant,

      productTitleStyle: baseTheme.productTitleStyle.copyWith(
        color: themeData.colorScheme.onSurface,
      ),
      productSubunitsStyle: baseTheme.productSubunitsStyle.copyWith(
        color: themeData.colorScheme.onSurface,
      ),

      productPriceStyle: baseTheme.productPriceStyle.copyWith(
        color: themeData.colorScheme.onTertiaryContainer,
      ),
      productSalePriceStrikeStyle: baseTheme.productSalePriceStrikeStyle.copyWith(
        color: themeData.colorScheme.onTertiaryContainer,
      ),
      pricePerSubunitStyle: baseTheme.pricePerSubunitStyle.copyWith(
        color: themeData.colorScheme.onSurfaceVariant,
      ),
      expandControlsStyle: baseTheme.expandControlsStyle.copyWith(
        color: themeData.colorScheme.onSurface,
      ),
    );
  }
}
