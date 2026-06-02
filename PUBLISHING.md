# Publishing Guide

This document explains how to cut a release for the Android SDK (Maven Central) and the iOS SDK (Swift Package Manager via GitHub Releases).

---

## Android SDK — Maven Central

**Consumer dependency:**
```kotlin
implementation("com.yalo.chat:yalo-chat-android-sdk:0.0.1")
```

### How a release works

Releasing is fully automated. Pushing a tag of the form `android-sdk/v<semver>` triggers the [`release-android.yml`](.github/workflows/release-android.yml) workflow, which:

1. Runs `:sdk:testDebugUnitTest`
2. Publishes the AAR to Maven Central via `com.vanniktech.maven.publish`
3. Creates a GitHub Release

### Required GitHub Actions secrets

| Secret | Description |
|---|---|
| `MAVEN_CENTRAL_USERNAME` | Portal token username from [central.sonatype.com](https://central.sonatype.com) |
| `MAVEN_CENTRAL_PASSWORD` | Portal token password |
| `SIGNING_KEY` | In-memory GPG private key (armored, `gpg --armor --export-secret-keys <KEY_ID>`) |
| `SIGNING_KEY_ID` | Last 8 characters of the GPG key fingerprint |
| `SIGNING_KEY_PASSWORD` | GPG key passphrase |

### Cutting a release

```bash
git tag android-sdk/v0.0.1
git push origin android-sdk/v0.0.1
```

### Versioning

The version is derived from the tag: `android-sdk/v0.0.2` → `0.0.2`. The default in `gradle.properties` (`VERSION_NAME=0.0.1`) is used for local builds and overridden by CI via `ORG_GRADLE_PROJECT_VERSION_NAME`.

---

## iOS SDK — Swift Package Manager

**Consumer integration:**

In Xcode: **File → Add Package Dependencies…** → enter the GitHub repo URL.

Or in `Package.swift`:
```swift
.package(url: "https://github.com/yalochat/chat-sdk", from: "0.0.1"),
// then in your target:
.product(name: "YaloChatIosSDK", package: "chat-sdk"),
```

The package manifest lives at `ios-sdk/Package.swift` — consumers point Xcode at the GitHub repo URL and Xcode discovers it automatically.

### How a release works

Pushing a tag of the form `ios-sdk/v<semver>` triggers the [`release-ios.yml`](.github/workflows/release-ios.yml) workflow, which:

1. Builds the XCFramework via `./gradlew :sdk:assembleChatSdkReleaseXCFramework`
2. Zips the output and computes its checksum
3. Updates `Package.swift` in `main` with the release URL and checksum
4. Force-moves the tag to the updated commit
5. Creates a GitHub Release and uploads `ChatSdk.xcframework.zip`

### Cutting a release

1. Build the XCFramework locally and compute the checksum:
   ```bash
   cd android-sdk
   ./gradlew :sdk:assembleChatSdkReleaseXCFramework
   cd sdk/build/XCFrameworks/release
   zip -r ChatSdk.xcframework.zip ChatSdk.xcframework
   swift package compute-checksum ChatSdk.xcframework.zip
   ```

2. Update `ios-sdk/Package.swift` with the release URL and computed checksum, then commit and push to `main`.

3. Push the tag — CI builds the XCFramework, uploads it to GitHub Releases, and creates the release:
   ```bash
   git tag ios-sdk/v0.0.1
   git push origin ios-sdk/v0.0.1
   ```

### Local XCFramework build (for development)

```bash
cd android-sdk
./gradlew :sdk:assembleChatSdkReleaseXCFramework
# Output: android-sdk/sdk/build/XCFrameworks/release/ChatSdk.xcframework
```

To use locally in an Xcode project, drag the `.xcframework` folder into the **Frameworks, Libraries, and Embedded Content** section of your target.
