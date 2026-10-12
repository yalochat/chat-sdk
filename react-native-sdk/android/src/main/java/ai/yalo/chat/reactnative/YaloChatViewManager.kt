// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.YaloChatViewManagerDelegate
import com.facebook.react.viewmanagers.YaloChatViewManagerInterface

@ReactModule(name = YaloChatViewManager.NAME)
internal class YaloChatViewManager :
    SimpleViewManager<YaloChatView>(),
    YaloChatViewManagerInterface<YaloChatView> {

    private val delegate: ViewManagerDelegate<YaloChatView> = YaloChatViewManagerDelegate(this)

    override fun getDelegate(): ViewManagerDelegate<YaloChatView> = delegate

    override fun getName(): String = NAME

    override fun createViewInstance(context: ThemedReactContext): YaloChatView = YaloChatView(context)

    @ReactProp(name = "config")
    override fun setConfig(view: YaloChatView, value: String?) {
        view.setConfig(value)
    }

    @ReactProp(name = "theme")
    override fun setTheme(view: YaloChatView, value: String?) {
        view.setTheme(value)
    }

    @ReactProp(name = "showsBackButton")
    override fun setShowsBackButton(view: YaloChatView, value: Boolean) {
        view.showsBackButton = value
    }

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any> =
        mapOf(BackEvent.NAME to mapOf("registrationName" to "onBack"))

    companion object {
        const val NAME: String = "YaloChatView"
    }
}
