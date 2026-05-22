// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Three-dot loading animation displayed at the bottom of the message list
// while the SDK is waiting for an assistant reply. Each dot fades and lifts
// on a staggered cycle to convey activity.
class TypingIndicator extends StatefulWidget {
  static const Duration cycleDuration = Duration(milliseconds: 1200);
  static const double dotSize = 8;
  static const double dotSpacing = 4;
  static const double maxLift = 4;

  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TypingIndicator.cycleDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatTheme = context.watch<ChatThemeCubit>().chatTheme;
    final Color dotColor = chatTheme.typingIndicatorDotColor;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SdkConstants.messagePadding,
        vertical: SdkConstants.columnItemSpace,
      ),
      child: Row(
        key: const Key('typing_indicator'),
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < 2 ? TypingIndicator.dotSpacing : 0,
            ),
            child: _AnimatedDot(
              controller: _controller,
              index: index,
              color: dotColor,
            ),
          );
        }),
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Color color;

  const _AnimatedDot({
    required this.controller,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Stagger each dot so they ripple instead of pulsing in unison.
    final double phase = index * 0.2;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final double t = (controller.value - phase) % 1.0;
        // Curve peaks halfway through the dot's cycle, then settles.
        final double wave = (t < 0.5)
            ? Curves.easeInOut.transform(t * 2)
            : Curves.easeInOut.transform((1 - t) * 2);
        final double opacity = 0.3 + 0.7 * wave;
        final double lift = TypingIndicator.maxLift * wave;
        return Transform.translate(
          offset: Offset(0, -lift),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: TypingIndicator.dotSize,
              height: TypingIndicator.dotSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
