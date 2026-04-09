import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.plugin.KotlinPlatformType
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    alias(libs.plugins.kotlin.multiplatform)
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.compose.compiler)
    alias(libs.plugins.ksp)
    alias(libs.plugins.sqldelight)
}

// Read the API base URL from local.properties (gitignored).
// CI pipelines inject YALO_API_BASE_URL as an environment variable instead.
val localProps = Properties().also { props ->
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { props.load(it) }
}
val yaloApiBaseUrl: String = (System.getenv("YALO_API_BASE_URL")
    ?: localProps.getProperty("yalo.apiBaseUrl", "")).also { url ->
    if (url.isEmpty()) logger.warn(
        "WARNING: YALO_API_BASE_URL is not set. " +
        "Add yalo.apiBaseUrl to local.properties or set the YALO_API_BASE_URL env variable. " +
        "The SDK will fail at runtime when connecting to the backend."
    )
}

kotlin {
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
            implementation(libs.ktor.serialization.kotlinx.json)
            implementation(libs.ktor.client.logging)
            implementation(libs.kotlinx.serialization.json)
            implementation(libs.kotlinx.datetime)
            implementation(libs.sqldelight.coroutines.extensions)
        }

        androidMain.dependencies {
            // Proto-generated sources and lite runtime are Android/JVM-only.
            implementation(libs.protobuf.kotlin.lite)

            // Android Ktor engine and SQLite driver
            implementation(libs.ktor.client.android)
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

            // Coil — async image loading
            implementation(libs.coil.compose)
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
    }
}

android {
    namespace = "com.yalo.chat.sdk"
    compileSdk = 35

    defaultConfig {
        minSdk = 21
        consumerProguardFiles("consumer-proguard-rules.pro")
        val escapedUrl = yaloApiBaseUrl.trim().replace("\\", "\\\\").replace("\"", "\\\"")
        buildConfigField("String", "YALO_API_BASE_URL", "\"$escapedUrl\"")
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
