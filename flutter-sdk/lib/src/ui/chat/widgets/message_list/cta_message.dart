// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class CtaMessage extends StatelessWidget {
  final ChatMessage message;

  const CtaMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ChatThemeCubit>().chatTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.header != null && message.header!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              bottom: SdkConstants.columnItemSpace / 2,
            ),
            child: Text(message.header!, style: theme.messageHeaderStyle),
          ),
        if (message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              bottom: SdkConstants.columnItemSpace / 2,
            ),
            child: Text(
              message.content,
              style: theme.assistantMessageTextStyle,
            ),
          ),
        if (message.footer != null && message.footer!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: SdkConstants.columnItemSpace),
            child: Text(message.footer!, style: theme.messageFooterStyle),
          ),
        ...message.ctaButtons.map(
          (button) => Padding(
            padding: const EdgeInsets.only(top: SdkConstants.columnItemSpace),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: theme.ctaButtonColor,
                foregroundColor: theme.ctaButtonForegroundColor,
                side: BorderSide(color: theme.ctaButtonBorderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    SdkConstants.messageBorderRadius / 2,
                  ),
                ),
              ),
              onPressed: () => launchUrl(
                Uri.parse(button.url),
                mode: LaunchMode.externalApplication,
              ),
              icon: Text(button.text, style: theme.ctaButtonTextStyle),
              label: Icon(
                theme.ctaArrowForwardIcon,
                color: theme.ctaButtonForegroundColor,
                size: SdkConstants.titleFontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
