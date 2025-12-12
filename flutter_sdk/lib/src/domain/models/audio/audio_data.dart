// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

class AudioData extends Equatable {
  final String fileName;
  final List<double> amplitudes;
  final List<double> amplitudesFilePreview;
  // The duration in milliseconds of the audio
  final int duration;

  AudioData({
    this.fileName = '',
    List<double>? amplitudes,
    List<double>? amplitudesFilePreview,
    this.duration = 0,
  }) : amplitudes = amplitudes ?? [],
       amplitudesFilePreview = amplitudesFilePreview ?? [];

  AudioData copyWith({
    String? fileName,
    List<double>? amplitudes,
    List<double>? amplitudesFilePreview,
    int? duration,
  }) {
    return AudioData(
      fileName: fileName ?? this.fileName,
      amplitudes: amplitudes ?? this.amplitudes,
      amplitudesFilePreview:
          amplitudesFilePreview ?? this.amplitudesFilePreview,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [fileName, amplitudes, duration, amplitudesFilePreview];
}
