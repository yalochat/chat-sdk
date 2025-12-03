// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String imagePath;

  const ImagePreview({super.key, required this.imagePath});
  @override
  Widget build(BuildContext context) {
    File imageFile = File(imagePath);
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: SdkConstants.rowItemSpace, bottom: SdkConstants.rowItemSpace),
      child: Image.file(imageFile, width: 50, height: 50));
  }
}
