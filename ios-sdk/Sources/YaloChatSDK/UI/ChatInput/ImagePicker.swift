// Copyright (c) Yalochat, Inc. All rights reserved.

import PhotosUI
import SwiftUI

/// The system photo picker, limited to one picture. It runs outside the app,
/// so it needs no photo library permission and hands over only what was picked.
/// `onFinish` gets nil when the person cancels.
struct ImagePicker: UIViewControllerRepresentable {
    let onFinish: (NSItemProvider?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration: PHPickerConfiguration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker: PHPickerViewController = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ picker: PHPickerViewController, context: Context) {
        context.coordinator.onFinish = onFinish
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onFinish: (NSItemProvider?) -> Void

        init(onFinish: @escaping (NSItemProvider?) -> Void) {
            self.onFinish = onFinish
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            onFinish(results.first?.itemProvider)
        }
    }
}
