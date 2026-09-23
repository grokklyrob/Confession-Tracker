import Foundation
import Testing
@testable import ConfessionTracker

struct EntryValidationTests {
    private func calendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0, _ second: Int = 0) -> Date {
        let calendar = calendar()
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return calendar.date(from: components)!
    }

    @Test func whitespacePenanceBecomesNil() {
        #expect(EntryValidation.normalizedPenance("   ") == nil)
        #expect(EntryValidation.normalizedPenance("\n\n") == nil)
        #expect(EntryValidation.normalizedPenance("  \n  penance  \n") == "penance")
        #expect(EntryValidation.normalizedPenance(nil) == nil)
    }

    @Test func penanceLimiterKeepsFirstTwoThousandCharacters() {
        let pasted = String(repeating: "a", count: 2_500)
        let limited = EntryValidation.limitedPenance(pasted)
        #expect(limited.count == 2_000)
        #expect(limited == String(repeating: "a", count: 2_000))
        #expect(EntryValidation.showsPenanceCounter(limited))

        let family = "👨‍👩‍👧‍👦"
        #expect(family.count == 1)
        let emojiPaste = String(repeating: family, count: 2_001)
        #expect(EntryValidation.limitedPenance(emojiPaste).count == 2_000)
    }

    @Test func futureAndMinimumDates() {
        let calendar = calendar()
        let now = date(2026, 6, 15, 12, 0, 0)
        #expect(EntryValidation.isDateAllowed(now, now: now, calendar: calendar))
        #expect(EntryValidation.isDateAllowed(now.addingTimeInterval(-1), now: now, calendar: calendar))
        #expect(!EntryValidation.isDateAllowed(now.addingTimeInterval(1), now: now, calendar: calendar))

        let future = now.addingTimeInterval(86_400)
        #expect(EntryValidation.isDateAllowed(future, now: now, originalDate: future, calendar: calendar))
        #expect(!EntryValidation.isDateAllowed(future, now: now, originalDate: now, calendar: calendar))

        let minimum = EntryValidation.minimumDate(calendar: calendar)
        #expect(EntryValidation.isDateAllowed(minimum, now: now, calendar: calendar))
        #expect(!EntryValidation.isDateAllowed(minimum.addingTimeInterval(-1), now: now, calendar: calendar))
        #expect(!EntryValidation.isDateAllowed(date(1899, 12, 31, 23, 59), now: now, calendar: calendar))
    }

    @Test func roundsDownToTheMinute() {
        let calendar = calendar()
        let original = date(2026, 6, 15, 12, 34, 59)
        let rounded = EntryValidation.roundedDownToMinute(original, calendar: calendar)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: rounded)
        #expect(components.minute == 34)
        #expect(components.second == 0)
    }
}
