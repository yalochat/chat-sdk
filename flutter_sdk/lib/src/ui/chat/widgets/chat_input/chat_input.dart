// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/translation.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/image_preview.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/quick_reply.dart';
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
  final bool showAttachmentButton;
  const ChatInput({super.key, this.showAttachmentButton = true});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  OverlayEntry? _imagePreviewOverlay;
  OverlayEntry? _quickReplyOverlay;
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
                child: ImagePreview(
                  key: Key('ImagePreview'),
                  imagePath: pickedImage.path,
                ),
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

  void _createQuickReplyOverlay(List<String> quickReplies) {
    _removeQuickReplyOverlay();
    final parentContext = context;
    _quickReplyOverlay = OverlayEntry(
      builder: (context) {
        return BlocProvider.value(
          value: BlocProvider.of<ChatThemeCubit>(parentContext),
          child: BlocProvider.value(
            value: BlocProvider.of<MessagesBloc>(parentContext),
            child: Align(
              child: CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.topCenter,
                followerAnchor: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(SdkConstants.quickReplyPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    spacing: SdkConstants.columnItemSpace,
                    children: quickReplies
                        .map((reply) => QuickReply(text: reply))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(
      parentContext,
      debugRequiredFor: widget,
    ).insert(_quickReplyOverlay!);
  }

  void _removeQuickReplyOverlay() {
    _quickReplyOverlay?.remove();
    _quickReplyOverlay?.dispose();
    _quickReplyOverlay = null;
  }

  @override
  void dispose() {
    _removeImagePreviewOverlay();
    _removeQuickReplyOverlay();
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
          child: BlocListener<MessagesBloc, MessagesState>(
            listenWhen: (previous, current) =>
                previous.quickReplies != current.quickReplies,
            listener: (BuildContext context, MessagesState state) {
              if (state.quickReplies.isNotEmpty) {
                _createQuickReplyOverlay(state.quickReplies);
              } else {
                _removeQuickReplyOverlay();
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: SdkConstants.rowItemSpace * 3),
                                Expanded(
                                  child: isUserRecordingAudio
                                      ? WaveformRecorder(
                                          key: const Key('WaveformRecorder'),
                                        )
                                      : MessageTextField(
                                          key: const Key('MessageTextField'),
                                          hintText:
                                              context.translate.typeMessage,
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
          ),
        );
      },
    );
  }
}
