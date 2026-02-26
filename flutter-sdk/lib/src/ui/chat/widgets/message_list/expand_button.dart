// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpandButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Axis direction;
  const ExpandButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    final child = Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(text, style: chatThemeCubit.state.expandControlsStyle),
      ),
    );
    return (direction == Axis.vertical)
        ? Row(children: [Expanded(child: child)])
        : Column(mainAxisSize: MainAxisSize.min, children: [child]);
  }
}
