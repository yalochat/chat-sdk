// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/data/services/client/yalo_chat_client.dart';
import 'package:chat_flutter_sdk/src/config/dependencies.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_app_bar/chat_app_bar.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/chat_input.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/message_list.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Chat extends StatelessWidget {
  final PreferredSizeWidget? appBar;

  final YaloChatClient client;
  final bool showAttachmentButton;
  final VoidCallback? onShopPressed;
  final VoidCallback? onCartPressed;
  final ChatTheme theme;

  const Chat({
    super.key,
    required this.client,
    this.showAttachmentButton = true,
    this.appBar,
    this.onShopPressed,
    this.onCartPressed,
    this.theme = const ChatTheme(),
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: repositoryProviders(context, client),
      child: MultiBlocProvider(
        providers: chatProviders(theme, client.name),
        child: BlocBuilder<ChatThemeCubit, ChatTheme>(
          builder: (context, chatTheme) {
            return Scaffold(
              backgroundColor: chatTheme.backgroundColor,
              appBar:
                  appBar ??
                  ChatAppBar(
                    onShopPressed: onShopPressed,
                    onCartPressed: onCartPressed,
                  ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(child: MessageList()),
                    ChatInput(showAttachmentButton: showAttachmentButton),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
