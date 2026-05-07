// Copyright (c) Yalochat, Inc. All rights reserved.

import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.compose.compiler)
    alias(libs.plugins.ksp)
    alias(libs.plugins.hilt)
}

// Read demo credentials from local.properties (never committed to git).
// Copy local.properties.example → local.properties and fill in the values.
val localProps = Properties().also { props ->
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { props.load(it) }
}

fun localProp(key: String): String {
    val value = localProps.getProperty(key, "")
    if (value.isEmpty()) {
        logger.warn("WARNING: local.properties is missing '$key'. Copy local.properties.example → local.properties and fill in the values. The demo app will fail at runtime.")
    }
    return value
}

android {
    namespace = "com.yalo.chat.demo"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.yalo.chat.demo"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        buildConfigField("String",  "YALO_CHANNEL_NAME",      "\"${localProp("yalo.channelName")}\"")
        buildConfigField("String",  "YALO_CHANNEL_ID",        "\"${localProp("yalo.channelId")}\"")
        buildConfigField("String",  "YALO_ORGANIZATION_ID",   "\"${localProp("yalo.organizationId")}\"")
        buildConfigField("String",  "YALO_ENVIRONMENT",       "\"${localProps.getProperty("yalo.environment", "PRODUCTION")}\"")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    lint {
        // IncompatibleClassChangeError crashes from buggy lint detectors on Kotlin 2.x / AGP 8.x.
        disable += "NullSafeMutableLiveData"
        disable += "RememberInComposition"
        disable += "FrequentlyChangingValue"
        disable += "AutoboxingStateCreation"
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

dependencies {
    implementation(project(":sdk"))

    // Compose BOM
    val composeBom = platform(libs.compose.bom)
    implementation(composeBom)
    implementation(libs.compose.ui)
    implementation(libs.compose.material3)
    implementation(libs.compose.material.icons.extended)
    implementation(libs.compose.ui.tooling.preview)
    debugImplementation(libs.compose.ui.tooling)

    // Activity Compose — provides setContent {}
    implementation(libs.activity.compose)

    // Lifecycle
    implementation(libs.lifecycle.runtime.ktx)

    // Hilt — app only, never inside :sdk
    implementation(libs.hilt.android)
    ksp(libs.hilt.compiler)
}
