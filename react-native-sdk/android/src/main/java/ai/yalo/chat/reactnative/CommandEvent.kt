// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

/** The channel asked for a command the JavaScript side registered. */
internal class CommandEvent(
    surfaceId: Int,
    viewId: Int,
    private val requestId: String,
    private val command: String,
    private val payload: String,
) : Event<CommandEvent>(surfaceId, viewId) {

    override fun getEventName(): String = NAME

    override fun getEventData(): WritableMap = Arguments.createMap().apply {
        putString("requestId", requestId)
        putString("command", command)
        putString("payload", payload)
    }

    companion object {
        const val NAME: String = "topCommand"
    }
}
