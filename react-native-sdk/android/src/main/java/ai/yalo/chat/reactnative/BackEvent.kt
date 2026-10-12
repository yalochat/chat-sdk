// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

/** The header's back button was pressed. */
internal class BackEvent(surfaceId: Int, viewId: Int) : Event<BackEvent>(surfaceId, viewId) {

    override fun getEventName(): String = NAME

    override fun getEventData(): WritableMap = Arguments.createMap()

    companion object {
        const val NAME: String = "topBack"
    }
}
