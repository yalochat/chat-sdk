plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.maven.publish)
    jacoco
}

kotlin {
    explicitApi()
}

android {
    namespace = "ai.yalo.chat.sdk"
    compileSdk {
        version = release(37)
    }

    defaultConfig {
        minSdk = 24

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
    buildTypes {
        getByName("debug") {
            enableUnitTestCoverage = true
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    buildFeatures {
        compose = true
    }
    testOptions {
        unitTests {
            isIncludeAndroidResources = true
        }
    }
}

// The release workflow overrides this with ORG_GRADLE_PROJECT_VERSION_NAME, taken
// from the android-sdk/vX.Y.Z tag that triggered it.
val sdkVersion: String = providers.gradleProperty("VERSION_NAME").getOrElse("0.0.1-SNAPSHOT")

mavenPublishing {
    publishToMavenCentral()
    coordinates("ai.yalo.chat", "chat-android-sdk", sdkVersion)

    // Signing keys only exist on the release workflow, so a local
    // publishToMavenLocal still works for trying the artifact out.
    if (providers.gradleProperty("signingInMemoryKey").isPresent) {
        signAllPublications()
    }

    pom {
        name.set("Yalo Chat Android SDK")
        description.set("Android SDK for the Yalo chat product.")
        url.set("https://github.com/yalochat/chat-sdk")
        inceptionYear.set("2026")
        licenses {
            license {
                name.set("The Apache License, Version 2.0")
                url.set("https://www.apache.org/licenses/LICENSE-2.0.txt")
            }
        }
        developers {
            developer {
                id.set("yalochat")
                name.set("Yalochat, Inc.")
                url.set("https://github.com/yalochat")
            }
        }
        scm {
            url.set("https://github.com/yalochat/chat-sdk")
            connection.set("scm:git:git://github.com/yalochat/chat-sdk.git")
            developerConnection.set("scm:git:ssh://git@github.com/yalochat/chat-sdk.git")
        }
    }
}

// Robolectric loads classes through its own class loader, which hides them from
// JaCoCo unless classes without a source location are included as well.
tasks.withType<Test>().configureEach {
    extensions.configure(JacocoTaskExtension::class) {
        isIncludeNoLocationClasses = true
        excludes = listOf("jdk.internal.*")
    }
}

dependencies {
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.core.ktx)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.animation)
    implementation(libs.kotlinx.coroutines.android)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.lifecycle.viewmodel.savedstate)
    implementation(libs.androidx.compose.ui)
    api(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.material)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.kotlinx.coroutines.test)
    testImplementation(platform(libs.androidx.compose.bom))
    testImplementation(libs.androidx.compose.ui.test.junit4)
    debugImplementation(libs.androidx.compose.ui.test.manifest)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(libs.androidx.junit)
}
