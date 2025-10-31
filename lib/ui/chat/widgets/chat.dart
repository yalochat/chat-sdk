// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/config/dependencies.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/chat_input_container.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Chat extends StatelessWidget {
  final PreferredSizeWidget? appBar;

  final String title;
  final String flowKey;
  final String hintText;
  final bool showCameraButton;
  final bool showAttachmentButton;
  final ChatTheme theme;

  const Chat({
    super.key,
    required this.title,
    required this.flowKey,
    this.hintText = "Type a message",
    this.showCameraButton = true,
    this.showAttachmentButton = true,
    this.appBar,
    this.theme = const ChatTheme.defaultTheme(),
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: chatProviders(theme),
      child: Scaffold(
        appBar: appBar ?? AppBar(title: Text(title)),
        body: Column(children: [ChatInputContainer(hintText: hintText)]),
      ),
    );
  }
}
