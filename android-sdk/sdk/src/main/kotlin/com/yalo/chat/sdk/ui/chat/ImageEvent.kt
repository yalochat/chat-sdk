// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

// Port of flutter-sdk/lib/src/ui/chat/view_models/image/image_event.dart
// URIs are passed as Strings to keep this class free of android.net.Uri — safe for KMP / JVM tests.
sealed class ImageEvent {
    /** User tapped the gallery option — triggers gallery picker launch. */
    data object PickFromGallery : ImageEvent()

    /** User tapped the camera option — triggers camera capture launch. */
    data object PickFromCamera : ImageEvent()

    /** Gallery picker returned a content URI (as string). */
    data class GalleryImageReceived(val uriString: String) : ImageEvent()

    /** Camera capture completed successfully (image stored at pendingCameraFile). */
    data object CameraImageCaptured : ImageEvent()

    /** User tapped Cancel in the image preview. */
    data object CancelPick : ImageEvent()

    /** Hide the image preview (after send or explicit dismiss). */
    data object HidePreview : ImageEvent()

    /** Re-show a hidden image preview. */
    data object ShowPreview : ImageEvent()
}
