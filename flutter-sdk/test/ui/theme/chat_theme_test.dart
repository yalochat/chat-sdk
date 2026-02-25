// Copyright (c) Yalochat, Inc. All rights reserved.


import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatTheme', () {
    test('should create instance with default values', () {
      const theme = ChatTheme();

      expect(theme.backgroundColor, isNotNull);
      expect(theme.userMessageColor, isNotNull);
      expect(theme.sendButtonIcon, Icons.send_outlined);
      expect(theme.userMessageTextStyle, isNotNull);
    });

    test('should create instance with custom values', () {
      const customTheme = ChatTheme(
        backgroundColor: Colors.blue,
        userMessageColor: Colors.green,
        sendButtonIcon: Icons.arrow_forward,
        userMessageTextStyle: TextStyle(color: Colors.red),
      );

      expect(customTheme.backgroundColor, Colors.blue);
      expect(customTheme.userMessageColor, Colors.green);
      expect(customTheme.sendButtonIcon, Icons.arrow_forward);
      expect(customTheme.userMessageTextStyle.color, Colors.red);
    });

    test('copyWith should return new instance with updated values', () {
      const originalTheme = ChatTheme();

      final updatedTheme = originalTheme.copyWith(
        backgroundColor: Colors.red,
        sendButtonIcon: Icons.send,
      );

      expect(updatedTheme.backgroundColor, Colors.red);
      expect(updatedTheme.sendButtonIcon, Icons.send);
      expect(updatedTheme.userMessageColor, originalTheme.userMessageColor);
      expect(updatedTheme.userMessageTextStyle, originalTheme.userMessageTextStyle);
    });

    test('copyWith with null values should keep original values', () {
      const originalTheme = ChatTheme(
        backgroundColor: Colors.blue,
        userMessageColor: Colors.green,
      );

      final copiedTheme = originalTheme.copyWith();

      expect(copiedTheme.backgroundColor, originalTheme.backgroundColor);
      expect(copiedTheme.userMessageColor, originalTheme.userMessageColor);
      expect(copiedTheme.sendButtonIcon, originalTheme.sendButtonIcon);
    });

    test('fromThemeData should create theme from Material ThemeData', () {
      final materialTheme = ThemeData.light();
      final chatTheme = ChatTheme.fromThemeData(materialTheme, null);

      expect(chatTheme.backgroundColor, materialTheme.colorScheme.surface);
      expect(chatTheme.sendButtonColor, materialTheme.colorScheme.primary);
      expect(chatTheme.sendButtonForegroundColor, materialTheme.colorScheme.onPrimary);
      expect(chatTheme.userMessageColor, materialTheme.colorScheme.surfaceContainerHighest);
    });

    test('fromThemeData with base theme should override specific values', () {
      final materialTheme = ThemeData.dark();
      const baseTheme = ChatTheme(
        sendButtonIcon: Icons.ten_k,
        recordAudioIcon: Icons.ten_k_sharp,
      );

      final chatTheme = ChatTheme.fromThemeData(materialTheme, baseTheme);

      expect(chatTheme.backgroundColor, materialTheme.colorScheme.surface);
      expect(chatTheme.sendButtonColor, materialTheme.colorScheme.primary);

      expect(chatTheme.sendButtonIcon, Icons.ten_k);
      expect(chatTheme.recordAudioIcon, Icons.ten_k_sharp);
    });

    test('should handle all color properties in copyWith', () {
      const theme = ChatTheme();

      final updatedTheme = theme.copyWith(
        backgroundColor: Colors.red,
        cardBackgroundColor: Colors.green,
        cardBorderColor: Colors.blue,
        appBarBackgroundColor: Colors.yellow,
        userMessageColor: Colors.purple,
        inputTextFieldColor: Colors.orange,
        sendButtonColor: Colors.pink,
        waveColor: Colors.teal,
      );

      expect(updatedTheme.backgroundColor, Colors.red);
      expect(updatedTheme.cardBackgroundColor, Colors.green);
      expect(updatedTheme.cardBorderColor, Colors.blue);
      expect(updatedTheme.appBarBackgroundColor, Colors.yellow);
      expect(updatedTheme.userMessageColor, Colors.purple);
      expect(updatedTheme.inputTextFieldColor, Colors.orange);
      expect(updatedTheme.sendButtonColor, Colors.pink);
      expect(updatedTheme.waveColor, Colors.teal);
    });

    test('should handle all text style properties in copyWith', () {
      const theme = ChatTheme();
      const newTextStyle = TextStyle(color: Colors.red, fontSize: 16);

      final updatedTheme = theme.copyWith(
        userMessageTextStyle: newTextStyle,
        assistantMessageTextStyle: newTextStyle,
        modalHeaderStyle: newTextStyle,
        hintTextStyle: newTextStyle,
      );

      expect(updatedTheme.userMessageTextStyle, newTextStyle);
      expect(updatedTheme.assistantMessageTextStyle, newTextStyle);
      expect(updatedTheme.modalHeaderStyle, newTextStyle);
      expect(updatedTheme.hintTextStyle, newTextStyle);
    });

    test('should handle all icon properties in copyWith', () {
      const theme = ChatTheme();

      final updatedTheme = theme.copyWith(
        sendButtonIcon: Icons.arrow_forward,
        recordAudioIcon: Icons.mic,
        shopIcon: Icons.store,
        cartIcon: Icons.shopping_cart,
        attachIcon: Icons.attach_file,
      );

      expect(updatedTheme.sendButtonIcon, Icons.arrow_forward);
      expect(updatedTheme.recordAudioIcon, Icons.mic);
      expect(updatedTheme.shopIcon, Icons.store);
      expect(updatedTheme.cartIcon, Icons.shopping_cart);
      expect(updatedTheme.attachIcon, Icons.attach_file);
    });
  });
}
