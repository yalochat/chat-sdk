plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.compose.compiler)
    alias(libs.plugins.ksp)
    alias(libs.plugins.sqldelight)
}

android {
    namespace = "com.yalo.chat.sdk"
    compileSdk = 35

    defaultConfig {
        minSdk = 21
        consumerProguardFiles("consumer-proguard-rules.pro")
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
        // These detectors crash with IncompatibleClassChangeError on Kotlin 2.0.x due to
        // KaSimpleVariableAccessCall class-vs-interface breakage in the Analysis API.
        // Affects AGP 8.7.x bundled lifecycle and compose lint rules.
        // Tracked upstream: https://issuetracker.google.com/issues/kotlin-analysis-api
        disable += "NullSafeMutableLiveData"     // lifecycle 2.8.x lint
        disable += "RememberInComposition"       // compose-ui lint
        disable += "FrequentlyChangingValue"     // compose-ui lint
        disable += "AutoboxingStateCreation"     // compose-ui lint (same IncompatibleClassChangeError)
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

// Phase 2 M2 (FDE-54): SQLDelight schema for local message persistence.
// Schema file: src/main/sqldelight/com/yalo/chat/sdk/database/ChatMessage.sq
// KMP note: when splitting to KMP, add NativeSqliteDriver for iosMain here.
sqldelight {
    databases {
        create("ChatDatabase") {
            packageName.set("com.yalo.chat.sdk.database")
        }
    }
}

dependencies {
    // Compose BOM — all Compose artifact versions come from here
    val composeBom = platform(libs.compose.bom)
    implementation(composeBom)
    implementation(libs.compose.ui)
    implementation(libs.compose.ui.tooling.preview)
    implementation(libs.compose.material3)
    implementation(libs.compose.foundation)
    implementation(libs.compose.material.icons.core)
    implementation(libs.compose.material.icons.extended)
    debugImplementation(libs.compose.ui.tooling)

    // Lifecycle / ViewModel
    implementation(libs.lifecycle.viewmodel.ktx)
    implementation(libs.lifecycle.viewmodel.compose)
    implementation(libs.lifecycle.runtime.ktx)

    // Activity — provides rememberLauncherForActivityResult for image/camera picking.
    implementation(libs.activity.compose)

    // Coil — async image loading (FDE-59)
    implementation(libs.coil.compose)

    // Coroutines
    implementation(libs.coroutines.android)

    // Ktor — HTTP client
    // ktor-client-android uses Android's system HTTP stack (proper DNS resolution).
    // ktor-client-cio kept for tests (MockEngine is engine-agnostic).
    // When splitting to KMP: move ktor-client-android to androidMain, add Darwin for iosMain.
    implementation(libs.ktor.client.core)
    implementation(libs.ktor.client.android)
    implementation(libs.ktor.client.content.negotiation)
    implementation(libs.ktor.serialization.kotlinx.json)
    implementation(libs.ktor.client.logging)
    testImplementation(libs.ktor.client.cio)

    // kotlinx.serialization
    implementation(libs.kotlinx.serialization.json)

    // kotlinx.datetime — KMP-compatible (replaces java.text.SimpleDateFormat)
    implementation(libs.kotlinx.datetime)

    // SQLDelight — KMP-ready persistence (no Room)
    implementation(libs.sqldelight.android.driver)
    implementation(libs.sqldelight.coroutines.extensions)

    // Unit tests (JVM — no emulator required)
    testImplementation(libs.junit)
    testImplementation(libs.kotlin.test)
    testImplementation(libs.coroutines.test)
    testImplementation(libs.ktor.client.mock)
    testImplementation(libs.sqldelight.jdbc.driver)
}
