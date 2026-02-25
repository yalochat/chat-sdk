// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

sealed class ChatEvent {}

final class TypingStart extends ChatEvent with EquatableMixin {
  final String statusText;

  TypingStart({required this.statusText});

  @override
  List<Object?> get props => [statusText];
}

final class TypingStop extends ChatEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}
