// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'action_button.dart';
import 'camera_button.dart';
import 'message_text_field.dart';

class ChatInput extends StatefulWidget {
  final String hintText;
  final bool showCameraButton;
  const ChatInput({
    super.key,
    this.hintText = '',
    this.showCameraButton = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  void _handleSendMessage(BuildContext context) {
    final chatBloc = context.read<ChatBloc>();
    chatBloc.add(ChatSendMessage());
  }

  void _handleOnMessageChange(BuildContext context, String message) {
    final chatBloc = context.read<ChatBloc>();
    chatBloc.add(ChatUpdateUserMessage(value: message));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatThemeCubit, ChatTheme>(
      builder: (context, chatTheme) {
        return Container(
          padding: EdgeInsets.all(SdkConstants.inputPadding),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: SdkConstants.rowItemSpace),
                  decoration: BoxDecoration(
                    color: chatTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(
                      SdkConstants.inputBorderRadius,
                    ),
                    border: Border.all(
                      width: 1,
                      color: chatTheme.inputTextFieldBorderColor,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(width: SdkConstants.rowItemSpace * 3),
                      Expanded(
                        child: BlocListener<ChatBloc, ChatState>(
                          listenWhen: (previous, current) =>
                              previous.userMessage != current.userMessage,
                          listener: (context, chatState) {
                            _textEditingController.text = chatState.userMessage;
                          },
                          child: MessageTextField(
                            key: const Key('MessageTextField'),
                            hintText: widget.hintText,
                            controller: _textEditingController,
                            onChanged: (value) => _handleOnMessageChange(context, value),
                          ),
                        ),
                      ),
                      if (widget.showCameraButton)
                      CameraButton(key: const Key('CameraButton')),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SdkConstants.rowItemSpace,
                  right: SdkConstants.rowItemSpace,
                ),
                child: BlocSelector<ChatBloc, ChatState, String>(
                  selector: (state) => state.userMessage,
                  builder: (context, userMessage) {
                    return ActionButton(
                      key: const Key('ActionButton'),
                      userMessage: userMessage,
                      onPressed: () => _handleSendMessage(context),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
