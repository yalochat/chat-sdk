// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

final class Unit extends Equatable {
  @override
  List<Object?> get props => [];
}

// A class to represent results from repositories and services
sealed class Result<T> {
  const Result();

  // Used to create an Ok return value
  const factory Result.ok(T value) = Ok._;

  // Used to create an error return value
  const factory Result.error(Exception error) = Error._;
}

// Ok holds a valid return value
final class Ok<T> extends Result<T> with EquatableMixin {
  final T result;
  const Ok._(this.result);

  @override
  List<Object?> get props => [result];
}

// Error holds an exception that need to be handler by the caller
final class Error<T> extends Result<T> with EquatableMixin {
  // The exception that was thrown
  final Exception error;
  const Error._(this.error);

  @override
  List<Object?> get props => [error];
}
