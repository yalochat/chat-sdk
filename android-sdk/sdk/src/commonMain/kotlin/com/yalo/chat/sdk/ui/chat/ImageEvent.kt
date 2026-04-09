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

    /** User cancelled the pick (preview Cancel button, OS camera back, or permission denied). */
    data object CancelPick : ImageEvent()

    /** Hide the image preview (after send or explicit dismiss). */
    data object HidePreview : ImageEvent()

    /** Re-show a hidden image preview (e.g. after scroll past unsent image).
     * TODO: dispatch from ChatScreen when restoring preview after scroll — future milestone. */
    data object ShowPreview : ImageEvent()

    /** Clears the error message after the Snackbar has been shown. */
    data object DismissError : ImageEvent()
}
