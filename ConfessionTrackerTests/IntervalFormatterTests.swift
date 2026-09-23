import Foundation
import Testing
@testable import ConfessionTracker

struct IntervalFormatterTests {
    private let locale = Locale(identifier: "en_US")

    private func calendar(timeZone identifier: String = "UTC") -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: identifier)!
        calendar.locale = locale
        return calendar
    }

    private func date(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        _ hour: Int = 0,
        _ minute: Int = 0,
        calendar: Calendar
    ) -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components)!
    }

    @Test func dayCountBuckets() {
        let calendar = calendar()
        let start = date(2026, 1, 15, calendar: calendar)
        let expectations: [(Int, IntervalBucket)] = [
            (0, .sameDay),
            (1, .days(1)),
            (2, .days(2)),
            (13, .days(13)),
            (14, .weeks(2)),
            (15, .weeks(2)),
            (59, .weeks(8)),
            (60, .months(2)),
            (61, .months(2)),
        ]
        for (days, expected) in expectations {
            let later = calendar.date(byAdding: .day, value: days, to: start)!
            #expect(IntervalFormatter.bucket(from: start, to: later, calendar: calendar) == expected)
        }
    }

    @Test func monthAndYearBuckets() {
        let calendar = calendar()
        let start = date(2026, 1, 15, calendar: calendar)
        let twoMonths = calendar.date(byAdding: .day, value: 60, to: start)!
        #expect(IntervalFormatter.bucket(from: start, to: twoMonths, calendar: calendar) == .months(2))

        let twentyThree = calendar.date(byAdding: .month, value: 23, to: start)!
        #expect(IntervalFormatter.bucket(from: start, to: twentyThree, calendar: calendar) == .months(23))

        let twentyFour = calendar.date(byAdding: .month, value: 24, to: start)!
        #expect(IntervalFormatter.bucket(from: start, to: twentyFour, calendar: calendar) == .years(2))

        let thirtySix = calendar.date(byAdding: .month, value: 36, to: start)!
        #expect(IntervalFormatter.bucket(from: start, to: thirtySix, calendar: calendar) == .years(3))
    }

    @Test func bucketIsMonotonicAndNeverOneYear() {
        let calendar = calendar()
        let starts = [
            date(2024, 2, 29, calendar: calendar),
            date(2026, 1, 1, calendar: calendar),
            date(2025, 6, 15, calendar: calendar),
            date(2023, 12, 31, calendar: calendar),
        ]
        for start in starts {
            var previous: IntervalBucket = .sameDay
            for day in 0...1_500 {
                let later = calendar.date(byAdding: .day, value: day, to: start)!
                let bucket = IntervalFormatter.bucket(from: start, to: later, calendar: calendar)
                let previousUnit = previous.rank.unit
                let previousValue = previous.rank.value
                let unit = bucket.rank.unit
                let value = bucket.rank.value
                let movedForward = unit > previousUnit
                let sameUnitNotSmaller = unit == previousUnit && value >= previousValue
                #expect(movedForward || sameUnitNotSmaller)
                if case .years(1) = bucket {
                    Issue.record("A 1-year bucket occurred at \(day) days")
                }
                if day == 729 || day == 730 {
                    if case .years(let years) = bucket {
                        #expect(years != 1)
                    }
                }
                previous = bucket
            }
        }
    }

    @Test func bucketAcrossDaylightSaving() {
        let calendar = calendar(timeZone: "Europe/London")
        let earlier = date(2026, 3, 28, 23, 30, calendar: calendar)
        let later = date(2026, 3, 30, 0, 30, calendar: calendar)
        #expect(IntervalFormatter.bucket(from: earlier, to: later, calendar: calendar) == .days(2))
    }

    @Test func bucketWhenEarlierIsAfterLater() {
        let calendar = calendar()
        let earlier = date(2026, 5, 2, calendar: calendar)
        let later = date(2026, 5, 1, calendar: calendar)
        #expect(IntervalFormatter.bucket(from: earlier, to: later, calendar: calendar) == .sameDay)
    }

    @Test func bucketIgnoresTimeOfDay() {
        let calendar = calendar()
        let earlier = date(2026, 4, 1, 23, 59, calendar: calendar)
        let later = date(2026, 4, 2, 0, 1, calendar: calendar)
        #expect(IntervalFormatter.bucket(from: earlier, to: later, calendar: calendar) == .days(1))
    }

    @Test func sinceLastRendersEveryBucket() {
        let calendar = calendar()
        let now = date(2026, 6, 15, 12, 0, calendar: calendar)
        #expect(IntervalFormatter.sinceLast(now, now: now, calendar: calendar, locale: locale) == "Today")
        #expect(IntervalFormatter.sinceLast(calendar.date(byAdding: .day, value: -1, to: now)!, now: now, calendar: calendar, locale: locale) == "Yesterday")
        #expect(IntervalFormatter.sinceLast(calendar.date(byAdding: .day, value: -2, to: now)!, now: now, calendar: calendar, locale: locale) == "2 days ago")
        #expect(IntervalFormatter.sinceLast(calendar.date(byAdding: .day, value: -14, to: now)!, now: now, calendar: calendar, locale: locale) == "2 weeks ago")
        #expect(IntervalFormatter.sinceLast(calendar.date(byAdding: .day, value: -60, to: now)!, now: now, calendar: calendar, locale: locale) == "2 months ago")
        #expect(IntervalFormatter.sinceLast(calendar.date(byAdding: .month, value: -23, to: now)!, now: now, calendar: calendar, locale: locale) == "23 months ago")
        #expect(IntervalFormatter.sinceLast(calendar.date(byAdding: .month, value: -24, to: now)!, now: now, calendar: calendar, locale: locale) == "2 years ago")
        #expect(IntervalFormatter.sinceLast(calendar.date(byAdding: .month, value: -36, to: now)!, now: now, calendar: calendar, locale: locale) == "3 years ago")
    }

    @Test func afterPreviousRendersEveryBucket() {
        let calendar = calendar()
        let current = date(2026, 6, 15, 12, 0, calendar: calendar)
        #expect(IntervalFormatter.afterPrevious(current: current, previous: current, calendar: calendar, locale: locale) == "Same day as previous")
        #expect(IntervalFormatter.afterPrevious(current: current, previous: calendar.date(byAdding: .day, value: -1, to: current)!, calendar: calendar, locale: locale) == "1 day after previous")
        #expect(IntervalFormatter.afterPrevious(current: current, previous: calendar.date(byAdding: .day, value: -2, to: current)!, calendar: calendar, locale: locale) == "2 days after previous")
        #expect(IntervalFormatter.afterPrevious(current: current, previous: calendar.date(byAdding: .day, value: -21, to: current)!, calendar: calendar, locale: locale) == "3 weeks after previous")
        #expect(IntervalFormatter.afterPrevious(current: current, previous: calendar.date(byAdding: .day, value: -60, to: current)!, calendar: calendar, locale: locale) == "2 months after previous")
        #expect(IntervalFormatter.afterPrevious(current: current, previous: calendar.date(byAdding: .month, value: -23, to: current)!, calendar: calendar, locale: locale) == "23 months after previous")
        #expect(IntervalFormatter.afterPrevious(current: current, previous: calendar.date(byAdding: .month, value: -24, to: current)!, calendar: calendar, locale: locale) == "2 years after previous")
    }

    @Test func spokenIntervalRendersEveryBucket() {
        let calendar = calendar()
        let now = date(2026, 6, 15, 12, 0, calendar: calendar)
        #expect(IntervalFormatter.spokenInterval(nil, now: now, calendar: calendar, locale: locale) == "[time]")
        let phrases = [
            IntervalFormatter.spokenInterval(now, now: now, calendar: calendar, locale: locale),
            IntervalFormatter.spokenInterval(calendar.date(byAdding: .day, value: -1, to: now)!, now: now, calendar: calendar, locale: locale),
            IntervalFormatter.spokenInterval(calendar.date(byAdding: .day, value: -3, to: now)!, now: now, calendar: calendar, locale: locale),
            IntervalFormatter.spokenInterval(calendar.date(byAdding: .day, value: -21, to: now)!, now: now, calendar: calendar, locale: locale),
            IntervalFormatter.spokenInterval(calendar.date(byAdding: .day, value: -60, to: now)!, now: now, calendar: calendar, locale: locale),
            IntervalFormatter.spokenInterval(calendar.date(byAdding: .month, value: -23, to: now)!, now: now, calendar: calendar, locale: locale),
            IntervalFormatter.spokenInterval(calendar.date(byAdding: .month, value: -36, to: now)!, now: now, calendar: calendar, locale: locale),
        ]
        #expect(phrases == [
            "less than a day",
            "one day",
            "3 days",
            "3 weeks",
            "2 months",
            "23 months",
            "3 years",
        ])
        for phrase in phrases {
            #expect(!phrase.contains("It has been"))
            #expect(!phrase.contains("since my last confession"))
        }
        let sentence = L10n.blessMe(interval: "3 weeks", locale: locale)
        #expect(sentence == "Bless me, Father, for I have sinned. It has been 3 weeks since my last confession.")
        #expect(sentence.components(separatedBy: "It has been").count - 1 == 1)
    }
}
