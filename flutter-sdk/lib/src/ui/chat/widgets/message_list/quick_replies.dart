// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A container shown at the bottom of the message list that holds the quick
/// replies of the latest assistant message. Tapping a reply sends it as a
/// user message, so it appears inserted into the conversation.
class QuickReplies extends StatelessWidget {
  const QuickReplies({super.key});

  @override
  Widget build(BuildContext context) {
    final MessagesBloc chatBloc = context.read<MessagesBloc>();
    final Size size = MediaQuery.sizeOf(context);
    return BlocSelector<MessagesBloc, MessagesState, List<String>>(
      selector: (state) => state.quickReplies,
      builder: (BuildContext context, List<String> quickReplies) {
        // Expand the container into view from the bottom when replies arrive
        // and collapse it once they are cleared.
        return AnimatedSize(
          duration: SdkConstants.quickReplyAnimationDuration,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
          child: quickReplies.isEmpty
              ? const SizedBox(width: double.infinity)
              : BlocBuilder<ChatThemeCubit, ChatTheme>(
                  builder: (BuildContext context, ChatTheme theme) {
                    return Container(
                      key: const Key('quick_replies'),
                      width: double.infinity,
                      padding: EdgeInsets.all(SdkConstants.quickReplyPadding),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: SdkConstants.columnItemSpace,
                        runSpacing: SdkConstants.columnItemSpace,
                        children: quickReplies.map((String reply) {
                          return Container(
                            constraints: BoxConstraints(
                              maxWidth: size.width * 0.5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.quickReplyColor,
                              border: BoxBorder.all(
                                color: theme.quickReplyBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                SdkConstants.inputBorderRadius,
                              ),
                            ),
                            child: TextButton(
                              child: Text(reply, style: theme.quickReplyStyle),
                              onPressed: () {
                                chatBloc.add(ChatSendTextMessage(text: reply));
                                chatBloc.add(ChatClearQuickReplies());
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
