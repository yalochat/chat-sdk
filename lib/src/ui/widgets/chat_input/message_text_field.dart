// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../view_models/chat/chat_cubit.dart';
import '../../view_models/chat/chat_state.dart';
import '../../view_models/theme/theme_cubit.dart';

class MessageTextField extends StatefulWidget {
  final String hintText;
  const MessageTextField({super.key, this.hintText = ""});

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  void _handleOnMessageChange(BuildContext context, String message) {
    final chatCubit = context.read<ChatCubit>();
    chatCubit.updateUserMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    final chatThemeState = context.watch<ChatThemeCubit>();
    return Container(
      constraints: BoxConstraints(maxHeight: 120),
      child: Scrollbar(
        child: BlocSelector<ChatCubit, ChatState, String>(
          selector: (state) => state.userMessage,
          builder: (context, userMessage) {
            return TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: chatThemeState.chatTheme.hintTextStyle,
                border: InputBorder.none,
              ),
              onChanged: (message) => _handleOnMessageChange(context, message),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
