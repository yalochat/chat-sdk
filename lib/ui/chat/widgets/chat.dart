// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/config/dependencies.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_app_bar/chat_app_bar.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/chat_input.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class Chat extends StatelessWidget {
  final PreferredSizeWidget? appBar;


  final String name;
  final String flowKey;
  final String hintText;
  final bool showCameraButton;
  final bool showAttachmentButton;
  final ChatTheme theme;

  const Chat({
    super.key,
    required this.name,
    required this.flowKey,
    this.hintText = "Type a message",
    this.showCameraButton = true,
    this.showAttachmentButton = true,
    this.appBar,
    this.theme = const ChatTheme(),
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: chatProviders(theme, name),
      child: BlocBuilder<ChatThemeCubit, ChatTheme>(
        builder: (context, chatTheme) {
          return Scaffold(
            backgroundColor: chatTheme.backgroundColor,
            appBar: appBar ?? ChatAppBar(),
            body: SafeArea(
              child: Column(children: [
                  Expanded(
                    child: Container(
                      color: SdkColors.backgroundColorLight,
                    ),
                  ),
                  ChatInput(hintText: hintText)]
              ),
            ),
          );
        }
      ),
    );
  }
}
