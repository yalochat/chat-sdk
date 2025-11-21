// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';

class AttachmentButton extends StatelessWidget {
  const AttachmentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _handleAttachment(),
      icon: const Icon(Icons.attach_file),
    );
  }

  void _handleAttachment() {
    // Attachment logic
  }
}
