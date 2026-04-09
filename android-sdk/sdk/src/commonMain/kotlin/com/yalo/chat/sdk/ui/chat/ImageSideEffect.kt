// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

// Side effects emitted by ImageViewModel for the UI to act on.
// The UI registers ActivityResult launchers and fires them when these effects arrive.
// URIs are Strings to keep this class free of android.net.Uri — safe for KMP / JVM tests.
internal sealed class ImageSideEffect {
    /** Launch the system gallery picker (PickVisualMedia). */
    data object LaunchGallery : ImageSideEffect()

    /** Launch the camera capture with the pre-created FileProvider URI (as string). */
    data class LaunchCamera(val uriString: String) : ImageSideEffect()
}
