// Copyright (c) Yalochat, Inc. All rights reserved.

import ImageIO
import UIKit
import UniformTypeIdentifiers

/// Copies picked pictures into `directory` and reads them back.
final class ImageDeviceService: ImageService {
    private let directory: URL
    private let log: YaloLog

    /// Long side, in pixels, of a picture drawn in a bubble. Enough for a
    /// sharp full width bubble without holding a camera sized bitmap per message.
    private static let maxPixelSize: Int = 2_048

    init(directory: URL, logLevel: LogLevel = .warn) {
        self.directory = directory
        self.log = YaloLog("Images", level: logLevel)
    }

    func file(of picture: ImageAttachment) -> URL? {
        guard let name = picture.localFileName else {
            return nil
        }
        let file: URL = directory.appendingPathComponent(name)
        return FileManager.default.fileExists(atPath: file.path) ? file : nil
    }

    @concurrent
    func image(at file: URL) async -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(file as CFURL, nil) else {
            return nil
        }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            // Turns the picture the way the camera held it.
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: Self.maxPixelSize,
        ]
        guard let picture = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: picture)
    }

    func content(_ picked: NSItemProvider) async throws -> MediaContent {
        // The provider lists its types best quality first.
        guard let type = picked.registeredTypeIdentifiers.lazy
            .compactMap(UTType.init)
            .first(where: { $0.conforms(to: .image) })
        else {
            log.warn("what was picked is not a picture")
            throw ImageServiceError.notAnImage
        }
        let directory: URL = directory
        let copy: URL
        do {
            copy = try await withCheckedThrowingContinuation { continuation in
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
        } catch {
            log.warn("the picture could not be read", error: error)
            throw error
        }
        var fileName: String = picked.suggestedName ?? "image"
        if (fileName as NSString).pathExtension.isEmpty, !copy.pathExtension.isEmpty {
            fileName += ".\(copy.pathExtension)"
        }
        log.info("kept a picture as \(copy.lastPathComponent)")
        return MediaContent(
            fileURL: copy,
            fileName: fileName,
            mimeType: type.preferredMIMEType ?? "application/octet-stream"
        )
    }
}
