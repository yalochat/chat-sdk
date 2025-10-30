// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/config/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/ui/widgets/chat_input/chat_input_container.dart';
import '../../theme/chat_theme.dart';

class Chat extends StatelessWidget {
  final PreferredSizeWidget? appBar;

  final String title;
  final String flowKey;
  final ChatTheme theme;

  const Chat({
    super.key,
    required this.title,
    required this.flowKey,
    this.appBar,
    this.theme = const ChatTheme.defaultTheme(),
  });

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: chatProviders(theme),
      child: Scaffold(
        appBar: appBar ?? AppBar(title: Text(title)),
        body: Column(children: [ChatInputContainer(hintText: "Type a message")]),
      ),
    );

  }
}
