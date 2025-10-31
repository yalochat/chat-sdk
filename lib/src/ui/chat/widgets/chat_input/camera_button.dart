// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _handleCamera(context),
      icon: const Icon(Icons.photo_camera),
    );
  }

  void _handleCamera(BuildContext context) {
    // Attachment logic
  }
}
