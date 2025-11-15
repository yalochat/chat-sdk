// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok._;

  const factory Result.error(Exception error) = Error._;
}

final class Ok<T> extends Result<T> with EquatableMixin {
  final T result;
  const Ok._(this.result);

  @override
  List<Object?> get props => [result];
}

final class Error<T> extends Result<T> with EquatableMixin {
  final Exception error;
  const Error._(this.error);

  @override
  List<Object?> get props => [error];
}
