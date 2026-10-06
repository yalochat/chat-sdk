// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

struct YaloMessageAuthRemoteServiceTests {
    private static let now: Date = Date(timeIntervalSince1970: 1_700_000_000)

    private func service(_ server: StubServer, authUserId: String? = nil) -> YaloMessageAuthRemoteService {
        YaloMessageAuthRemoteService(
            channelId: "channel-1",
            organizationId: "org-1",
            authUserId: authUserId,
            baseURL: server.baseURL,
            session: server.session,
            now: { Self.now }
        )
    }

    private static func tokenResponse(
        accessToken: String = "access",
        refreshToken: String = "refresh",
        expiresIn: Int = 3_600
    ) -> Data {
        Data("""
        {"access_token": "\(accessToken)", "refresh_token": "\(refreshToken)", "expires_in": \(expiresIn)}
        """.utf8)
    }

    private func sentJSON(_ server: StubServer) throws -> [String: Any] {
        let sent: RecordedRequest = try #require(server.requests.first)
        return try #require(try JSONSerialization.jsonObject(with: sent.body) as? [String: Any])
    }

    @Test func authenticatesAnonymouslyWhenThereIsNoUser() async throws {
        let server: StubServer = StubServer(body: Self.tokenResponse())

        _ = try await service(server).authenticate()

        let body: [String: Any] = try sentJSON(server)
        #expect(body["user_type"] as? String == "anonymous")
        #expect(body["user_id"] == nil)
    }

    @Test func identifiesTheUserWhenThereIsOne() async throws {
        let server: StubServer = StubServer(body: Self.tokenResponse())

        _ = try await service(server, authUserId: "user-1").authenticate()

        let body: [String: Any] = try sentJSON(server)
        #expect(body["user_type"] as? String == "third_party_anonymous")
        #expect(body["user_id"] as? String == "user-1")
    }

    @Test func sendsTheChannelItIsAuthenticatingFor() async throws {
        let server: StubServer = StubServer(body: Self.tokenResponse())

        _ = try await service(server).authenticate()

        let sent: RecordedRequest = try #require(server.requests.first)
        let body: [String: Any] = try sentJSON(server)
        #expect(sent.request.httpMethod == "POST")
        #expect(sent.request.url?.path == "/v1/channels/auth")
        #expect(sent.request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(body["channel_id"] as? String == "channel-1")
        #expect(body["organization_id"] as? String == "org-1")
        #expect((body["timestamp"] as? NSNumber)?.int64Value == 1_700_000_000)
    }

    @Test func returnsTheTokenTheBackendIssued() async throws {
        let server: StubServer = StubServer(body: Self.tokenResponse(accessToken: "issued", refreshToken: "for-later"))

        let token: AuthToken = try await service(server).authenticate()

        #expect(token == AuthToken(
            accessToken: "issued",
            refreshToken: "for-later",
            expiresAt: Self.now.addingTimeInterval(3_600)
        ))
    }

    @Test func readsCamelCaseFields() async throws {
        let server: StubServer = StubServer(body: Data("""
        {"accessToken": "camel", "refreshToken": "r", "expiresIn": 60}
        """.utf8))

        let token: AuthToken = try await service(server).authenticate()

        #expect(token == AuthToken(accessToken: "camel", refreshToken: "r", expiresAt: Self.now.addingTimeInterval(60)))
    }

    @Test func authenticateFailsOnAnErrorStatus() async throws {
        let server: StubServer = StubServer(status: 401)

        await #expect(throws: AuthServiceError.authenticateFailed(status: 401)) {
            try await service(server).authenticate()
        }
    }

    @Test func authenticateFailsWhenTheAnswerIsNotAToken() async throws {
        let server: StubServer = StubServer(body: Data("not json at all".utf8))

        await #expect(throws: AuthServiceError.unreadableResponse) {
            try await service(server).authenticate()
        }
    }

    @Test func failsWhenTheBackendCannotBeReached() async throws {
        let server: StubServer = StubServer()
        let unreachable: YaloMessageAuthRemoteService = YaloMessageAuthRemoteService(
            channelId: "channel-1",
            organizationId: "org-1",
            authUserId: nil,
            baseURL: URL(string: "https://unregistered.test/")!,
            session: server.session
        )

        await #expect(throws: URLError.self) {
            try await unreachable.authenticate()
        }
        await #expect(throws: URLError.self) {
            try await unreachable.refresh("refresh")
        }
    }

    @Test func tradesARefreshTokenForANewOne() async throws {
        let server: StubServer = StubServer(body: Self.tokenResponse(accessToken: "refreshed", refreshToken: "the-next-one"))

        let token: AuthToken = try await service(server).refresh("the+refresh/token")

        let sent: RecordedRequest = try #require(server.requests.first)
        #expect(sent.request.httpMethod == "POST")
        #expect(sent.request.url?.path == "/v1/channels/oauth/token")
        #expect(sent.request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
        #expect(String(decoding: sent.body, as: UTF8.self) == "grant_type=refresh_token&refresh_token=the%2Brefresh%2Ftoken")
        #expect(token == AuthToken(
            accessToken: "refreshed",
            refreshToken: "the-next-one",
            expiresAt: Self.now.addingTimeInterval(3_600)
        ))
    }

    @Test func keepsTheRefreshTokenWhenTheAnswerCarriesNoNewOne() async throws {
        let server: StubServer = StubServer(body: Data("""
        {"access_token": "refreshed", "expires_in": 3600}
        """.utf8))

        let token: AuthToken = try await service(server).refresh("the-refresh-token")

        #expect(token.refreshToken == "the-refresh-token")
    }

    @Test func refreshFailsOnAnErrorStatus() async throws {
        let server: StubServer = StubServer(status: 403)

        await #expect(throws: AuthServiceError.refreshFailed(status: 403)) {
            try await service(server).refresh("stale")
        }
    }
}
