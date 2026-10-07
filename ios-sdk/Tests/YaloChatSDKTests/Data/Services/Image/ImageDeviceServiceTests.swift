// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
import UniformTypeIdentifiers
@testable import YaloChatSDK

struct ImageDeviceServiceTests {
    private let directory: URL = FileManager.default.temporaryDirectory
        .appendingPathComponent("yalo-chat-images-tests-\(UUID().uuidString)", isDirectory: true)

    private var service: ImageDeviceService {
        ImageDeviceService(directory: directory)
    }

    private static func picture(_ name: String, bytes: String = "picture bytes") throws -> URL {
        let folder: URL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let file: URL = folder.appendingPathComponent(name)
        try Data(bytes.utf8).write(to: file)
        return file
    }

    private static func provider(_ type: UTType, file: URL?, suggestedName: String?) -> NSItemProvider {
        let provider: NSItemProvider = NSItemProvider()
        provider.suggestedName = suggestedName
        provider.registerFileRepresentation(forTypeIdentifier: type.identifier, visibility: .all) { completion in
            completion(file, false, file == nil ? CocoaError(.fileReadUnknown) : nil)
            return nil
        }
        return provider
    }

    @Test func describesACopyOfThePickedPicture() async throws {
        let picked: URL = try Self.picture("holiday.jpg")

        let content: MediaContent = try await service.content(Self.provider(.jpeg, file: picked, suggestedName: "holiday"))

        #expect(content.fileName == "holiday.jpeg")
        #expect(content.mimeType == "image/jpeg")
        #expect(content.fileURL.deletingLastPathComponent().standardizedFileURL == directory.standardizedFileURL)
        #expect(try Data(contentsOf: content.fileURL) == Data("picture bytes".utf8))
    }

    @Test func theCopyOutlivesThePickedFile() async throws {
        let picked: URL = try Self.picture("holiday.jpg")

        let content: MediaContent = try await service.content(try #require(NSItemProvider(contentsOf: picked)))
        try FileManager.default.removeItem(at: picked)

        #expect(try Data(contentsOf: content.fileURL) == Data("picture bytes".utf8))
    }

    @Test func picturesWithTheSameNameDoNotOverwriteEachOther() async throws {
        let first: URL = try Self.picture("photo.jpg", bytes: "first")
        let second: URL = try Self.picture("photo.jpg", bytes: "second")

        let firstCopy: MediaContent = try await service.content(try #require(NSItemProvider(contentsOf: first)))
        let secondCopy: MediaContent = try await service.content(try #require(NSItemProvider(contentsOf: second)))

        #expect(try Data(contentsOf: firstCopy.fileURL) == Data("first".utf8))
        #expect(try Data(contentsOf: secondCopy.fileURL) == Data("second".utf8))
    }

    @Test func aNameWithoutExtensionTakesTheOneOfThePicture() async throws {
        let picked: URL = try Self.picture("screenshot.png")

        let content: MediaContent = try await service.content(Self.provider(.png, file: picked, suggestedName: "screenshot"))

        #expect(content.fileName == "screenshot.png")
        #expect(content.mimeType == "image/png")
        #expect(content.fileURL.pathExtension == "png")
    }

    @Test func aFileWithoutExtensionIsNamedAfterItsType() async throws {
        let picked: URL = try Self.picture("picture")

        let content: MediaContent = try await service.content(Self.provider(.png, file: picked, suggestedName: nil))

        #expect(content.fileName == "image.png")
        #expect(content.fileURL.pathExtension == "png")
    }

    @Test func somethingThatIsNotAPictureIsRefused() async throws {
        await #expect(throws: ImageServiceError.notAnImage) {
            try await service.content(NSItemProvider(object: "Hello" as NSString))
        }
    }

    @Test func aPictureTheDeviceWillNotHandOverIsUnreadable() async throws {
        await #expect(throws: ImageServiceError.unreadable) {
            try await service.content(Self.provider(.jpeg, file: nil, suggestedName: "holiday"))
        }
    }

    @Test func aFolderThatCannotBeCreatedMakesThePictureUnreadable() async throws {
        let blocker: URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data("not a folder".utf8).write(to: blocker)
        let picked: URL = try Self.picture("holiday.jpg")

        await #expect(throws: ImageServiceError.unreadable) {
            try await ImageDeviceService(directory: blocker.appendingPathComponent("images"))
                .content(try #require(NSItemProvider(contentsOf: picked)))
        }
    }
}
