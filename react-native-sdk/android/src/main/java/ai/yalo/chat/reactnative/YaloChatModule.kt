// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.YaloChatClient
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import org.json.JSONException
import org.json.JSONObject

/** What the JavaScript client asks of the SDK outside of a chat on screen. */
@ReactModule(name = YaloChatModule.NAME)
internal class YaloChatModule(private val context: ReactApplicationContext) : NativeYaloChatSpec(context) {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    override fun getName(): String = NAME

    override fun clearMessages(config: String, promise: Promise) {
        run(config, promise) { client -> client.clearMessages(context) }
    }

    override fun logout(config: String, promise: Promise) {
        run(config, promise) { client -> client.logout(context) }
    }

    override fun invalidate() {
        scope.cancel()
        super.invalidate()
    }

    private fun run(config: String, promise: Promise, action: suspend (YaloChatClient) -> Unit) {
        val client = try {
            YaloChatClient(clientConfigOf(JSONObject(config)))
        } catch (error: JSONException) {
            promise.reject(INVALID_CONFIG, error)
            return
        }
        scope.launch {
            action(client)
            promise.resolve(null)
        }
    }

    companion object {
        const val NAME: String = "YaloChat"
        private const val INVALID_CONFIG = "invalid_config"
    }
}
