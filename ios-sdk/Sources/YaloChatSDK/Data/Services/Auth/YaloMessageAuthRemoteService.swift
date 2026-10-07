// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// `authUserId` is who the backend is told it is talking to. Nil asks for a
/// fresh anonymous one.
final class YaloMessageAuthRemoteService: YaloMessageAuthService {
    private let channelId: String
    private let organizationId: String
    private let authUserId: String?
    private let channelsURL: URL
    private let session: URLSession
    private let now: @Sendable () -> Date

    init(
        channelId: String,
        organizationId: String,
        authUserId: String?,
        baseURL: URL,
        session: URLSession = .shared,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.channelId = channelId
        self.organizationId = organizationId
        self.authUserId = authUserId
        self.channelsURL = baseURL.appendingPathComponent("v1/channels")
        self.session = session
        self.now = now
    }

    func authenticate() async throws -> AuthToken {
        let body: AuthRequest = AuthRequest(
            userType: authUserId == nil ? "anonymous" : "third_party_anonymous",
            userId: authUserId,
            channelId: channelId,
            organizationId: organizationId,
            timestamp: Int64(now().timeIntervalSince1970)
        )
        var request: URLRequest = URLRequest(url: channelsURL.appendingPathComponent("auth"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return try await call(request, failure: AuthServiceError.authenticateFailed)
    }

    func refresh(_ refreshToken: String) async throws -> AuthToken {
        var request: URLRequest = URLRequest(url: channelsURL.appendingPathComponent("oauth/token"))
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data("grant_type=refresh_token&refresh_token=\(Self.formEncoded(refreshToken))".utf8)
        // An answer carrying no new refresh token leaves the old one in place.
        return try await call(request, failure: AuthServiceError.refreshFailed, heldRefreshToken: refreshToken)
    }

    private func call(
        _ request: URLRequest,
        failure: (Int) -> AuthServiceError,
        heldRefreshToken: String = ""
    ) async throws -> AuthToken {
        let (data, response): (Data, URLResponse) = try await session.data(for: request)
        let status: Int = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            throw failure(status)
        }
        return try token(from: data, heldRefreshToken: heldRefreshToken)
    }

    // Snake case from the OAuth refresh endpoint, camel case from the auth endpoint's protobuf.
    private func token(from data: Data, heldRefreshToken: String) throws -> AuthToken {
        guard let fields = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AuthServiceError.unreadableResponse
        }
        func text(_ keys: String...) -> String {
            keys.lazy.compactMap { fields[$0] as? String }.first { !$0.isEmpty } ?? ""
        }
        let lifetime: Double = ["expires_in", "expiresIn"].lazy
            .compactMap { (fields[$0] as? NSNumber)?.doubleValue }
            .first ?? 0
        let refreshToken: String = text("refresh_token", "refreshToken")
        return AuthToken(
            accessToken: text("access_token", "accessToken"),
            refreshToken: refreshToken.isEmpty ? heldRefreshToken : refreshToken,
            expiresAt: now().addingTimeInterval(lifetime)
        )
    }

    private static let formUnreserved: CharacterSet = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )

    private static func formEncoded(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: formUnreserved) ?? value
    }
}

private struct AuthRequest: Encodable {
    let userType: String
    let userId: String?
    let channelId: String
    let organizationId: String
    let timestamp: Int64

    enum CodingKeys: String, CodingKey {
        case userType = "user_type"
        case userId = "user_id"
        case channelId = "channel_id"
        case organizationId = "organization_id"
        case timestamp
    }
}
