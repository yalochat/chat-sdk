// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const ChatAppBar({super.key, required this.title});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: SdkConstants.titleFontSize, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Tomando pedido...',
                      style: TextStyle(fontSize: SdkConstants.statusFontSize),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(icon: chatTheme.shopIcon, onPressed: () {}),
            IconButton(icon: chatTheme.cartIcon, onPressed: () {}),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(SdkConstants.appBarPreferredSize);
}
