// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/image_preview.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/waveform_recorder.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'action_button.dart';
import 'attachment_button.dart';
import 'message_text_field.dart';

class ChatInput extends StatefulWidget {
  final String hintText;
  final bool showAttachmentButton;
  const ChatInput({
    super.key,
    this.hintText = '',
    this.showAttachmentButton = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  OverlayEntry? _imagePreviewOverlay;
  final LayerLink _layerLink = LayerLink();

  void _createImagePreviewOverlay(ImageData pickedImage) {
    _removeImagePreviewOverlay();

    final parentContext = context;
    _imagePreviewOverlay = OverlayEntry(
      builder: (context) {
        return BlocProvider.value(
          value: BlocProvider.of<ChatThemeCubit>(parentContext),
          child: BlocProvider.value(
            value: BlocProvider.of<ImageBloc>(parentContext),
            child: Align(
              child: CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.topLeft,
                followerAnchor: Alignment.bottomLeft,
                child: ImagePreview(key: Key('ImagePreview'), imagePath: pickedImage.path),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(
      parentContext,
      debugRequiredFor: widget,
    ).insert(_imagePreviewOverlay!);
  }

  void _removeImagePreviewOverlay() {
    _imagePreviewOverlay?.remove();
    _imagePreviewOverlay?.dispose();
    _imagePreviewOverlay = null;
  }

  @override
  void dispose() {
    _removeImagePreviewOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatThemeCubit, ChatTheme>(
      builder: (context, chatTheme) {
        return BlocListener<ImageBloc, ImageState>(
          listenWhen: (previous, current) =>
              previous.pickedImage != current.pickedImage,
          listener: (BuildContext context, ImageState state) {
            if (state.pickedImage != null) {
              _createImagePreviewOverlay(state.pickedImage!);
            } else {
              _removeImagePreviewOverlay();
            }
          },
          child: Container(
            padding: EdgeInsets.all(SdkConstants.inputPadding),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: SdkConstants.rowItemSpace),
                    constraints: BoxConstraints(
                      maxHeight: SdkConstants.maxChatInputSize,
                    ),
                    decoration: BoxDecoration(
                      color: chatTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(
                        SdkConstants.inputBorderRadius,
                      ),
                      border: Border.all(
                        width: 1,
                        color: chatTheme.inputTextFieldBorderColor,
                      ),
                    ),
                    child: BlocSelector<AudioBloc, AudioState, bool>(
                      selector: (state) => state.isUserRecordingAudio,
                      builder: (context, isUserRecordingAudio) {
                        return CompositedTransformTarget(
                          link: _layerLink,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(width: SdkConstants.rowItemSpace * 3),
                              Expanded(
                                child: isUserRecordingAudio
                                    ? WaveformRecorder(
                                        key: const Key('WaveformRecorder'),
                                      )
                                    : MessageTextField(
                                        key: const Key('MessageTextField'),
                                        hintText: widget.hintText,
                                      ),
                              ),
                              if (widget.showAttachmentButton &&
                                  !isUserRecordingAudio)
                                AttachmentButton(
                                  key: const Key('AttachmentButton'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: SdkConstants.rowItemSpace,
                    right: SdkConstants.rowItemSpace,
                  ),
                  child: ActionButton(key: const Key('ActionButton')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
