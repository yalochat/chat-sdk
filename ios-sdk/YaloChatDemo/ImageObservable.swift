// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import PhotosUI
import SwiftUI
import UIKit

class ImageObservable: ObservableObject {

    @Published var pickedRawImage: UIImage? = nil
    @Published var pickedImagePath: String? = nil
    @Published var mimeType: String = "image/jpeg"
    @Published var showSourceSheet: Bool = false
    @Published var showGallery: Bool = false
    @Published var showCamera: Bool = false

    func setPickedImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".jpg")
        do {
            try data.write(to: url)
            pickedRawImage = image
            pickedImagePath = url.path
            mimeType = "image/jpeg"
        } catch {
            // No-op — user can retry by picking again
        }
    }

    func clearImage() {
        pickedRawImage = nil
        pickedImagePath = nil
    }
}

// ── Gallery picker (iOS 14+) ──────────────────────────────────────────────────

struct PHPickerRepresentable: UIViewControllerRepresentable {

    let imageObservable: ImageObservable

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(imageObservable) }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let observable: ImageObservable
        init(_ observable: ImageObservable) { self.observable = observable }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let result = results.first else { return }
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                DispatchQueue.main.async {
                    if let image = object as? UIImage {
                        self.observable.setPickedImage(image)
                    }
                }
            }
        }
    }
}

// ── Camera picker ─────────────────────────────────────────────────────────────

struct CameraPickerRepresentable: UIViewControllerRepresentable {

    let imageObservable: ImageObservable

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(imageObservable) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let observable: ImageObservable
        init(_ observable: ImageObservable) { self.observable = observable }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                observable.setPickedImage(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
