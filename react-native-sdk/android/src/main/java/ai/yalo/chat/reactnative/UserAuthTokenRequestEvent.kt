// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

/** The chat is authenticating and needs a token from the JavaScript provider. */
internal class UserAuthTokenRequestEvent(
    surfaceId: Int,
    viewId: Int,
    private val requestId: String,
) : Event<UserAuthTokenRequestEvent>(surfaceId, viewId) {

    override fun getEventName(): String = NAME

    override fun getEventData(): WritableMap = Arguments.createMap().apply {
        putString("requestId", requestId)
    }

    companion object {
        const val NAME: String = "topUserAuthTokenRequest"
    }
}
