// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/picker_button.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttachmentButton extends StatelessWidget {
  const AttachmentButton({super.key});

  @override
  Widget build(BuildContext context) {
    final imageBloc = context.read<ImageBloc>();
    return BlocBuilder<ChatThemeCubit, ChatTheme>(
      builder: (parentContext, chatTheme) {
        return IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: parentContext,
              builder: (BuildContext context) {
                return BlocProvider.value(
                  value: BlocProvider.of<ChatThemeCubit>(parentContext),
                  child: Container(
                    height: 275,
                    padding: EdgeInsets.all(SdkConstants.messageListMargin),
                    decoration: BoxDecoration(
                      color: chatTheme.attachmentPickerBackgroundColor,
                      borderRadius: BorderRadiusGeometry.circular(12),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Send an image',
                                  style: chatTheme.modalHeaderStyle,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: chatTheme.closeModalIcon,
                              ),
                            ],
                          ),
                          SizedBox(height: 26),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: PickerButton(
                                    icon: chatTheme.cameraIcon,
                                    onPressed: () {
                                      imageBloc.add(ImagePickFromCamera());
                                      Navigator.pop(context);
                                    },
                                    text: 'Take a photo',
                                  ),
                                ),
                                SizedBox(height: 8),
                                Expanded(
                                  flex: 1,
                                  child: PickerButton(
                                    icon: chatTheme.galleryIcon,
                                    onPressed: () {
                                      imageBloc.add(ImagePickFromGallery());
                                      Navigator.pop(context);
                                      ;
                                    },
                                    text: 'Choose from gallery',
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
          icon: chatTheme.attachIcon,
        );
      },
    );
  }
}
