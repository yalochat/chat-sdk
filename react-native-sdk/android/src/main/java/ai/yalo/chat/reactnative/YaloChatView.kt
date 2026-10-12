// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import ai.yalo.chat.sdk.YaloChatClient
import ai.yalo.chat.sdk.YaloChatClientConfig
import ai.yalo.chat.sdk.ui.Chat
import ai.yalo.chat.sdk.ui.theme.ChatTheme
import android.util.Log
import android.widget.FrameLayout
import androidx.activity.ComponentActivity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeViewModelStoreOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import org.json.JSONException
import org.json.JSONObject

/** Hosts the Android SDK chat inside a React Native view. */
internal class YaloChatView(private val reactContext: ThemedReactContext) : FrameLayout(reactContext) {

    private var config: YaloChatClientConfig? by mutableStateOf(null)
    private var theme: JSONObject by mutableStateOf(JSONObject())
    var showsBackButton: Boolean by mutableStateOf(false)

    private var layoutPending: Boolean = false

    init {
        addView(
            ComposeView(reactContext).apply {
                setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
                setContent { HostedChat() }
            },
        )
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
        config = try {
            clientConfigOf(JSONObject(value ?: "{}"))
        } catch (error: JSONException) {
            Log.e(TAG, "The chat config could not be read, so the chat is not shown.", error)
            null
        }
    }

    fun setTheme(value: String?) {
        theme = try {
            JSONObject(value ?: "{}")
        } catch (error: JSONException) {
            Log.e(TAG, "The chat theme could not be read, so the default is used.", error)
            JSONObject()
        }
    }

    @Composable
    private fun HostedChat() {
        val current = config ?: return
        val client = remember(current) { YaloChatClient(current) }
        val colors = if (isSystemInDarkTheme()) darkColorScheme() else lightColorScheme()
        MaterialTheme(colorScheme = colors) {
            Chat(
                client = client,
                theme = ChatTheme.default().overriddenBy(theme),
                onBack = if (showsBackButton) ::dispatchBack else null,
            )
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
