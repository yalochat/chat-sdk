// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// The access token everything else in the conversation sends, and the only
/// place that decides when a new one is needed.
///
/// Held in memory and stored on the device, so starting the app again keeps
/// the person the backend knows, anonymous or not. Storing is an
/// optimization: failing to read or write is answered by authenticating
/// again rather than by an error.
actor TokenRepository {
    private let auth: YaloMessageAuthService
    private let store: TokenStoreService
    private let sessionId: String
    private let ephemeral: Bool
    private let now: @Sendable () -> Date
    private let log: YaloLog
    private var held: AuthToken?
    private var loaded: Bool = false
    private var issuing: Task<AuthToken, Error>?

    init(
        auth: YaloMessageAuthService,
        store: TokenStoreService,
        sessionId: String,
        ephemeral: Bool = false,
        now: @escaping @Sendable () -> Date = { Date() },
        logLevel: LogLevel = .warn
    ) {
        self.auth = auth
        self.store = store
        self.sessionId = sessionId
        self.ephemeral = ephemeral
        self.now = now
        self.log = YaloLog("Token", level: logLevel)
    }

    /// Several callers asking at once share one exchange with the backend.
    func token() async throws -> String {
        let current: AuthToken? = current()
        if let current, current.usable(at: now()) {
            log.debug("the token in hand is still good")
            return current.accessToken
        }
        if let issuing {
            return try await issuing.value.accessToken
        }
        let auth: YaloMessageAuthService = auth
        let refreshToken: String = current?.refreshToken ?? ""
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
        keep(issued)
        return issued.accessToken
    }

    /// Forgets the token the backend refused, so the next caller gets a new one.
    /// The refresh token is kept, so the person stays the same.
    func invalidate() {
        guard let current = current() else {
            return
        }
        log.info("the backend refused the token, the next one will be another")
        keep(AuthToken(accessToken: current.accessToken, refreshToken: current.refreshToken, expiresAt: .distantPast))
    }

    /// Forgets the tokens of `sessionIds`, which do not have to include this
    /// one. Sessions with nothing stored are no error.
    func deleteSessions(_ sessionIds: [String]) throws {
        do {
            try store.delete(sessionIds: sessionIds)
        } catch {
            log.warn("the stored tokens cannot be forgotten", error: error)
            throw error
        }
        if sessionIds.contains(sessionId) {
            held = nil
        }
    }

    /// The sessions whose stored token says they are to leave nothing behind.
    func ephemeralSessions() -> Set<String> {
        do {
            return try store.ephemeralSessionIds()
        } catch {
            log.warn("the stored tokens cannot be listed", error: error)
            return []
        }
    }

    /// What this conversation holds, read back from the device the first time.
    private func current() -> AuthToken? {
        if loaded {
            return held
        }
        loaded = true
        do {
            held = try store.token(sessionId: sessionId)
        } catch {
            log.warn("the stored token cannot be read, forgetting it", error: error)
            try? store.delete(sessionIds: [sessionId])
        }
        return held
    }

    private func keep(_ token: AuthToken) {
        held = token
        do {
            try store.save(token, sessionId: sessionId, ephemeral: ephemeral)
        } catch {
            log.warn("the token cannot be stored, keeping it for this run only", error: error)
        }
    }
}
