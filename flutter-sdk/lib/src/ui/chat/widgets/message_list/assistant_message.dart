// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/button.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/widgets/message_list/assistant_product_message.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/widgets/message_list/image_message.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/widgets/message_list/message_button.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/widgets/message_list/video_message.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AssistantMessage extends StatelessWidget {
  final ChatMessage message;
  const AssistantMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    assert(
      message.role == MessageRole.assistant,
      'AssistantMessages can only render messages with role assistant',
    );
    final chatTheme = context.watch<ChatThemeCubit>().chatTheme;
    final hasHeader = message.header != null && message.header!.isNotEmpty;
    final hasFooter = message.footer != null && message.footer!.isNotEmpty;
    // REPLY-typed buttons surface as quick-reply chips in the chat input,
    // so the message bubble only renders POSTBACK and LINK buttons.
    final inlineButtons = message.buttons
        .where((b) => b.type != ButtonType.reply)
        .toList();
    return Flexible(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            padding: EdgeInsets.all(SdkConstants.messagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                switch (message.type) {
                  MessageType.text => Container(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.9,
                    ),
                    child: Markdown(
                      data: message.content,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      styleSheet: MarkdownStyleSheet(
                        textAlign: WrapAlignment.start,
                        p: chatTheme.assistantMessageTextStyle,
                      ),
                      onTapLink: (String text, String? href, String title) {
                        if (href != null) {
                          launchUrl(
                            Uri.parse(href),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ),
                  MessageType.image => ImageMessage(message: message),
                  MessageType.video => VideoMessage(message: message),
                  MessageType.product => AssistantProductMessage(
                    message: message,
                    direction: Axis.vertical,
                  ),
                  MessageType.productCarousel => AssistantProductMessage(
                    message: message,
                    direction: Axis.horizontal,
                  ),
                  // FIXME: Instead of throwing a special message could be rendered
                  _ => throw UnimplementedError(
                    'Unimplemented assistant message type ${message.type}',
                  ),
                },
                if (hasFooter)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: SdkConstants.columnItemSpace / 2,
                    ),
                    child: Text(
                      message.footer!,
                      style: chatTheme.messageFooterStyle,
                    ),
                  ),
                ...inlineButtons.map(
                  (button) => Padding(
                    padding: const EdgeInsets.only(
                      top: SdkConstants.columnItemSpace,
                    ),
                    child: MessageButton(button: button),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
