// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.data.services.auth

import com.yalo.chat.sdk.common.Result

// Port of flutter-sdk YaloMessageAuthService (data/services/auth).
// Calls POST /auth for anonymous token acquisition and POST /oauth/token for refresh.
// All results are wrapped in Result<T>; no exceptions are thrown to the caller.
interface YaloMessageAuthService {
    // Returns a valid access token.
    // On first call (no cache) — POSTs to /auth.
    // On subsequent calls — returns cached token if still valid, or POSTs to /oauth/token to refresh.
    suspend fun auth(): Result<String>
}
