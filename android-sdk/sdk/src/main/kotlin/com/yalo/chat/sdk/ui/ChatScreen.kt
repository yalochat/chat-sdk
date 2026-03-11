// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
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
    val factory = YaloChat.getViewModelFactory()
    val viewModel: MessagesViewModel = viewModel(factory = factory)
    val imageViewModel: ImageViewModel = viewModel(factory = factory)

    val state by viewModel.state.collectAsState()
    val imageState by imageViewModel.state.collectAsState()

    var showPickerSheet by remember { mutableStateOf(false) }

    // Gallery launcher — PickVisualMedia requires no READ_MEDIA_IMAGES permission on API 33+.
    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia(),
    ) { uri: Uri? ->
        if (uri != null) {
            imageViewModel.handleEvent(ImageEvent.GalleryImageReceived(uri.toString()))
        }
    }

    // Camera launcher — saves image to the FileProvider URI provided by ImageViewModel.
    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicture(),
    ) { success: Boolean ->
        if (success) imageViewModel.handleEvent(ImageEvent.CameraImageCaptured)
    }

    // Collect ImageViewModel side effects and fire the appropriate launchers.
    LaunchedEffect(imageViewModel) {
        imageViewModel.sideEffects.collect { effect ->
            when (effect) {
                is ImageSideEffect.LaunchGallery ->
                    galleryLauncher.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
                is ImageSideEffect.LaunchCamera ->
                    cameraLauncher.launch(Uri.parse(effect.uriString))
            }
        }
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
        ) { paddingValues ->
            MessageList(
                messages = state.messages,
                modifier = Modifier.padding(paddingValues),
            )
        }

        // Image preview overlay — shown above the scaffold when a picked image is ready.
        if (imageState.isPreviewVisible) {
            imageState.pickedImage?.path?.let { path ->
                ImagePreview(
                    imagePath = path,
                    onSend = {
                        viewModel.handleEvent(MessagesEvent.SendImageMessage(imageState.pickedImage!!))
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
