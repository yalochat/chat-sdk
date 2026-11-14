// Copyright (c) Yalochat, Inc. All rights reserved.

import PhotosUI
import Testing
@testable import YaloChatSDK

@MainActor
struct ImagePickerTests {
    @Test func pickerRenders() {
        #expect(renders(ImagePicker { _ in }))
    }

    @Test func offersAnyPictureByDefault() {
        #expect(ImagePicker { _ in }.configuration.filter == .images)
    }

    @Test func offersOnlyScreenshotsWhenAsked() {
        #expect(ImagePicker(source: .screenshots) { _ in }.configuration.filter == .screenshots)
    }

    @Test func cancellingFinishesWithNothing() {
        var finished: [NSItemProvider?] = []
        let coordinator: ImagePicker.Coordinator = ImagePicker { picked in
            finished.append(picked)
        }.makeCoordinator()

        coordinator.picker(PHPickerViewController(configuration: PHPickerConfiguration()), didFinishPicking: [])

        #expect(finished.count == 1)
        #expect(finished.first == .some(nil))
    }
}
