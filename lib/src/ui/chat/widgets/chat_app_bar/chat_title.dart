// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatTitle extends StatelessWidget {

  const ChatTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ChatBloc, ChatState, (String, String)>(
      selector: (state) => (state.chatTitle, state.chatStatus),
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.$1,
              style: TextStyle(
                fontSize: SdkConstants.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: state.$2.isEmpty ? 0 : SdkConstants.statusHeight,
              child: Text(
                state.$2,
                style: TextStyle(fontSize: SdkConstants.statusFontSize),
              ),
            ),
          ],
        );
      },
    );
  }
}
