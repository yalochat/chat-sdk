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
import androidx.compose.runtime.DisposableEffect
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
import com.yalo.chat.sdk.ui.chat.AudioEvent
import com.yalo.chat.sdk.ui.chat.AudioStatus
import com.yalo.chat.sdk.ui.chat.AudioViewModel
import com.yalo.chat.sdk.ui.chat.ChatAppBar
import com.yalo.chat.sdk.ui.chat.ChatInput
import com.yalo.chat.sdk.ui.chat.ImageEvent
import com.yalo.chat.sdk.ui.chat.ImagePreview
import com.yalo.chat.sdk.ui.chat.ImageSideEffect
import com.yalo.chat.sdk.ui.chat.ImageViewModel
import com.yalo.chat.sdk.ui.chat.MessageList
import com.yalo.chat.sdk.ui.chat.MessagesEvent
import com.yalo.chat.sdk.ui.chat.MessagesViewModel
import com.yalo.chat.sdk.ui.chat.WaveformRecorder
import com.yalo.chat.sdk.ui.chat.isRecording

// android.net.Uri is used only at the Activity Result boundary; URIs are Strings inside ViewModels.
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatScreen(onBack: (() -> Unit)? = null) {
    val context = LocalContext.current
    val factory = YaloChat.getViewModelFactory()
    val viewModel: MessagesViewModel = viewModel(factory = factory)
    val imageViewModel: ImageViewModel = viewModel(factory = factory)
    val audioViewModel: AudioViewModel = viewModel(factory = factory)

    val state by viewModel.state.collectAsState()
    val imageState by imageViewModel.state.collectAsState()
    val audioState by audioViewModel.state.collectAsState()

    var showPickerSheet by remember { mutableStateOf(false) }
    val snackbarHostState = remember { SnackbarHostState() }

    // Holds the camera URI while waiting for the permission grant result.
    var pendingCameraUriString by remember { mutableStateOf<String?>(null) }

    // ── Image launchers ───────────────────────────────────────────────────────


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

    // Permission launcher for CAMERA — requests at runtime (dangerous permission, API 23+).
    // On grant: fires the camera launcher with the URI held in pendingCameraUriString.
    // On denial: dispatches CancelPick to clean up the pending temp file.
    val cameraPermissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission(),
    ) { granted: Boolean ->
        if (granted) {
            pendingCameraUriString?.let {
                try {
                    cameraLauncher.launch(Uri.parse(it))
                } catch (_: SecurityException) {
                    // Permission revoked between grant callback and intent launch (TOCTOU).
                    imageViewModel.handleEvent(ImageEvent.CancelPick)
                }
            }
        } else {
            imageViewModel.handleEvent(ImageEvent.CancelPick)
        }
        pendingCameraUriString = null
    }

    // ── Audio permission launcher ─────────────────────────────────────────────

    // FDE-60: RECORD_AUDIO is a dangerous permission — request before starting recording.
    // On denial do nothing: no crash, no further action (graceful denial per DoD).
    val recordAudioPermissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission(),
    ) { granted: Boolean ->
        if (granted) {
            audioViewModel.handleEvent(AudioEvent.StartRecording)
        }
        // Denial is intentionally silent — a future milestone may add a rationale Snackbar.
    }

    // ── Side-effect collectors ────────────────────────────────────────────────


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
                        try {
                            cameraLauncher.launch(Uri.parse(effect.uriString))
                        } catch (_: SecurityException) {
                            // Permission revoked between checkSelfPermission and intent launch (TOCTOU).
                            imageViewModel.handleEvent(ImageEvent.CancelPick)
                        }
                    } else {
                        pendingCameraUriString = effect.uriString
                        cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
                    }
                }
            }
        }
    }

    // Show a Snackbar whenever ImageViewModel emits an error.
    LaunchedEffect(imageState.errorMessage) {
        val message = imageState.errorMessage ?: return@LaunchedEffect
        snackbarHostState.showSnackbar(message)
        imageViewModel.handleEvent(ImageEvent.DismissError)
    }

    // When recording stops successfully, insert the voice message.
    // Guards:
    //  1. audioStatus must be Initial — prevents sending on ErrorStoppingRecording.
    //  2. audioData.fileName must be non-empty — prevents sending after CancelRecording
    //     (cancelRecording() resets audioData to an empty AudioData before transitioning).
    val wasRecording = remember { mutableStateOf(false) }
    LaunchedEffect(audioState.isRecording) {
        if (wasRecording.value && !audioState.isRecording
            && audioState.audioStatus is AudioStatus.Initial
        ) {
            viewModel.handleEvent(MessagesEvent.SendVoiceMessage(audioState.audioData))
        }
        wasRecording.value = audioState.isRecording
    }

    LaunchedEffect(Unit) {
        viewModel.handleEvent(MessagesEvent.LoadMessages)
        viewModel.handleEvent(MessagesEvent.SubscribeToMessages)
        audioViewModel.handleEvent(AudioEvent.SubscribeToPlaybackCompletion)
    }

    // Stop sync and reset state when the screen leaves composition so background
    // polling does not continue while the host app shows other screens.
    // Keyed to viewModel so disposal always targets the current instance.
    DisposableEffect(viewModel) {
        onDispose { viewModel.handleEvent(MessagesEvent.ClearMessages) }
    }

    // ── Scaffold ──────────────────────────────────────────────────────────────


    Box {
        Scaffold(
            topBar = {
                ChatAppBar(title = YaloChat.config.name, onBack = onBack)
            },
            bottomBar = {
                if (audioState.isRecording) {
                    WaveformRecorder(
                        audioData = audioState.audioData,
                        onCancel = { audioViewModel.handleEvent(AudioEvent.CancelRecording) },
                        onSend = { audioViewModel.handleEvent(AudioEvent.StopRecording) },
                    )
                } else {
                    ChatInput(
                        userMessage = state.userMessage,
                        onUserMessageChange = { viewModel.handleEvent(MessagesEvent.UpdateUserMessage(it)) },
                        onSendMessage = { viewModel.handleEvent(MessagesEvent.SendTextMessage(state.userMessage)) },
                        onAttachmentClick = { showPickerSheet = true },
                        onMicClick = {
                                                val hasPermission = ContextCompat.checkSelfPermission(
                                context, Manifest.permission.RECORD_AUDIO
                            ) == PackageManager.PERMISSION_GRANTED
                            if (hasPermission) {
                                audioViewModel.handleEvent(AudioEvent.StartRecording)
                            } else {
                                recordAudioPermissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
                            }
                        },
                    )
                }
            },
            snackbarHost = { SnackbarHost(snackbarHostState) },
        ) { paddingValues ->
            MessageList(
                messages = state.messages,
                modifier = Modifier.padding(paddingValues),
                playingMessage = audioState.playingMessage,
                onPlayAudio = { audioViewModel.handleEvent(AudioEvent.Play(it)) },
                onStopAudio = { audioViewModel.handleEvent(AudioEvent.Stop) },
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
