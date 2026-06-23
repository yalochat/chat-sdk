// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// A confirmation card for a product action. Shows a header, a content body, a
// primary button that confirms the action (e.g. updating the cart) and a
// footer text link that sends its text as a user message. Once confirmed the
// button is disabled and shows a check icon, a state that is persisted so it
// survives reopening the chat.
class ProductConfirmationMessage extends StatefulWidget {
  final ChatMessage message;

  const ProductConfirmationMessage({super.key, required this.message});

  @override
  State<ProductConfirmationMessage> createState() =>
      _ProductConfirmationMessageState();
}

class _ProductConfirmationMessageState
    extends State<ProductConfirmationMessage> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final ChatMessage message = widget.message;
    final ChatTheme chatTheme = context.watch<ChatThemeCubit>().chatTheme;
    final bool confirmed =
        _confirmed || message.status == MessageStatus.clicked;
    final bool hasHeader = message.header != null && message.header!.isNotEmpty;
    final bool hasFooter = message.footer != null && message.footer!.isNotEmpty;
    final String buttonText = message.buttons.isNotEmpty
        ? message.buttons.first.text
        : '';

    return Flexible(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: SdkConstants.rowItemSpace),
        padding: EdgeInsets.all(SdkConstants.messagePadding),
        decoration: BoxDecoration(
          color: chatTheme.cardBackgroundColor,
          border: Border.all(color: chatTheme.cardBorderColor),
          borderRadius: BorderRadius.circular(SdkConstants.messageBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasHeader)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: SdkConstants.columnItemSpace / 2,
                ),
                child: Text(
                  message.header!,
                  style: chatTheme.messageHeaderStyle,
                ),
              ),
            Text(message.content, style: chatTheme.assistantMessageTextStyle),
            Padding(
              padding: const EdgeInsets.only(top: SdkConstants.columnItemSpace),
              child: FilledButton(
                key: const Key('product_confirmation_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: confirmed
                      ? chatTheme.productConfirmationButtonConfirmedColor
                      : chatTheme.productConfirmationButtonColor,
                  foregroundColor: confirmed
                      ? chatTheme
                            .productConfirmationButtonConfirmedForegroundColor
                      : chatTheme.productConfirmationButtonForegroundColor,
                  disabledBackgroundColor:
                      chatTheme.productConfirmationButtonConfirmedColor,
                  disabledForegroundColor: chatTheme
                      .productConfirmationButtonConfirmedForegroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      SdkConstants.messageBorderRadius / 2,
                    ),
                  ),
                ),
                onPressed: confirmed ? null : () => _confirm(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (confirmed) ...[
                      Icon(
                        chatTheme.productConfirmationConfirmedIcon,
                        size: SdkConstants.titleFontSize,
                      ),
                      const SizedBox(width: SdkConstants.rowItemSpace / 2),
                    ],
                    Flexible(child: Text(buttonText)),
                  ],
                ),
              ),
            ),
            if (hasFooter)
              TextButton(
                key: const Key('product_confirmation_footer'),
                onPressed: () => context.read<MessagesBloc>().add(
                  ChatSendTextMessage(text: message.footer),
                ),
                child: Text(
                  message.footer!,
                  style: chatTheme.messageFooterStyle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    setState(() {
      _confirmed = true;
    });
    context.read<MessagesBloc>().add(
      ChatConfirmProductConfirmation(messageId: widget.message.id!),
    );
  }
}
