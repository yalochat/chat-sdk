// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/product_expanded_card.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssistantProductMessage extends StatelessWidget {
  final ChatMessage message;

  const AssistantProductMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();

    final product = message.products[0];

    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxHeight: orientation == Orientation.portrait
                ? size.height * 0.22
                : size.height * 0.5,
          ),
          width: constraints.maxWidth,
          padding: EdgeInsets.all(SdkConstants.messagePadding),
          decoration: BoxDecoration(
            color: chatThemeCubit.chatTheme.backgroundColor,
            border: BoxBorder.all(
              color: chatThemeCubit.chatTheme.cardBorderColor,
            ),
            borderRadius: BorderRadius.circular(
              SdkConstants.messageBorderRadius,
            ),
          ),
          child: ProductExpandedCard(message: message, product: product),
        );
      },
    );
  }
}
