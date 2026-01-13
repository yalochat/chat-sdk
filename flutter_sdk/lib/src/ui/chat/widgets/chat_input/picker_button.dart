// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/colors.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PickerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Icon icon;

  const PickerButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatThemeCubit, ChatTheme>(
      builder: (context, chatTheme) {
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.only(
              left: SdkConstants.messagePadding,
              right: SdkConstants.messagePadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadiusGeometry.circular(
                SdkConstants.pickerButtonRadius,
              ),
              border: BoxBorder.all(
                width: 1,
                color: chatTheme.pickerButtonBorderColor,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                SizedBox(width: SdkConstants.iconButtonPadding),
                Text(text, style: chatTheme.modalHeaderStyle),
              ],
            ),
          ),
        );
      },
    );
  }
}
