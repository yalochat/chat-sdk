plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.compose.compiler)
    alias(libs.plugins.ksp)
    // SQLDelight plugin deferred to Phase 2 — no .sq files yet
    // alias(libs.plugins.sqldelight)
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
    }

    lint {
        // These detectors crash with IncompatibleClassChangeError on Kotlin 2.0.x due to
        // KaSimpleVariableAccessCall class-vs-interface breakage in the Analysis API.
        // Affects AGP 8.7.x bundled lifecycle and compose lint rules.
        // Tracked upstream: https://issuetracker.google.com/issues/kotlin-analysis-api
        disable += "NullSafeMutableLiveData"     // lifecycle 2.8.x lint
        disable += "RememberInComposition"       // compose-ui lint
        disable += "FrequentlyChangingValue"     // compose-ui lint
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

// SQLDelight schema and ChatDatabase configuration deferred to Phase 2 (FDE-54).
// Will be added here once .sq files exist under src/main/sqldelight/.

dependencies {
    // Compose BOM — all Compose artifact versions come from here
    val composeBom = platform(libs.compose.bom)
    implementation(composeBom)
    implementation(libs.compose.ui)
    implementation(libs.compose.ui.tooling.preview)
    implementation(libs.compose.material3)
    implementation(libs.compose.foundation)
    debugImplementation(libs.compose.ui.tooling)

    // Lifecycle / ViewModel
    implementation(libs.lifecycle.viewmodel.ktx)
    implementation(libs.lifecycle.viewmodel.compose)
    implementation(libs.lifecycle.runtime.ktx)

    // Coroutines
    implementation(libs.coroutines.android)

    // Ktor — KMP-ready HTTP client (no OkHttp)
    implementation(libs.ktor.client.core)
    implementation(libs.ktor.client.cio)
    implementation(libs.ktor.client.content.negotiation)
    implementation(libs.ktor.serialization.kotlinx.json)

    // kotlinx.serialization
    implementation(libs.kotlinx.serialization.json)

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
