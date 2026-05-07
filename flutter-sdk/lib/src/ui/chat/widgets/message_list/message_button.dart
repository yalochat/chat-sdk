// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/button.dart'
    as domain;
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/constants.dart';

// Renders a single message-attached button. POSTBACK buttons dispatch the
// button text back through the chat (matches the legacy buttons_message
// styling). LINK buttons open the configured url externally (matches the
// legacy cta_message styling). REPLY buttons are surfaced as quick-reply
// chips in the chat input, so this widget renders nothing for them.
class MessageButton extends StatelessWidget {
  final domain.Button button;

  const MessageButton({super.key, required this.button});

  @override
  Widget build(BuildContext context) {
    final chatTheme = context.watch<ChatThemeCubit>().chatTheme;
    final radius = BorderRadius.circular(SdkConstants.messageBorderRadius / 2);

    return SizedBox(
      width: double.infinity,
      child: switch (button.type) {
        domain.ButtonType.postback => OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: chatTheme.buttonsMessageButtonColor,
            foregroundColor: chatTheme.buttonsMessageButtonForegroundColor,
            side: BorderSide(
              color: chatTheme.buttonsMessageButtonBorderColor,
            ),
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          onPressed: () => context.read<MessagesBloc>().add(
            ChatSendTextMessage(text: button.text),
          ),
          child: Text(
            button.text,
            style: chatTheme.buttonsMessageButtonTextStyle,
          ),
        ),
        domain.ButtonType.link => OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: chatTheme.ctaButtonColor,
            foregroundColor: chatTheme.ctaButtonForegroundColor,
            side: BorderSide(color: chatTheme.ctaButtonBorderColor),
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          onPressed: () => launchUrl(
            Uri.parse(button.url!),
            mode: LaunchMode.externalApplication,
          ),
          icon: Text(button.text, style: chatTheme.ctaButtonTextStyle),
          label: Icon(
            chatTheme.ctaArrowForwardIcon,
            color: chatTheme.ctaButtonForegroundColor,
            size: SdkConstants.titleFontSize,
          ),
        ),
        domain.ButtonType.reply => const SizedBox.shrink(),
      },
    );
  }
}
