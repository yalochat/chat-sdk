// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart'
    show ChatThemeCubit;
import 'package:yalo_chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoMessage extends StatefulWidget {
  final ChatMessage message;

  const VideoMessage({super.key, required this.message});

  @override
  State<VideoMessage> createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    assert(
      widget.message.type == MessageType.video &&
          widget.message.fileName != null,
      'VideoMessage is only able to render video messages with non-empty fileName',
    );
    _controller = VideoPlayerController.file(File(widget.message.fileName!))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChatThemeCubit chatThemeCubit = context.watch<ChatThemeCubit>();
    final TextStyle textStyle = widget.message.role == MessageRole.user
        ? chatThemeCubit.chatTheme.userMessageTextStyle
        : chatThemeCubit.chatTheme.assistantMessageTextStyle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(SdkConstants.messageBorderRadius),
            child: _initialized
                ? GestureDetector(
                    onTap: _togglePlayPause,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        if (!_controller.value.isPlaying)
                          const Icon(
                            Icons.play_circle_fill,
                            size: 48,
                            color: Colors.white70,
                          ),
                      ],
                    ),
                  )
                : const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  ),
          ),
        ),
        SizedBox(height: SdkConstants.columnItemSpace),
        if (widget.message.content.isNotEmpty)
          SelectableText(
            widget.message.content,
            style: textStyle,
          ),
      ],
    );
  }
}
