// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:math';

import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> _amplitudes;
  final Color _barColor;

  WaveformPainter(List<double> amplitudes, Color barColor)
    : _amplitudes = amplitudes,
      _barColor = barColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _amplitudes.length; i++) {
      // Convert from dbfs to 0 to 1.
      final amplitude = pow(10, (_amplitudes[i] / 20)).toDouble();
      final height = max(0.05 * size.height, amplitude * size.height);
      final barWidth = size.width / _amplitudes.length;
      final rect = Rect.fromCenter(
        center: Offset(i * barWidth, size.height / 2),
        width: barWidth * 0.8,
        height: height,
      );
      final rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(SdkConstants.soundBarsRadius),
      );
      canvas.drawRRect(rrect, Paint()..color = _barColor);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return _amplitudes != oldDelegate._amplitudes;
  }
}
