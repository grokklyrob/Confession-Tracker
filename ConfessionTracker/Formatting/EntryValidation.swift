import Foundation

/// Pure validation for confession entry fields. No SwiftUI or SwiftData.
nonisolated enum EntryValidation {
    static let penanceCharacterLimit = 2_000
    private static let counterThreshold = 200

    static func minimumDate(calendar: Calendar = .current) -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = 1900
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        guard let date = calendar.date(from: components) else {
            preconditionFailure("1 January 1900 must be representable")
        }
        return date
    }

    static func roundedDownToMinute(_ date: Date, calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return calendar.date(from: components) ?? date
    }

    /// Keeps the first 2,000 user-perceived characters. An emoji counts as one.
    static func limitedPenance(_ text: String) -> String {
        guard text.count > penanceCharacterLimit else { return text }
        return String(text.prefix(penanceCharacterLimit))
    }

    static func showsPenanceCounter(_ text: String) -> Bool {
        text.count >= penanceCharacterLimit - counterThreshold
    }

    /// Trims whitespace and newlines. Empty results become nil. Over-long values are a programmer error.
    static func normalizedPenance(_ text: String?) -> String? {
        guard let text else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard trimmed.count <= penanceCharacterLimit else {
            assertionFailure("Penance exceeded \(penanceCharacterLimit) characters")
            return String(trimmed.prefix(penanceCharacterLimit))
        }
        return trimmed
    }

    /// A future date is rejected unless it is the entry's unchanged stored date (edit mode).
    static func isDateAllowed(
        _ date: Date,
        now: Date,
        originalDate: Date? = nil,
        calendar: Calendar = .current
    ) -> Bool {
        if date < minimumDate(calendar: calendar) {
            return false
        }
        if date <= now {
            return true
        }
        if let originalDate, date == originalDate {
            return true
        }
        return false
    }
}
