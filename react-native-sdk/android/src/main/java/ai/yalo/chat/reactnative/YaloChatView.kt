// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.ui.ChatView
import android.util.Log
import android.widget.FrameLayout
import androidx.activity.ComponentActivity
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeViewModelStoreOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import kotlinx.coroutines.CompletableDeferred
import org.json.JSONException
import org.json.JSONObject
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

/** Hosts the Android SDK chat inside a React Native view. */
internal class YaloChatView(private val reactContext: ThemedReactContext) : FrameLayout(reactContext) {

    private val chat = ChatView(reactContext)
    private var config: YaloChatClientConfig? = null
    private var client: YaloChatClient? = null

    var showsBackButton: Boolean = false
        set(value) {
            field = value
            chat.onBack = if (value) ::dispatchBack else null
        }

    /** The commands the JavaScript side registered a handler for. */
    var commands: List<String> = emptyList()
        set(value) {
            field = value
            registerCommands()
        }

    // Commands handed to JavaScript, waiting for it to answer.
    private val pendingCommands = ConcurrentHashMap<String, CompletableDeferred<Result<String>>>()

    private var layoutPending: Boolean = false

    init {
        addView(chat)
    }

    // React Native moves its views between parents, so the chat is pointed at
    // the screen it lives on instead of finding it through the window.
    override fun onAttachedToWindow() {
        val activity = reactContext.currentActivity as? ComponentActivity
        if (activity != null) {
            setViewTreeLifecycleOwner(activity)
            setViewTreeViewModelStoreOwner(activity)
            setViewTreeSavedStateRegistryOwner(activity)
        }
        super.onAttachedToWindow()
    }

    fun setConfig(value: String?) {
        val next = try {
            clientConfigOf(JSONObject(value ?: "{}"))
        } catch (error: JSONException) {
            Log.e(TAG, "The chat config could not be read, so the chat is not shown.", error)
            null
        }
        if (next == config) {
            return
        }
        config = next
        client = next?.let { YaloChatClient(it) }
        registerCommands()
        chat.client = client
    }

    fun setTheme(value: String?) {
        val overrides = try {
            JSONObject(value ?: "{}")
        } catch (error: JSONException) {
            Log.e(TAG, "The chat theme could not be read, so the default is used.", error)
            JSONObject()
        }
        chat.theme = { default -> default.overriddenBy(overrides) }
    }

    private fun registerCommands() {
        val current = client ?: return
        for (command in commands) {
            current.registerCommand(command) { payload -> runInJavaScript(command, payload) }
        }
    }

    /** Answers a command handed to JavaScript with what its handler returned. */
    fun resolveCommand(requestId: String, succeeded: Boolean, payload: String) {
        val result = if (succeeded) {
            Result.success(payload)
        } else {
            Result.failure(CommandFailedException())
        }
        pendingCommands.remove(requestId)?.complete(result)
    }

    private suspend fun runInJavaScript(command: String, payload: String): String {
        val requestId = UUID.randomUUID().toString()
        val answer = CompletableDeferred<Result<String>>()
        pendingCommands[requestId] = answer
        try {
            val surfaceId = UIManagerHelper.getSurfaceId(reactContext)
            UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)
                ?.dispatchEvent(CommandEvent(surfaceId, id, requestId, command, payload))
            return answer.await().getOrThrow()
        } finally {
            pendingCommands.remove(requestId)
        }
    }

    private fun dispatchBack() {
        val surfaceId = UIManagerHelper.getSurfaceId(reactContext)
        UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)?.dispatchEvent(BackEvent(surfaceId, id))
    }

    // React Native lays out its own views and ignores layout requests from
    // children, so the chat measures itself whenever Compose asks for it.
    override fun requestLayout() {
        super.requestLayout()
        if (layoutPending) {
            return
        }
        layoutPending = true
        post {
            layoutPending = false
            measure(
                MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY),
            )
            layout(left, top, right, bottom)
        }
    }

    private companion object {
        const val TAG: String = "YaloChatView"
    }
}

/** The JavaScript handler for a command threw or was missing. */
internal class CommandFailedException : IllegalStateException("The command handler failed")
