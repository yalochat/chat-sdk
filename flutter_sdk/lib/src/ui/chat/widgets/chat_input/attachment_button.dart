// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/translation.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/picker_button.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttachmentButton extends StatefulWidget {
  const AttachmentButton({super.key});

  @override
  State<AttachmentButton> createState() => _AttachmentButtonState();
}

class _AttachmentButtonState extends State<AttachmentButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    final imageBloc = context.read<ImageBloc>();
    animationController = BottomSheet.createAnimationController(this);
    animationController.addStatusListener((status) {
      if (status.isDismissed) {
        imageBloc.add(ImageShowPreview());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageBloc = context.read<ImageBloc>();
    return BlocBuilder<ChatThemeCubit, ChatTheme>(
      builder: (parentContext, chatTheme) {
        return IconButton(
          onPressed: () {
            if (imageBloc.state.pickedImage != null) {
              imageBloc.add(ImageHidePreview());
            }
            showModalBottomSheet(
              context: parentContext,
              transitionAnimationController: animationController,
              builder: (BuildContext context) {
                final orientation = MediaQuery.orientationOf(context);
                final size = MediaQuery.sizeOf(context);
                return BlocProvider.value(
                  value: BlocProvider.of<ChatThemeCubit>(parentContext),
                  child: Container(
                    height: orientation == Orientation.portrait
                        ? size.height * 0.25
                        : size.height * 0.5,
                    padding: EdgeInsets.all(SdkConstants.messageListMargin),
                    decoration: BoxDecoration(
                      color: chatTheme.attachmentPickerBackgroundColor,
                      borderRadius: BorderRadiusGeometry.circular(
                        SdkConstants.pickerButtonRadius,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.translate.sendImage,
                                  style: chatTheme.modalHeaderStyle,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  chatTheme.closeModalIcon,
                                  color: chatTheme.closeModalIconColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SdkConstants.columnItemSpace * 3),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: PickerButton(
                                    key: const Key('CameraPickerButton'),
                                    icon: Icon(
                                      chatTheme.cameraIcon,
                                      color: chatTheme.cameraIconColor,
                                    ),
                                    onPressed: () {
                                      imageBloc.add(ImagePickFromCamera());
                                      Navigator.pop(context);
                                    },
                                    text: context.translate.takePhoto,
                                  ),
                                ),
                                SizedBox(height: SdkConstants.columnItemSpace),
                                Expanded(
                                  flex: 1,
                                  child: PickerButton(
                                    key: const Key('GalleryPickerButton'),
                                    icon: Icon(
                                      chatTheme.galleryIcon,
                                      color: chatTheme.galleryIconColor,
                                    ),
                                    onPressed: () {
                                      imageBloc.add(ImagePickFromGallery());
                                      Navigator.pop(context);
                                    },
                                    text: context.translate.chooseFromGallery,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          icon: Icon(chatTheme.attachIcon, color: chatTheme.attachIconColor),
        );
      },
    );
  }
}
