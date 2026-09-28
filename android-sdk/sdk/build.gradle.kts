import java.util.Properties

plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.maven.publish)
    jacoco
}

val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) {
        file.inputStream().use { stream -> load(stream) }
    }
}

val apiBaseUrl: String = providers.environmentVariable("YALO_API_BASE_URL").orNull
    ?: providers.gradleProperty("yaloApiBaseUrl").orNull
    ?: localProperties.getProperty("yaloApiBaseUrl")
    ?: error(
        """
        The API base URL is not set. It is the host and path with no scheme,
        the same value the web SDK takes in VITE_YALO_API_BASE_URL. Pick one:
          local.properties  yaloApiBaseUrl=example.yalochat.com/public-api-gateway
          environment       YALO_API_BASE_URL=example.yalochat.com/public-api-gateway
          command line      ./gradlew -PyaloApiBaseUrl=example.yalochat.com/public-api-gateway
        """.trimIndent(),
    )

val protoSources = "../../proto/kotlin"
val generatedProtoClasses = "ai/yalo/chat/sdk/internal/proto/**"

kotlin {
    explicitApi()
}

android {
    namespace = "ai.yalo.chat.sdk"
    compileSdk {
        version = release(37)
    }

    sourceSets {
        getByName("main") {
            java.directories.add(protoSources)
            kotlin.directories.add(protoSources)
        }
    }

    defaultConfig {
        minSdk = 24

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        buildConfigField("String", "YALO_API_BASE_URL", "\"$apiBaseUrl\"")

        // Shipped to whoever uses the SDK, because the rules protect the
        // generated proto in their build, not in this one.
        consumerProguardFiles("consumer-rules.pro")
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
        buildConfig = true
    }
    testOptions {
        unitTests {
            isIncludeAndroidResources = true
        }
    }
}

val sdkVersion: String = providers.gradleProperty("VERSION_NAME").getOrElse("0.0.1-SNAPSHOT")

mavenPublishing {
    publishToMavenCentral()
    coordinates("ai.yalo.chat", "chat-android-sdk", sdkVersion)

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

tasks.withType<Test>().configureEach {
    extensions.configure(JacocoTaskExtension::class) {
        isIncludeNoLocationClasses = true
        excludes = listOf("jdk.internal.*")
    }
}

tasks.register<JacocoReport>("sdkCoverageReport") {
    group = "verification"
    description = "Unit test coverage for the SDK's own code, without the generated proto."
    dependsOn("testDebugUnitTest")

    executionData.setFrom(
        layout.buildDirectory.file("outputs/unit_test_code_coverage/debugUnitTest/testDebugUnitTest.exec"),
    )
    sourceDirectories.setFrom(files("src/main/java"))
    classDirectories.setFrom(
        files(
            tasks.named("compileDebugJavaWithJavac").map { task ->
                (task as JavaCompile).destinationDirectory
            },
            tasks.named("compileDebugKotlin").map { task ->
                task.outputs.files.filter { it.name == "classes" }
            },
        ).asFileTree.matching { exclude(generatedProtoClasses) },
    )

    reports {
        xml.required.set(true)
        html.required.set(true)
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
    implementation(libs.okhttp)
    implementation(libs.okio)
    implementation(libs.protobuf.java)
    implementation(libs.protobuf.kotlin)
    implementation(libs.protobuf.java.util)
    implementation(libs.androidx.datastore.preferences)
    implementation(libs.jetbrains.markdown)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.lifecycle.viewmodel.savedstate)
    implementation(libs.androidx.compose.ui)
    api(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.material)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.kotlinx.coroutines.test)
    testImplementation(libs.okhttp.mockwebserver)
    testImplementation(platform(libs.androidx.compose.bom))
    testImplementation(libs.androidx.compose.ui.test.junit4)
    debugImplementation(libs.androidx.compose.ui.test.manifest)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(libs.androidx.junit)
}
