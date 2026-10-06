// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

struct RecordedRequest: Sendable {
    let request: URLRequest
    let body: Data
}

/// Answers every request sent to its own host, and records them.
final class StubServer: @unchecked Sendable {
    let baseURL: URL
    let session: URLSession
    private let lock: NSLock = NSLock()
    private var status: Int
    private var body: Data
    private var recorded: [RecordedRequest] = []

    init(status: Int = 200, body: Data = Data()) {
        self.status = status
        self.body = body
        self.baseURL = URL(string: "https://\(UUID().uuidString.lowercased()).test/")!
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        self.session = URLSession(configuration: configuration)
        StubURLProtocol.register(self, for: baseURL.host!)
    }

    var requests: [RecordedRequest] {
        lock.withLock {
            recorded
        }
    }

    func respond(status: Int, body: Data = Data()) {
        lock.withLock {
            self.status = status
            self.body = body
        }
    }

    fileprivate func answer(_ request: URLRequest, body requestBody: Data) -> (Int, Data) {
        lock.withLock {
            recorded.append(RecordedRequest(request: request, body: requestBody))
            return (status, body)
        }
    }
}

final class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) private static var servers: [String: StubServer] = [:]
    private static let lock: NSLock = NSLock()

    fileprivate static func register(_ server: StubServer, for host: String) {
        lock.withLock {
            servers[host] = server
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let url: URL = request.url!
        let server: StubServer? = Self.lock.withLock {
            Self.servers[url.host ?? ""]
        }
        guard let server else {
            client?.urlProtocol(self, didFailWithError: URLError(.cannotFindHost))
            return
        }
        let (status, data): (Int, Data) = server.answer(request, body: Self.readBody(of: request))
        let response: HTTPURLResponse = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    private static func readBody(of request: URLRequest) -> Data {
        guard let stream = request.httpBodyStream else {
            return request.httpBody ?? Data()
        }
        stream.open()
        defer {
            stream.close()
        }
        var data: Data = Data()
        var buffer: [UInt8] = [UInt8](repeating: 0, count: 16 * 1024)
        while stream.hasBytesAvailable {
            let read: Int = stream.read(&buffer, maxLength: buffer.count)
            if read <= 0 {
                break
            }
            data.append(buffer, count: read)
        }
        return data
    }
}
