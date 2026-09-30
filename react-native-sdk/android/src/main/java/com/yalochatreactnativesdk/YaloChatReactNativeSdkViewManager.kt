package com.yalochatreactnativesdk

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.YaloChatReactNativeSdkViewManagerInterface
import com.facebook.react.viewmanagers.YaloChatReactNativeSdkViewManagerDelegate

@ReactModule(name = YaloChatReactNativeSdkViewManager.NAME)
class YaloChatReactNativeSdkViewManager : SimpleViewManager<YaloChatReactNativeSdkView>(),
  YaloChatReactNativeSdkViewManagerInterface<YaloChatReactNativeSdkView> {
  private val mDelegate: ViewManagerDelegate<YaloChatReactNativeSdkView>

  init {
    mDelegate = YaloChatReactNativeSdkViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<YaloChatReactNativeSdkView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): YaloChatReactNativeSdkView {
    return YaloChatReactNativeSdkView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: YaloChatReactNativeSdkView?, color: Int?) {
    view?.setBackgroundColor(color ?: Color.TRANSPARENT)
  }

  companion object {
    const val NAME = "YaloChatReactNativeSdkView"
  }
}
