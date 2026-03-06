// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.common

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNull
import kotlin.test.assertTrue

class ResultTest {

    @Test
    fun `Ok holds and returns result correctly`() {
        val result = Result.Ok(42)
        assertEquals(42, result.result)
    }

    @Test
    fun `Error holds error and message`() {
        val exception = Exception("something went wrong")
        val result = Result.Error<Int>(exception)
        assertEquals("something went wrong", result.error.message)
    }

    @Test
    fun `map transforms result inside Ok`() {
        val result = Result.Ok(10)
        val mapped = result.map { it * 2 }
        assertIs<Result.Ok<Int>>(mapped)
        assertEquals(20, mapped.result)
    }

    @Test
    fun `map passes Error through unchanged`() {
        val exception = Exception("error")
        val result: Result<Int> = Result.Error(exception)
        val mapped = result.map { it * 2 }
        assertIs<Result.Error<Int>>(mapped)
        assertEquals(exception, mapped.error)
    }

    @Test
    fun `onSuccess only executes for Ok`() {
        var called = false
        Result.Ok("hello").onSuccess { called = true }
        assertTrue(called)
    }

    @Test
    fun `onSuccess does not execute for Error`() {
        var called = false
        Result.Error<String>(Exception()).onSuccess { called = true }
        assertTrue(!called)
    }

    @Test
    fun `onError only executes for Error`() {
        var called = false
        Result.Error<String>(Exception("fail")).onError { called = true }
        assertTrue(called)
    }

    @Test
    fun `onError does not execute for Ok`() {
        var called = false
        Result.Ok("hello").onError { called = true }
        assertTrue(!called)
    }

    @Test
    fun `getOrNull returns result for Ok`() {
        assertEquals("value", Result.Ok("value").getOrNull())
    }

    @Test
    fun `getOrNull returns null for Error`() {
        assertNull(Result.Error<String>(Exception()).getOrNull())
    }
}
