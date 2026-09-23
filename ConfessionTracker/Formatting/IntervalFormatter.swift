import Foundation

/// Pure interval formatting shared by the summary, history rows, and the guide.
nonisolated enum IntervalFormatter {
    static func bucket(from earlier: Date, to later: Date, calendar: Calendar) -> IntervalBucket {
        let start = calendar.startOfDay(for: earlier)
        let end = calendar.startOfDay(for: later)
        let dayCount = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        if dayCount <= 0 {
            return .sameDay
        }
        if dayCount <= 13 {
            return .days(dayCount)
        }
        if dayCount <= 59 {
            return .weeks(dayCount / 7)
        }
        let monthCount = calendar.dateComponents([.month], from: start, to: end).month ?? 0
        if monthCount < 24 {
            return .months(max(monthCount, 2))
        }
        return .years(monthCount / 12)
    }

    static func sinceLast(_ last: Date, now: Date, calendar: Calendar, locale: Locale = .current) -> String {
        switch bucket(from: last, to: now, calendar: calendar) {
        case .sameDay:
            return L10n.text("interval.today", locale: locale)
        case .days(1):
            return L10n.text("interval.yesterday", locale: locale)
        case .days(let count):
            return L10n.daysAgo(count, locale: locale)
        case .weeks(let count):
            return L10n.weeksAgo(count, locale: locale)
        case .months(let count):
            return L10n.monthsAgo(count, locale: locale)
        case .years(let count):
            return L10n.yearsAgo(count, locale: locale)
        }
    }

    static func afterPrevious(current: Date, previous: Date, calendar: Calendar, locale: Locale = .current) -> String {
        switch bucket(from: previous, to: current, calendar: calendar) {
        case .sameDay:
            return L10n.text("interval.sameDayAsPrevious", locale: locale)
        case .days(let count):
            return L10n.daysAfterPrevious(count, locale: locale)
        case .weeks(let count):
            return L10n.weeksAfterPrevious(count, locale: locale)
        case .months(let count):
            return L10n.monthsAfterPrevious(count, locale: locale)
        case .years(let count):
            return L10n.yearsAfterPrevious(count, locale: locale)
        }
    }

    /// Phrase that fills `{interval}` in the guide's opening line. Never a full sentence.
    static func spokenInterval(_ last: Date?, now: Date, calendar: Calendar, locale: Locale = .current) -> String {
        guard let last else {
            return L10n.text("guide.interval.placeholder", locale: locale)
        }
        switch bucket(from: last, to: now, calendar: calendar) {
        case .sameDay:
            return L10n.text("guide.interval.lessThanDay", locale: locale)
        case .days(1):
            return L10n.text("guide.interval.oneDay", locale: locale)
        case .days(let count):
            return L10n.spokenDays(count, locale: locale)
        case .weeks(let count):
            return L10n.spokenWeeks(count, locale: locale)
        case .months(let count):
            return L10n.spokenMonths(count, locale: locale)
        case .years(let count):
            return L10n.spokenYears(count, locale: locale)
        }
    }
}
