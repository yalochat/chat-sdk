// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/widgets.dart';

class ChatTitle extends StatelessWidget {
  final String title;
  final String status;
  const ChatTitle({super.key, required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: SdkConstants.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: status.isEmpty ? 0 : SdkConstants.statusHeight,
          child: Text(
            status,
            style: TextStyle(fontSize: SdkConstants.statusFontSize),
          ),
        ),
      ],
    );
  }
}
