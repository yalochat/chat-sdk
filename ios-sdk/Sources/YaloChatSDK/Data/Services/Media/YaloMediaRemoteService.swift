// Copyright (c) Yalochat, Inc. All rights reserved.

import CryptoKit
import Foundation

final class YaloMediaRemoteService: YaloMediaService {
    private let mediaURL: URL
    private let cacheDirectory: URL
    private let session: URLSession

    init(
        baseURL: URL,
        cacheDirectory: URL = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("yalo-chat-media", isDirectory: true),
        session: URLSession = .shared
    ) {
        self.mediaURL = baseURL.appendingPathComponent("v1/channels/all/media")
        self.cacheDirectory = cacheDirectory
        self.session = session
    }

    func upload(_ content: MediaContent, token: String) async throws -> Media {
        let boundary: String = "yalo-chat-\(UUID().uuidString)"
        let body: URL = try await Self.writeMultipartBody(content, boundary: boundary)
        defer {
            try? FileManager.default.removeItem(at: body)
        }
        let size: Int = try body.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0

        var request: URLRequest = URLRequest(url: mediaURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(String(size), forHTTPHeaderField: "Content-Length")
        // Streamed from disk so a video never has to fit in memory.
        request.httpBodyStream = InputStream(url: body)

        let (data, response): (Data, URLResponse) = try await session.data(for: request)
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
        case 201:
            return try Self.media(from: data)
        case 401:
            throw MediaServiceError.staleToken
        case let status:
            throw MediaServiceError.uploadFailed(status: status)
        }
    }

    func download(_ url: String) async throws -> URL {
        guard
            let address = URL(string: url),
            let scheme = address.scheme?.lowercased(),
            scheme == "http" || scheme == "https",
            let key = Self.cacheKey(address)
        else {
            throw MediaServiceError.invalidAddress(url)
        }
        let target: URL = cacheDirectory.appendingPathComponent(key)
        if FileManager.default.fileExists(atPath: target.path) {
            return target
        }

        // No authorization: the address is already signed.
        let (temporary, response): (URL, URLResponse) = try await session.download(from: address)
        let status: Int = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            try? FileManager.default.removeItem(at: temporary)
            throw MediaServiceError.downloadFailed(status: status)
        }
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        do {
            try FileManager.default.moveItem(at: temporary, to: target)
        } catch where FileManager.default.fileExists(atPath: target.path) {
            // A concurrent download of the same file got there first.
            try? FileManager.default.removeItem(at: temporary)
        }
        return target
    }

    @concurrent
    private static func writeMultipartBody(_ content: MediaContent, boundary: String) async throws -> URL {
        let input: FileHandle = try FileHandle(forReadingFrom: content.fileURL)
        defer {
            try? input.close()
        }
        let body: URL = FileManager.default.temporaryDirectory
            .appendingPathComponent("yalo-chat-upload-\(UUID().uuidString)")
        FileManager.default.createFile(atPath: body.path, contents: nil)
        do {
            let output: FileHandle = try FileHandle(forWritingTo: body)
            defer {
                try? output.close()
            }
            let fileName: String = content.fileName
                .replacingOccurrences(of: "\"", with: "%22")
                .replacingOccurrences(of: "\r", with: "%0D")
                .replacingOccurrences(of: "\n", with: "%0A")
            let head: String = "--\(boundary)\r\n"
                + "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n"
                + "Content-Type: \(content.mimeType)\r\n\r\n"
            try output.write(contentsOf: Data(head.utf8))
            while let chunk = try input.read(upToCount: 64 * 1024), !chunk.isEmpty {
                try output.write(contentsOf: chunk)
            }
            try output.write(contentsOf: Data("\r\n--\(boundary)--\r\n".utf8))
        } catch {
            try? FileManager.default.removeItem(at: body)
            throw error
        }
        return body
    }

    // The signature differs on every read of the same media, so the query is left out.
    private static func cacheKey(_ url: URL) -> String? {
        guard
            let host = url.host,
            let path = URLComponents(url: url, resolvingAgainstBaseURL: false)?.percentEncodedPath
        else {
            return nil
        }
        return SHA256.hash(data: Data("\(host)\(path)".utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    // Snake case from the endpoint, camel case from a serialised protobuf.
    private static func media(from data: Data) throws -> Media {
        guard let fields = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw MediaServiceError.unreadableResponse
        }
        func text(_ keys: String...) -> String {
            keys.lazy.compactMap { fields[$0] as? String }.first { !$0.isEmpty } ?? ""
        }
        return Media(
            id: text("id"),
            signedURL: text("signed_url", "signedUrl"),
            originalName: text("original_name", "originalName"),
            type: MessageType.of(text("type"))
        )
    }
}
