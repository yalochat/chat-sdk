// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.common

// Every repository method returns Result<T> instead of throwing exceptions.
sealed class Result<out T> {
    data class Ok<out T>(val result: T) : Result<T>()
    data class Error<out T>(val error: Exception) : Result<T>()
}

inline fun <T, R> Result<T>.map(transform: (T) -> R): Result<R> = when (this) {
    is Result.Ok -> Result.Ok(transform(result))
    is Result.Error -> Result.Error(error)
}

inline fun <T> Result<T>.onSuccess(action: (T) -> Unit): Result<T> {
    if (this is Result.Ok) action(result)
    return this
}

inline fun <T> Result<T>.onError(action: (Exception) -> Unit): Result<T> {
    if (this is Result.Error) action(error)
    return this
}

fun <T> Result<T>.getOrNull(): T? = when (this) {
    is Result.Ok -> result
    is Result.Error -> null
}
