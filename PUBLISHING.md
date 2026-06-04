# Publishing Guide

This document explains how to cut a release for the Android SDK (Maven Central) and the iOS SDK (Swift Package Manager via GitHub Releases).

---

## Android SDK — Maven Central

**Consumer dependency:**
```kotlin
implementation("com.yalo.chat:yalo-chat-android-sdk:0.0.1")
```

### How a release works

Triggered manually via **GitHub Actions → Release Android SDK → Run workflow**. The [`release-android.yml`](.github/workflows/release-android.yml) workflow:

1. Runs `:sdk:testDebugUnitTest`
2. Publishes the AAR to Maven Central via `com.vanniktech.maven.publish`
3. Creates the `android-sdk/v<semver>` tag and a GitHub Release

### Required GitHub Actions secrets

| Secret | Description |
|---|---|
| `MAVEN_CENTRAL_USERNAME` | Portal token username from [central.sonatype.com](https://central.sonatype.com) |
| `MAVEN_CENTRAL_PASSWORD` | Portal token password |
| `SIGNING_KEY` | In-memory GPG private key (armored, `gpg --armor --export-secret-keys <KEY_ID>`) |
| `SIGNING_KEY_ID` | Last 8 characters of the GPG key fingerprint |
| `SIGNING_KEY_PASSWORD` | GPG key passphrase |

### Cutting a release

Go to **GitHub → Actions → Release Android SDK → Run workflow**, enter the version (e.g. `0.0.1`), and click **Run workflow**. CI runs tests, publishes to Maven Central, creates the `android-sdk/v0.0.1` tag, and creates a GitHub Release.

### Versioning

The version comes from the workflow input. The default in `gradle.properties` (`VERSION_NAME=0.0.1`) is used for local builds and overridden by CI via `ORG_GRADLE_PROJECT_VERSION_NAME`.

---

## iOS SDK — Swift Package Manager

**Consumer integration:**

In Xcode: **File → Add Package Dependencies…** → enter `https://github.com/yalochat/chat-sdk`.

Or in `Package.swift`:
```swift
.package(url: "https://github.com/yalochat/chat-sdk", from: "0.0.1"),
// then in your target:
.product(name: "YaloChatIosSDK", package: "chat-sdk"),
```

The package manifest lives at the repo root (`Package.swift`). SPM discovers it automatically when consumers add the repo URL.

### How a release works

Triggered manually via **GitHub Actions → Release iOS SDK → Run workflow** (not by a tag push). The [`release-ios.yml`](.github/workflows/release-ios.yml) workflow:

1. Builds the XCFramework via `./gradlew :sdk:assembleChatSdkReleaseXCFramework`
2. Zips the output and computes its checksum
3. Commits the updated `Package.swift` (with real URL + checksum) to `main` via the GitHub API
4. Creates a `v<semver>` tag on that commit so the tagged commit already contains the correct checksum
5. Creates a GitHub Release and uploads `ChatSdk.xcframework.zip`

### Cutting a release

Go to **GitHub → Actions → Release iOS SDK → Run workflow**, enter the version (e.g. `0.0.1`), and click **Run workflow**. Everything else is automated.

### Why workflow_dispatch instead of a tag push?

SPM resolves `Package.swift` from the tagged commit. If the tag is pushed before the checksum is known, the tagged commit contains a stale/placeholder checksum and SPM dependency resolution fails for consumers. The `workflow_dispatch` trigger lets CI compute the real checksum, commit it, and then create the tag — guaranteeing the tagged commit is always valid.

### Local XCFramework build (for development)

```bash
cd android-sdk
./gradlew :sdk:assembleChatSdkReleaseXCFramework
# Output: android-sdk/sdk/build/XCFrameworks/release/ChatSdk.xcframework
```

To use locally in an Xcode project, drag the `.xcframework` folder into the **Frameworks, Libraries, and Embedded Content** section of your target.
