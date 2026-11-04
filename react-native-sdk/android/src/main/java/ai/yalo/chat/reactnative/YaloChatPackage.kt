// Copyright (c) Yalochat, Inc. All rights reserved.
package ai.yalo.chat.reactnative

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.react.uimanager.ViewManager

public class YaloChatPackage : BaseReactPackage() {

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> =
        listOf(YaloChatViewManager())

    override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? = when (name) {
        YaloChatModule.NAME -> YaloChatModule(reactContext)
        else -> null
    }

    override fun getReactModuleInfoProvider(): ReactModuleInfoProvider = ReactModuleInfoProvider {
        mapOf(
            YaloChatModule.NAME to ReactModuleInfo(
                YaloChatModule.NAME,
                YaloChatModule::class.java.name,
                false,
                false,
                false,
                BuildConfig.IS_NEW_ARCHITECTURE_ENABLED,
            ),
        )
    }
}
