// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui

import android.Manifest
import android.content.pm.PackageManager
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import androidx.lifecycle.viewmodel.compose.viewModel
import com.yalo.chat.sdk.YaloChat
import com.yalo.chat.sdk.ui.chat.ChatAppBar
import com.yalo.chat.sdk.ui.chat.ChatInput
import com.yalo.chat.sdk.ui.chat.ImageEvent
import com.yalo.chat.sdk.ui.chat.ImagePreview
import com.yalo.chat.sdk.ui.chat.ImageSideEffect
import com.yalo.chat.sdk.ui.chat.ImageViewModel
import com.yalo.chat.sdk.ui.chat.MessageList
import com.yalo.chat.sdk.ui.chat.MessagesEvent
import com.yalo.chat.sdk.ui.chat.MessagesViewModel

// Port of flutter-sdk Chat widget.
// Phase 2 M3: adds ImageViewModel, gallery/camera launchers, and ImagePreview overlay.
// android.net.Uri is used only at the Activity Result boundary; URIs are Strings inside ViewModels.
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatScreen() {
    val context = LocalContext.current
    val factory = YaloChat.getViewModelFactory()
    val viewModel: MessagesViewModel = viewModel(factory = factory)
    val imageViewModel: ImageViewModel = viewModel(factory = factory)

    val state by viewModel.state.collectAsState()
    val imageState by imageViewModel.state.collectAsState()

    var showPickerSheet by remember { mutableStateOf(false) }
    val snackbarHostState = remember { SnackbarHostState() }

    // Holds the camera URI while waiting for the permission grant result.
    var pendingCameraUriString by remember { mutableStateOf<String?>(null) }

    // Gallery launcher — PickVisualMedia requires no READ_MEDIA_IMAGES permission on API 33+.
    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia(),
    ) { uri: Uri? ->
        if (uri != null) {
            imageViewModel.handleEvent(ImageEvent.GalleryImageReceived(uri.toString()))
        }
    }

    // Camera launcher — saves image to the FileProvider URI provided by ImageViewModel.
    // Dispatches CancelPick on failure so the ViewModel can delete the pending temp file.
    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicture(),
    ) { success: Boolean ->
        if (success) {
            imageViewModel.handleEvent(ImageEvent.CameraImageCaptured)
        } else {
            imageViewModel.handleEvent(ImageEvent.CancelPick)
        }
    }

    // Permission launcher — requests CAMERA at runtime (dangerous permission, API 23+).
    // On grant: fires the camera launcher with the URI held in pendingCameraUriString.
    // On denial: dispatches CancelPick to clean up the pending temp file created by PickFromCamera.
    val cameraPermissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission(),
    ) { granted: Boolean ->
        if (granted) {
            pendingCameraUriString?.let { uriString ->
                cameraLauncher.launch(Uri.parse(uriString))
            }
        } else {
            imageViewModel.handleEvent(ImageEvent.CancelPick)
        }
        pendingCameraUriString = null
    }

    // Collect ImageViewModel side effects and fire the appropriate launchers.
    LaunchedEffect(imageViewModel) {
        imageViewModel.sideEffects.collect { effect ->
            when (effect) {
                is ImageSideEffect.LaunchGallery ->
                    galleryLauncher.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
                is ImageSideEffect.LaunchCamera -> {
                    val hasCameraPermission = ContextCompat.checkSelfPermission(
                        context, Manifest.permission.CAMERA
                    ) == PackageManager.PERMISSION_GRANTED
                    if (hasCameraPermission) {
                        cameraLauncher.launch(Uri.parse(effect.uriString))
                    } else {
                        // Store the URI and request the permission; launcher fires on grant.
                        pendingCameraUriString = effect.uriString
                        cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
                    }
                }
            }
        }
    }

    // Show a Snackbar whenever ImageViewModel emits an error (e.g. failed gallery save or
    // camera setup failure). Dismisses automatically and clears the error from state.
    LaunchedEffect(imageState.errorMessage) {
        val message = imageState.errorMessage ?: return@LaunchedEffect
        snackbarHostState.showSnackbar(message)
        imageViewModel.handleEvent(ImageEvent.DismissError)
    }

    LaunchedEffect(Unit) {
        viewModel.handleEvent(MessagesEvent.LoadMessages)
        viewModel.handleEvent(MessagesEvent.SubscribeToMessages)
    }

    Box {
        Scaffold(
            topBar = {
                ChatAppBar(title = YaloChat.config.name)
            },
            bottomBar = {
                ChatInput(
                    userMessage = state.userMessage,
                    onUserMessageChange = { viewModel.handleEvent(MessagesEvent.UpdateUserMessage(it)) },
                    onSendMessage = { viewModel.handleEvent(MessagesEvent.SendTextMessage(state.userMessage)) },
                    onAttachmentClick = { showPickerSheet = true },
                )
            },
            snackbarHost = { SnackbarHost(snackbarHostState) },
        ) { paddingValues ->
            MessageList(
                messages = state.messages,
                modifier = Modifier.padding(paddingValues),
            )
        }

        // Image preview overlay — shown above the scaffold when a picked image is ready.
        // pickedImage is captured as a local val so the lambda captures a stable reference
        // rather than relying on a non-null assertion against live state.
        if (imageState.isPreviewVisible) {
            val pickedImage = imageState.pickedImage
            if (pickedImage?.path != null) {
                ImagePreview(
                    imagePath = pickedImage.path,
                    onSend = {
                        viewModel.handleEvent(MessagesEvent.SendImageMessage(pickedImage))
                        imageViewModel.handleEvent(ImageEvent.HidePreview)
                    },
                    onCancel = { imageViewModel.handleEvent(ImageEvent.CancelPick) },
                )
            }
        }
    }

    // Bottom sheet for picker source selection (gallery vs. camera).
    if (showPickerSheet) {
        ModalBottomSheet(
            onDismissRequest = { showPickerSheet = false },
            sheetState = rememberModalBottomSheetState(),
        ) {
            TextButton(
                onClick = {
                    showPickerSheet = false
                    imageViewModel.handleEvent(ImageEvent.PickFromGallery)
                },
            ) {
                Text("Choose from Gallery")
            }
            TextButton(
                onClick = {
                    showPickerSheet = false
                    imageViewModel.handleEvent(ImageEvent.PickFromCamera)
                },
            ) {
                Text("Take Photo")
            }
        }
    }
}
