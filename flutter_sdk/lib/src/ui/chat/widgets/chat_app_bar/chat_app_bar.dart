// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_app_bar/chat_title.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onShopPressed;
  final VoidCallback? onCartPressed;
  const ChatAppBar({super.key, this.onShopPressed, this.onCartPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatThemeCubit, ChatTheme>(
      builder: (context, chatTheme) {
        return AppBar(
          backgroundColor: chatTheme.appBarBackgroundColor,
          title: Row(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image(
                    width: SdkConstants.imageIconSize,
                    height: SdkConstants.imageIconSize,
                    image: chatTheme.chatIconImage,
                  ),
                ),
              ),
              SizedBox(width: SdkConstants.rowItemSpace),
              Expanded(
                child: BlocSelector<MessagesBloc, MessagesState, (String, String)>(
                  selector: (state) => (state.chatTitle, state.chatStatusText),
                  builder: (context, state) {
                    return ChatTitle(title: state.$1, status: state.$2);
                  },
                ),
              ),
            ],
          ),
          actions: [
            if (onShopPressed != null)
            IconButton(icon: chatTheme.shopIcon, onPressed: onShopPressed),

            if (onCartPressed != null)
            IconButton(icon: chatTheme.cartIcon, onPressed: onCartPressed),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(SdkConstants.appBarPreferredSize);
}
