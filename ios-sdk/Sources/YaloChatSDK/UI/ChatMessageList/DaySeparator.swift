// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The day the messages under it were sent, as `label(of:now:locale:)` words it.
struct DaySeparator: View {
    let date: Date
    @Environment(\.chatTheme) private var theme: ChatTheme

    var body: some View {
        Text(verbatim: Self.label(of: date))
            .font(theme.font(.caption).weight(.medium))
            .foregroundStyle(theme.timestampColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .accessibilityIdentifier("yalo-chat-day-separator")
    }

    /// "Today", "Yesterday" or the short date such as "Nov 22", in the language
    /// of `locale`. The year is added only for a past year.
    static func label(of date: Date, now: Date = Date(), locale: Locale = .current) -> String {
        var calendar: Calendar = .current
        calendar.locale = locale
        let yesterday: Date = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let daysAgo: Int? = calendar.isDate(date, inSameDayAs: now) ? 0
            : calendar.isDate(date, inSameDayAs: yesterday) ? 1 : nil
        if let daysAgo {
            // Worded against `now` rather than the clock, so a label never goes stale.
            let relative: RelativeDateTimeFormatter = RelativeDateTimeFormatter()
            relative.locale = locale
            relative.calendar = calendar
            relative.dateTimeStyle = .named
            relative.formattingContext = .beginningOfSentence
            return relative.localizedString(from: DateComponents(day: -daysAgo))
        }
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        let sameYear: Bool = calendar.component(.year, from: date) == calendar.component(.year, from: now)
        formatter.setLocalizedDateFormatFromTemplate(sameYear ? "MMMd" : "yMMMd")
        return formatter.string(from: date)
    }
}
