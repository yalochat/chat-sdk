// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// The access token everything else in the conversation sends, and the only
/// place that decides when a new one is needed. Kept in memory, so every run
/// of the app starts with a new one.
actor TokenRepository {
    private let auth: YaloMessageAuthService
    private let now: @Sendable () -> Date
    private let log: YaloLog
    private var held: AuthToken?
    private var issuing: Task<AuthToken, Error>?

    init(
        auth: YaloMessageAuthService,
        now: @escaping @Sendable () -> Date = { Date() },
        logLevel: LogLevel = .warn
    ) {
        self.auth = auth
        self.now = now
        self.log = YaloLog("Token", level: logLevel)
    }

    /// Several callers asking at once share one exchange with the backend.
    func token() async throws -> String {
        if let held, held.usable(at: now()) {
            log.debug("the token in hand is still good")
            return held.accessToken
        }
        if let issuing {
            return try await issuing.value.accessToken
        }
        let auth: YaloMessageAuthService = auth
        let refreshToken: String = held?.refreshToken ?? ""
        let log: YaloLog = log
        let issuing: Task<AuthToken, Error> = Task {
            // A refresh keeps the person the backend knows, so it goes first.
            if !refreshToken.isEmpty {
                if let refreshed = try? await auth.refresh(refreshToken) {
                    return refreshed
                }
                log.info("the refresh was refused, authenticating instead")
            }
            return try await auth.authenticate()
        }
        self.issuing = issuing
        defer {
            self.issuing = nil
        }
        let issued: AuthToken = try await issuing.value
        held = issued
        return issued.accessToken
    }

    /// Forgets the token the backend refused, so the next caller gets a new one.
    /// The refresh token is kept, so the person stays the same.
    func invalidate() {
        guard let held else {
            return
        }
        log.info("the backend refused the token, the next one will be another")
        self.held = AuthToken(accessToken: held.accessToken, refreshToken: held.refreshToken, expiresAt: .distantPast)
    }
}
