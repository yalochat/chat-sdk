// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:math';

import 'package:chat_flutter_sdk/src/common/translation.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/expand_button.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/product_horizontal_card.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/product_vertical_card.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssistantProductMessage extends StatelessWidget {
  final ChatMessage message;
  final Axis direction;

  const AssistantProductMessage({
    super.key,
    required this.message,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    final messagesBloc = context.read<MessagesBloc>();

    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);

    assert(message.id != null, 'Message id must not be null');

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemCount = (message.expand)
            ? message.products.length + 1
            : min(
                SdkConstants.collapsedListMaxItems + 1,
                message.products.length,
              );
        final maxItems = SdkConstants.collapsedListMaxItems;

        double maxHeight = double.infinity;
        double maxWidth = double.infinity;
        if (direction == Axis.vertical) {
          maxHeight = orientation == Orientation.portrait
              ? size.height * 0.30
              : size.height * 0.5;
          maxWidth = constraints.maxWidth;
        } else {
          maxWidth = orientation == Orientation.portrait ? constraints.maxWidth * 0.6 : constraints.maxWidth * 0.3;
          maxHeight = double.infinity;
        }
        final children = [
          for (int index = 0; index < itemCount; index++)
            if (!message.expand &&
                message.products.length > maxItems &&
                index == maxItems)
              ExpandButton(
                direction: direction,
                onPressed: () {
                  messagesBloc.add(
                    ChatToggleMessageExpand(messageId: message.id!),
                  );
                },
                text: context.translate.showMore,
              )
            else if (message.expand && index == message.products.length)
              ExpandButton(
                direction: direction,
                onPressed: () {
                  messagesBloc.add(
                    ChatToggleMessageExpand(messageId: message.id!),
                  );
                },
                text: context.translate.showLess,
              )
            else
              Container(
                margin: (direction == Axis.vertical)
                    ? EdgeInsets.only(top: SdkConstants.messageListMargin)
                    : EdgeInsets.only(right: SdkConstants.rowItemSpace),
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: maxWidth,
                    maxHeight: maxHeight,
                  ),
                  width: (direction == Axis.vertical)
                      ? constraints.maxWidth
                      : maxWidth,
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
                  child: (direction == Axis.vertical)
                      ? ProductHorizontalCard(
                          message: message,
                          product: message.products[index],
                        )
                      : ProductVerticalCard(
                          message: message,
                          product: message.products[index],
                        ),
                ),
              ),
        ];
        return (direction == Axis.vertical)
            ? Column(
              mainAxisSize: MainAxisSize.min,
              children: children)
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: children),
              );
      },
    );
  }
}
