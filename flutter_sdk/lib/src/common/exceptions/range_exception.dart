// Copyright (c) Yalochat, Inc. All rights reserved.

class RangeException implements Exception {
  final int wrongValue;
  final int? minValue;
  final int? maxValue;
  final String message;

  RangeException(String message, this.wrongValue, [this.minValue, this.maxValue]) : message = '$message received $wrongValue, maxValue: $maxValue, minValue $minValue';
}
