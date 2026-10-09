// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import OSLog
import Testing
@testable import YaloChatSDK

private final class Lines: @unchecked Sendable {
    private let lock: NSLock = NSLock()
    private var written: [(LogLevel, String)] = []

    var all: [(LogLevel, String)] {
        lock.withLock {
            written
        }
    }

    var texts: [String] {
        all.map(\.1)
    }

    func sink(_ level: LogLevel, _ line: String) {
        lock.withLock {
            written.append((level, line))
        }
    }
}

struct YaloLogTests {
    private let lines: Lines = Lines()

    private func log(_ level: LogLevel) -> YaloLog {
        let lines: Lines = lines
        return YaloLog("Test", level: level) { at, line in
            lines.sink(at, line)
        }
    }

    private func writeOneOfEach(_ log: YaloLog) {
        log.debug("debug")
        log.info("info")
        log.warn("warn")
        log.error("error")
    }

    @Test(arguments: [
        (LogLevel.debug, ["debug", "info", "warn", "error"]),
        (LogLevel.info, ["info", "warn", "error"]),
        (LogLevel.warn, ["warn", "error"]),
        (LogLevel.error, ["error"]),
        (LogLevel.silent, []),
    ] as [(LogLevel, [String])])
    func writesItsLevelAndEverythingAfterIt(level: LogLevel, expected: [String]) {
        writeOneOfEach(log(level))

        #expect(lines.texts == expected)
    }

    @Test func tellsTheSinkWhichLevelALineWasWrittenAt() {
        writeOneOfEach(log(.debug))

        #expect(lines.all.map(\.0) == [.debug, .info, .warn, .error])
    }

    @Test func buildsNoMessageItWillNotWrite() {
        var built: Bool = false
        func message() -> String {
            built = true
            return "expensive"
        }

        log(.warn).debug(message())

        #expect(!built)
    }

    @Test func addsTheErrorToTheLine() {
        log(.warn).warn("upload failed", error: MediaServiceError.uploadFailed(status: 500))

        #expect(lines.texts == ["upload failed: uploadFailed(status: 500)"])
    }

    @Test func leavesTheAddressOutOfANetworkError() {
        let failure: URLError = URLError(
            .timedOut,
            userInfo: [NSURLErrorFailingURLStringErrorKey: "wss://host/connect?token=secret"]
        )

        log(.warn).error("the socket failed", error: failure)

        #expect(lines.texts == ["the socket failed: URLError \(URLError.Code.timedOut.rawValue)"])
    }

    @Test func writesToTheUnifiedLogWhenGivenNoSink() throws {
        let category: String = "Test-\(UUID().uuidString)"
        let store: OSLogStore = try OSLogStore(scope: .currentProcessIdentifier)
        let start: OSLogPosition = store.position(date: Date())

        writeOneOfEach(YaloLog(category, level: .debug))

        // Debug and info lines are kept in memory only, so the store may not hand them back.
        let written: Set<String> = Set(try store.getEntries(at: start)
            .compactMap { $0 as? OSLogEntryLog }
            .filter { $0.subsystem == YaloLog.subsystem && $0.category == category }
            .map(\.composedMessage))
        #expect(written.isSuperset(of: ["warn", "error"]))
    }
}
