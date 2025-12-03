// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({super.key});

  void _handleCamera(ImageBloc bloc) {
    bloc.add(ImagePick());
  }

  @override
  Widget build(BuildContext context) {
    final imageBloc = context.read<ImageBloc>();
    return IconButton(
      onPressed: () => _handleCamera(imageBloc),
      icon: const Icon(Icons.photo_camera),
    );
  }
}
