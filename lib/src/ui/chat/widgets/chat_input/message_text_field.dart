// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/view_models/theme_cubit.dart';

class MessageTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const MessageTextField({
    super.key,
    this.hintText = '',
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final chatThemeState = context.watch<ChatThemeCubit>();
    return Container(
      color: chatThemeState.state.inputTextFieldColor,
      constraints: BoxConstraints(maxHeight: 120),
      child: Scrollbar(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: chatThemeState.chatTheme.hintTextStyle,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: onChanged,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
      ),
    );
  }
}
