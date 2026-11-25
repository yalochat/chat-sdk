// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

struct DaySeparatorTests {
    private let english: Locale = Locale(identifier: "en_US")

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    @Test func namesTodayAndYesterday() {
        let now: Date = date(2026, 11, 24)

        #expect(DaySeparator.label(of: now, now: now, locale: english) == "Today")
        #expect(DaySeparator.label(of: date(2026, 11, 23), now: now, locale: english) == "Yesterday")
    }

    @Test func givesTheShortDateFromTwoDaysAgo() {
        let now: Date = date(2026, 11, 24)

        #expect(DaySeparator.label(of: date(2026, 11, 22), now: now, locale: english) == "Nov 22")
    }

    @Test func addsTheYearForAPastYear() {
        let now: Date = date(2026, 11, 24)

        #expect(DaySeparator.label(of: date(2025, 11, 22), now: now, locale: english) == "Nov 22, 2025")
    }
}
