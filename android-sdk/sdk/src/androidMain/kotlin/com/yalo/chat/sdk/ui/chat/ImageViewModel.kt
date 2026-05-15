// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yalo.chat.sdk.common.Result
import com.yalo.chat.sdk.domain.model.ImageData
import com.yalo.chat.sdk.domain.repository.ImagePickerRepository
import java.io.File
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

// Handles image pick flow: gallery / camera → preview → send (or cancel).
// Launching the system picker is done via side effects so the ViewModel stays
// free of Android Activity/Fragment dependencies (testable on JVM).
// URIs are Strings throughout so this class is free of android.net.Uri (KMP / JVM safe).
internal class ImageViewModel(
    private val imageRepo: ImagePickerRepository,
) : ViewModel() {

    private val _state = MutableStateFlow(ImageState())
    val state: StateFlow<ImageState> = _state.asStateFlow()

    // Buffered so effects are not dropped if the UI is not yet collecting.
    private val _sideEffects = Channel<ImageSideEffect>(Channel.BUFFERED)
    val sideEffects = _sideEffects.receiveAsFlow()

    // Holds the backing File for the current camera capture.
    // Kept as a plain var (not in ImageState) because it is an Android-specific
    // implementation detail that should never be observed by the UI.
    private var pendingCameraFile: File? = null

    fun handleEvent(event: ImageEvent) {
        when (event) {
            is ImageEvent.PickFromGallery -> viewModelScope.launch {
                _sideEffects.send(ImageSideEffect.LaunchGallery)
            }
            is ImageEvent.PickFromCamera -> viewModelScope.launch {
                try {
                    val capture = imageRepo.createCameraCapture()
                    pendingCameraFile = capture.file
                    _sideEffects.send(ImageSideEffect.LaunchCamera(capture.uriString))
                } catch (e: Exception) {
                    // Camera setup failed (e.g. FileProvider misconfigured, no cache space).
                    _state.update { it.copy(errorMessage = "Could not start camera. Please try again.") }
                }
            }
            is ImageEvent.GalleryImageReceived -> viewModelScope.launch {
                when (val result = imageRepo.saveGalleryUri(event.uriString)) {
                    is Result.Ok -> showPreview(result.result)
                    is Result.Error -> _state.update { it.copy(errorMessage = "Could not load image. Please try again.") }
                }
            }
            is ImageEvent.CameraImageCaptured -> {
                val file = pendingCameraFile ?: return
                pendingCameraFile = null
                showPreview(ImageData(path = file.absolutePath))
            }
            is ImageEvent.CancelPick -> {
                // Delete the committed picked image file (gallery dest or camera file post-capture).
                _state.value.pickedImage?.path?.let { File(it).delete() }
                // Delete the pending camera file if the OS camera was cancelled before capture
                // (TakePicture returned false) or permission was denied.
                pendingCameraFile?.delete()
                pendingCameraFile = null
                _state.update { ImageState() }
            }
            is ImageEvent.HidePreview -> _state.update { it.copy(isPreviewVisible = false) }
            is ImageEvent.ShowPreview -> {
                // TODO: dispatch from ChatScreen when restoring preview after scroll — future milestone.
                if (_state.value.pickedImage != null) {
                    _state.update { it.copy(isPreviewVisible = true) }
                }
            }
            is ImageEvent.DismissError -> _state.update { it.copy(errorMessage = null) }
        }
    }

    private fun showPreview(image: ImageData) {
        _state.update { ImageState(pickedImage = image, isPreviewVisible = true) }
    }
}
