// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/view_models/theme_cubit.dart';

class MessageTextField extends StatefulWidget {
  final String hintText;
  const MessageTextField({super.key, this.hintText = ''});

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

  void _handleOnMessageChange(ChatBloc chatBloc, String message) {
    chatBloc.add(ChatUpdateUserMessage(value: message));
  }

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    final chatBloc = context.read<ChatBloc>();
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.userMessage != current.userMessage,
      listener: (context, chatState) {
        _textEditingController.text = chatState.userMessage;
      },
      child: Container(
        color: chatThemeCubit.state.inputTextFieldColor,
        child: Scrollbar(
          child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: chatThemeCubit.chatTheme.hintTextStyle,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) => _handleOnMessageChange(chatBloc, value),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
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
