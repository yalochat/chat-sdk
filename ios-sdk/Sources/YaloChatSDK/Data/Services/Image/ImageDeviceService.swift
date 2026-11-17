// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation
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

    @concurrent
    func preview(of video: VideoAttachment, at file: URL) async -> VideoPreview? {
        guard let playable = Self.playable(file, of: video) else {
            log.warn("the video could not be opened")
            return nil
        }
        let asset: AVURLAsset = AVURLAsset(url: playable)
        let generator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: Self.maxPixelSize, height: Self.maxPixelSize)
        let frame: CGImage
        do {
            if #available(iOS 16, *) {
                frame = try await generator.image(at: .zero).image
            } else {
                frame = try generator.copyCGImage(at: .zero, actualTime: nil)
            }
        } catch {
            log.warn("the video could not be read", error: error)
            return nil
        }
        let length: Double = (try? await asset.load(.duration)).map(CMTimeGetSeconds) ?? 0
        return VideoPreview(file: playable, poster: UIImage(cgImage: frame), duration: length.isFinite ? length : 0)
    }

    /// AVFoundation tells a video's format by its extension, which downloads
    /// are kept without, so the playable file is a link that has one.
    private static func playable(_ file: URL, of video: VideoAttachment) -> URL? {
        guard file.pathExtension.isEmpty else {
            return file
        }
        let named: String = (video.fileName as NSString).pathExtension
        let fileExtension: String = UTType(mimeType: video.mimeType)?.preferredFilenameExtension
            ?? (named.isEmpty ? "mp4" : named)
        let link: URL = file.appendingPathExtension(fileExtension)
        if FileManager.default.fileExists(atPath: link.path) {
            return link
        }
        do {
            try FileManager.default.linkItem(at: file, to: link)
        } catch {
            guard (try? FileManager.default.copyItem(at: file, to: link)) != nil else {
                return nil
            }
        }
        return link
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
