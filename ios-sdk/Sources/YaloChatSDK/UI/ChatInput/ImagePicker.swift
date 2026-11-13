// Copyright (c) Yalochat, Inc. All rights reserved.

import PhotosUI
import SwiftUI

/// The system photo picker, limited to one picture. It runs outside the app,
/// so it needs no photo library permission and hands over only what was picked.
/// `onFinish` gets nil when the person cancels. With `.screenshots` the picker
/// lists nothing else, so there is nothing to turn away afterwards.
struct ImagePicker: UIViewControllerRepresentable {
    var source: ImageSource = .all
    let onFinish: (NSItemProvider?) -> Void

    var configuration: PHPickerConfiguration {
        var configuration: PHPickerConfiguration = PHPickerConfiguration()
        configuration.filter = source == .screenshots ? .screenshots : .images
        configuration.selectionLimit = 1
        return configuration
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
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
