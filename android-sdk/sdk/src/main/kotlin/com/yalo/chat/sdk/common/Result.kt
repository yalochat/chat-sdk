// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.common

// Port of flutter-sdk/lib/src/common/result.dart
// Every repository method returns Result<T> instead of throwing exceptions.
// Zero Android dependencies — KMP-ready.
sealed class Result<out T> {
    data class Ok<out T>(val value: T) : Result<T>()
    data class Error<out T>(val exception: Exception) : Result<T>()
}

inline fun <T, R> Result<T>.map(transform: (T) -> R): Result<R> = when (this) {
    is Result.Ok -> Result.Ok(transform(value))
    is Result.Error -> Result.Error(exception)
}

inline fun <T> Result<T>.onSuccess(action: (T) -> Unit): Result<T> {
    if (this is Result.Ok) action(value)
    return this
}

inline fun <T> Result<T>.onError(action: (Exception) -> Unit): Result<T> {
    if (this is Result.Error) action(exception)
    return this
}

fun <T> Result<T>.getOrNull(): T? = when (this) {
    is Result.Ok -> value
    is Result.Error -> null
}
