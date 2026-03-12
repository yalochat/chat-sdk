// Copyright (c) Yalochat, Inc. All rights reserved.

package com.yalo.chat.sdk.ui.chat

import com.yalo.chat.sdk.data.repository.fake.FakeImagePickerRepository
import com.yalo.chat.sdk.domain.model.ImageData
import java.io.File
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class ImageViewModelTest {

    private val dispatcher = UnconfinedTestDispatcher()

    @BeforeTest
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterTest
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun viewModel(
        repo: FakeImagePickerRepository = FakeImagePickerRepository(),
    ) = ImageViewModel(repo)

    // ── Initial state ─────────────────────────────────────────────────────────

    @Test
    fun `initial state has no picked image, preview hidden, and no error`() {
        val vm = viewModel()
        assertNull(vm.state.value.pickedImage)
        assertFalse(vm.state.value.isPreviewVisible)
        assertNull(vm.state.value.errorMessage)
    }

    // ── PickFromGallery ───────────────────────────────────────────────────────

    @Test
    fun `PickFromGallery emits LaunchGallery side effect`() = runTest {
        val vm = viewModel()
        val effects = mutableListOf<ImageSideEffect>()
        val job = launch { vm.sideEffects.collect { effects.add(it) } }

        vm.handleEvent(ImageEvent.PickFromGallery)
        advanceUntilIdle()

        assertTrue(effects.any { it is ImageSideEffect.LaunchGallery })
        job.cancel()
    }

    // ── GalleryImageReceived ──────────────────────────────────────────────────

    @Test
    fun `GalleryImageReceived shows preview with saved image`() = runTest {
        val expectedImage = ImageData(path = "fake_gallery.jpg")
        val vm = viewModel(FakeImagePickerRepository(galleryImageData = expectedImage))

        vm.handleEvent(ImageEvent.GalleryImageReceived("content://fake/uri"))

        assertEquals(expectedImage, vm.state.value.pickedImage)
        assertTrue(vm.state.value.isPreviewVisible)
    }

    @Test
    fun `GalleryImageReceived sets errorMessage and leaves pickedImage null on save failure`() = runTest {
        val vm = viewModel(FakeImagePickerRepository(saveError = RuntimeException("disk full")))

        vm.handleEvent(ImageEvent.GalleryImageReceived("content://fake/uri"))

        assertNull(vm.state.value.pickedImage)
        assertFalse(vm.state.value.isPreviewVisible)
        assertNotNull(vm.state.value.errorMessage)
    }

    // ── PickFromCamera ────────────────────────────────────────────────────────

    @Test
    fun `PickFromCamera emits LaunchCamera side effect with URI from repo`() = runTest {
        val vm = viewModel()
        val effects = mutableListOf<ImageSideEffect>()
        val job = launch { vm.sideEffects.collect { effects.add(it) } }

        vm.handleEvent(ImageEvent.PickFromCamera)
        advanceUntilIdle()

        val cameraEffect = effects.filterIsInstance<ImageSideEffect.LaunchCamera>().firstOrNull()
        assertEquals("content://fake/camera", cameraEffect?.uriString)
        job.cancel()
    }

    @Test
    fun `PickFromCamera sets errorMessage when camera setup fails`() = runTest {
        val vm = viewModel(FakeImagePickerRepository(captureError = RuntimeException("FileProvider not configured")))

        vm.handleEvent(ImageEvent.PickFromCamera)
        advanceUntilIdle()

        assertNotNull(vm.state.value.errorMessage)
        assertFalse(vm.state.value.isPreviewVisible)
    }

    // ── CameraImageCaptured ───────────────────────────────────────────────────

    @Test
    fun `CameraImageCaptured shows preview with camera file path`() = runTest {
        val cameraFile = File("captured.jpg")
        val vm = viewModel(FakeImagePickerRepository(cameraFile = cameraFile))

        vm.handleEvent(ImageEvent.PickFromCamera)   // sets pendingCameraFile
        vm.handleEvent(ImageEvent.CameraImageCaptured)

        assertEquals(cameraFile.absolutePath, vm.state.value.pickedImage?.path)
        assertTrue(vm.state.value.isPreviewVisible)
    }

    @Test
    fun `CameraImageCaptured without prior PickFromCamera is a no-op`() = runTest {
        val vm = viewModel()

        vm.handleEvent(ImageEvent.CameraImageCaptured)

        assertNull(vm.state.value.pickedImage)
        assertFalse(vm.state.value.isPreviewVisible)
    }

    // ── HidePreview / ShowPreview ─────────────────────────────────────────────

    @Test
    fun `HidePreview hides the preview without clearing the image`() = runTest {
        val image = ImageData(path = "img.jpg")
        val vm = viewModel(FakeImagePickerRepository(galleryImageData = image))

        vm.handleEvent(ImageEvent.GalleryImageReceived("content://x"))
        assertTrue(vm.state.value.isPreviewVisible)

        vm.handleEvent(ImageEvent.HidePreview)
        assertFalse(vm.state.value.isPreviewVisible)
        assertEquals(image, vm.state.value.pickedImage)
    }

    @Test
    fun `ShowPreview re-shows preview when an image is present`() = runTest {
        val image = ImageData(path = "img.jpg")
        val vm = viewModel(FakeImagePickerRepository(galleryImageData = image))

        vm.handleEvent(ImageEvent.GalleryImageReceived("content://x"))
        vm.handleEvent(ImageEvent.HidePreview)
        assertFalse(vm.state.value.isPreviewVisible)

        vm.handleEvent(ImageEvent.ShowPreview)
        assertTrue(vm.state.value.isPreviewVisible)
    }

    @Test
    fun `ShowPreview is no-op when no image is picked`() = runTest {
        val vm = viewModel()

        vm.handleEvent(ImageEvent.ShowPreview)

        assertFalse(vm.state.value.isPreviewVisible)
    }

    // ── CancelPick — state ────────────────────────────────────────────────────

    @Test
    fun `CancelPick clears image and hides preview`() = runTest {
        val vm = viewModel(FakeImagePickerRepository(galleryImageData = ImageData(path = "img.jpg")))
        vm.handleEvent(ImageEvent.GalleryImageReceived("content://x"))
        assertTrue(vm.state.value.isPreviewVisible)

        vm.handleEvent(ImageEvent.CancelPick)

        assertNull(vm.state.value.pickedImage)
        assertFalse(vm.state.value.isPreviewVisible)
    }

    // ── CancelPick — file cleanup ─────────────────────────────────────────────

    @Test
    fun `CancelPick deletes the gallery destination file`() = runTest {
        val galleryFile = File.createTempFile("test_gallery", ".jpg")
        assertTrue(galleryFile.exists())

        val vm = viewModel(FakeImagePickerRepository(galleryImageData = ImageData(path = galleryFile.absolutePath)))
        vm.handleEvent(ImageEvent.GalleryImageReceived("content://x"))
        vm.handleEvent(ImageEvent.CancelPick)

        assertFalse(galleryFile.exists())
    }

    @Test
    fun `CancelPick deletes the camera file after capture and preview`() = runTest {
        val cameraFile = File.createTempFile("test_capture", ".jpg")
        assertTrue(cameraFile.exists())

        val vm = viewModel(FakeImagePickerRepository(cameraFile = cameraFile))
        vm.handleEvent(ImageEvent.PickFromCamera)
        vm.handleEvent(ImageEvent.CameraImageCaptured)
        assertTrue(vm.state.value.isPreviewVisible)

        vm.handleEvent(ImageEvent.CancelPick)

        assertFalse(cameraFile.exists())
    }

    @Test
    fun `CancelPick deletes the pending camera file when OS camera is cancelled before capture`() = runTest {
        // Simulates TakePicture returning false — CameraImageCaptured is never dispatched.
        val cameraFile = File.createTempFile("test_pending", ".jpg")
        assertTrue(cameraFile.exists())

        val vm = viewModel(FakeImagePickerRepository(cameraFile = cameraFile))
        vm.handleEvent(ImageEvent.PickFromCamera)
        vm.handleEvent(ImageEvent.CancelPick)

        assertFalse(cameraFile.exists())
    }

    // ── DismissError ──────────────────────────────────────────────────────────

    @Test
    fun `DismissError clears the error message`() = runTest {
        val vm = viewModel(FakeImagePickerRepository(captureError = RuntimeException("setup failed")))
        vm.handleEvent(ImageEvent.PickFromCamera)
        advanceUntilIdle()
        assertNotNull(vm.state.value.errorMessage)

        vm.handleEvent(ImageEvent.DismissError)

        assertNull(vm.state.value.errorMessage)
    }
}
