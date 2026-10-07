// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import UniformTypeIdentifiers

/// Copies picked pictures into `directory`.
final class ImageDeviceService: ImageService {
    private let directory: URL

    init(directory: URL) {
        self.directory = directory
    }

    func content(_ picked: NSItemProvider) async throws -> MediaContent {
        // The provider lists its types best quality first.
        guard let type = picked.registeredTypeIdentifiers.lazy
            .compactMap(UTType.init)
            .first(where: { $0.conforms(to: .image) })
        else {
            throw ImageServiceError.notAnImage
        }
        let directory: URL = directory
        let copy: URL = try await withCheckedThrowingContinuation { continuation in
            _ = picked.loadFileRepresentation(forTypeIdentifier: type.identifier) { file, _ in
                guard let file else {
                    continuation.resume(throwing: ImageServiceError.unreadable)
                    return
                }
                // Two pictures can share a name, so the copy gets its own.
                let target: URL = directory
                    .appendingPathComponent("image-\(UUID().uuidString)")
                    .appendingPathExtension(type.preferredFilenameExtension ?? file.pathExtension)
                do {
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                    try FileManager.default.copyItem(at: file, to: target)
                    continuation.resume(returning: target)
                } catch {
                    continuation.resume(throwing: ImageServiceError.unreadable)
                }
            }
        }
        var fileName: String = picked.suggestedName ?? "image"
        if (fileName as NSString).pathExtension.isEmpty, !copy.pathExtension.isEmpty {
            fileName += ".\(copy.pathExtension)"
        }
        return MediaContent(
            fileURL: copy,
            fileName: fileName,
            mimeType: type.preferredMIMEType ?? "application/octet-stream"
        )
    }
}
