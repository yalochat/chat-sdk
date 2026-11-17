// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation
import Foundation

/// A two second, 64 by 48 MP4 written for a test, named `name` in a folder of its own.
func videoFile(named name: String = "setup.mp4") async throws -> URL {
    let folder: URL = FileManager.default.temporaryDirectory
        .appendingPathComponent("yalo-chat-video-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    let written: URL = folder.appendingPathComponent("written.mp4")
    let writer: AVAssetWriter = try AVAssetWriter(outputURL: written, fileType: .mp4)
    let input: AVAssetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: 64,
        AVVideoHeightKey: 48,
    ])
    let adaptor: AVAssetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: input,
        sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: 64,
            kCVPixelBufferHeightKey as String: 48,
        ]
    )
    writer.add(input)
    writer.startWriting()
    writer.startSession(atSourceTime: .zero)
    for frame in 0..<5 {
        while !input.isReadyForMoreMediaData {
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        var buffer: CVPixelBuffer?
        if let pool = adaptor.pixelBufferPool {
            CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
        }
        if let buffer {
            adaptor.append(buffer, withPresentationTime: CMTime(value: CMTimeValue(frame), timescale: 2))
        }
    }
    input.markAsFinished()
    writer.endSession(atSourceTime: CMTime(value: 4, timescale: 2))
    await writer.finishWriting()
    let file: URL = folder.appendingPathComponent(name)
    try FileManager.default.moveItem(at: written, to: file)
    return file
}
