import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.plugin.KotlinPlatformType
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

val localProps = Properties().also { props ->
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { props.load(it) }
}

plugins {
    alias(libs.plugins.kotlin.multiplatform)
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.compose.compiler)
    alias(libs.plugins.ksp)
    alias(libs.plugins.sqldelight)
}

kotlin {
    compilerOptions {
        // expect/actual classes are stable enough for use — suppress the Beta warning.
        freeCompilerArgs.add("-Xexpect-actual-classes")
    }
    androidTarget {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }
    val xcf = XCFramework("ChatSdk")
    listOf(iosArm64(), iosX64(), iosSimulatorArm64()).forEach { target ->
        target.binaries.framework {
            baseName = "ChatSdk"
            xcf.add(this)
        }
    }

    sourceSets {
        commonMain.dependencies {
            implementation(libs.ktor.client.core)
            implementation(libs.ktor.client.content.negotiation)
            implementation(libs.ktor.client.websockets)
            implementation(libs.ktor.serialization.kotlinx.json)
            implementation(libs.ktor.client.logging)
            implementation(libs.kotlinx.serialization.json)
            implementation(libs.kotlinx.datetime)
            implementation(libs.sqldelight.coroutines.extensions)
        }

        androidMain.dependencies {
            // Proto-generated sources and lite runtime are Android/JVM-only.
            implementation(libs.protobuf.kotlin.lite)

            // OkHttp engine — required for WebSocket support (ktor-client-android uses
            // HttpURLConnection which does not implement WebSocketCapability).
            implementation(libs.ktor.client.okhttp)
            implementation(libs.sqldelight.android.driver)

            // Coroutines with Android dispatcher
            implementation(libs.coroutines.android)

            // Compose — BOM is applied via top-level dependencies block (platform() not
            // available in KMP source set blocks). Individual artifacts listed here.
            implementation(libs.compose.ui)
            implementation(libs.compose.ui.tooling.preview)
            implementation(libs.compose.material3)
            implementation(libs.compose.foundation)
            implementation(libs.compose.material.icons.core)
            implementation(libs.compose.material.icons.extended)
            implementation(libs.activity.compose)

            // Lifecycle / ViewModel
            implementation(libs.lifecycle.viewmodel.ktx)
            implementation(libs.lifecycle.viewmodel.compose)
            implementation(libs.lifecycle.runtime.ktx)

            // Coil — async image loading (coil-network-okhttp adds the network fetcher required
            // for HTTP/HTTPS URLs; coil-compose alone only handles local files and drawables).
            implementation(libs.coil.compose)
            implementation(libs.coil.network.okhttp)
        }

        iosMain.dependencies {
            implementation(libs.ktor.client.darwin)
            implementation(libs.sqldelight.native.driver)
        }

        commonTest.dependencies {
            implementation(libs.kotlin.test)
            implementation(libs.coroutines.test)
            implementation(libs.ktor.client.mock)
        }

        val androidUnitTest by getting {
            dependencies {
                implementation(libs.junit)
                // CIO engine required by StagingIntegrationTest (JVM-only, not available in commonTest)
                implementation(libs.ktor.client.cio)
                // JVM SQLite driver — only runs on JVM test host (Android unit tests).
                // Moved from commonTest because sqldelight-jdbc-driver has no Kotlin/Native support.
                implementation(libs.sqldelight.jdbc.driver)
            }
        }
    }

    // Proto-generated Kotlin/Java classes live in proto/kotlin/ (committed to the repo).
    // They are JVM/Android-only (protobuf-kotlin-lite has no Kotlin/Native support).
    sourceSets.getByName("androidMain") {
        kotlin.srcDir("../../proto/kotlin")
        // Exclude all Kotlin DSL wrappers that reference Java types not present in the
        // committed SdkMessageOuterClass.java. These wrappers were generated from the proto
        // source but the corresponding Java outer class was not regenerated at the same time,
        // leaving unresolved type references that produce "Overload resolution ambiguity"
        // on timestampOrNull across all other proto files. The SDK does not use these
        // wrappers directly; the raw Java accessors in SdkMessageOuterClass are sufficient.
        kotlin.filter.exclude(
            "**/AttachmentMessageResponseKt.kt",
            "**/CustomActionRequestKt.kt",
            "**/CustomActionResponseKt.kt",
            "**/ImageMessageResponseKt.kt",
            "**/MessageReceiptResponseKt.kt",
            "**/MessageStatusRequestKt.kt",
            "**/MessageStatusResponseKt.kt",
            "**/RegisterCommandsRequestKt.kt",
            "**/TextMessageResponseKt.kt",
            "**/VideoMessageResponseKt.kt",
            "**/VoiceNoteMessageResponseKt.kt",
        )
    }
}

android {
    namespace = "com.yalo.chat.sdk"
    compileSdk = 35

    defaultConfig {
        minSdk = 21
        consumerProguardFiles("consumer-proguard-rules.pro")
        val useFakeRepo = localProps.getProperty("yalo.useFakeRepository", "false")
            .trim().toBooleanStrictOrNull() ?: false
        buildConfigField("Boolean", "USE_FAKE_REPOSITORY", "$useFakeRepo")
        buildConfigField("String",  "TRANSPORT",           "\"${localProps.getProperty("yalo.transport", "WEBSOCKET").trim().uppercase()}\"")
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
        disable += "NullSafeMutableLiveData"
        disable += "RememberInComposition"
        disable += "FrequentlyChangingValue"
        disable += "AutoboxingStateCreation"
    }
}

sqldelight {
    databases {
        create("ChatDatabase") {
            packageName.set("com.yalo.chat.sdk.database")
            version = 2
        }
    }
    // Required for iOS NativeSqliteDriver — links against the system SQLite library.
    // Without this, iOS apps linking against the XCFramework get "library not found for -lsqlite3".
    linkSqlite.set(true)
}

// Restrict Compose compiler to Android only — iOS targets don't use Compose.
composeCompiler {
    targetKotlinPlatforms = setOf(KotlinPlatformType.androidJvm)
}

// Compose BOM must live here because platform() and debug configurations are not
// available inside KMP source set dependency blocks.
dependencies {
    add("androidMainImplementation", platform(libs.compose.bom))
    debugImplementation(libs.compose.ui.tooling)
}
