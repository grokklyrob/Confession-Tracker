import Foundation

/// Localized copy. Parameterized strings use the catalog keys from the specification.
nonisolated enum L10n {
    static func text(_ key: String.LocalizationValue, locale: Locale = .current) -> String {
        String(localized: key, bundle: AppBundle.module, locale: locale)
    }

    static func daysAgo(_ n: Int, locale: Locale = .current) -> String {
        format("interval.daysAgo", defaultValue: "\(n) days ago", locale: locale, comment: "Relative interval. n is 2–13")
    }

    static func weeksAgo(_ n: Int, locale: Locale = .current) -> String {
        format("interval.weeksAgo", defaultValue: "\(n) weeks ago", locale: locale, comment: "Relative interval. n is 2–8")
    }

    static func monthsAgo(_ n: Int, locale: Locale = .current) -> String {
        format("interval.monthsAgo", defaultValue: "\(n) months ago", locale: locale, comment: "Relative interval. n is 2–23")
    }

    static func yearsAgo(_ n: Int, locale: Locale = .current) -> String {
        format("interval.yearsAgo", defaultValue: "\(n) years ago", locale: locale, comment: "Relative interval. n is 2 or more")
    }

    static func daysAfterPrevious(_ n: Int, locale: Locale = .current) -> String {
        format(
            "interval.daysAfterPrevious",
            defaultValue: "\(n) days after previous",
            locale: locale,
            comment: "History row. Plural one is 1 day after previous. n is 1–13"
        )
    }

    static func weeksAfterPrevious(_ n: Int, locale: Locale = .current) -> String {
        format("interval.weeksAfterPrevious", defaultValue: "\(n) weeks after previous", locale: locale, comment: "History row. n is 2–8")
    }

    static func monthsAfterPrevious(_ n: Int, locale: Locale = .current) -> String {
        format("interval.monthsAfterPrevious", defaultValue: "\(n) months after previous", locale: locale, comment: "History row. n is 2–23")
    }

    static func yearsAfterPrevious(_ n: Int, locale: Locale = .current) -> String {
        format("interval.yearsAfterPrevious", defaultValue: "\(n) years after previous", locale: locale, comment: "History row. n is 2 or more")
    }

    static func spokenDays(_ n: Int, locale: Locale = .current) -> String {
        format("guide.interval.days", defaultValue: "\(n) days", locale: locale, comment: "Spoken interval")
    }

    static func spokenWeeks(_ n: Int, locale: Locale = .current) -> String {
        format("guide.interval.weeks", defaultValue: "\(n) weeks", locale: locale, comment: "Spoken interval")
    }

    static func spokenMonths(_ n: Int, locale: Locale = .current) -> String {
        format("guide.interval.months", defaultValue: "\(n) months", locale: locale, comment: "Spoken interval")
    }

    static func spokenYears(_ n: Int, locale: Locale = .current) -> String {
        format("guide.interval.years", defaultValue: "\(n) years", locale: locale, comment: "Spoken interval. n is 2 or more")
    }

    static func penanceCounter(_ n: Int, locale: Locale = .current) -> String {
        format("entry.penance.counter", defaultValue: "\(n) of 2,000 characters", locale: locale, comment: "Penance footer, shown within 200 characters of the limit")
    }

    static func summaryLabel(date: String, interval: String, locale: Locale = .current) -> String {
        String(
            localized: LocalizedStringResource(
                "a11y.summary",
                defaultValue: "Last confession, \(date), \(interval)",
                locale: locale,
                bundle: AppBundle.module,
                comment: "Summary row accessibility label"
            )
        )
    }

    static func historyRow(_ dateTime: String, locale: Locale = .current) -> String {
        String(
            localized: LocalizedStringResource(
                "a11y.historyRow",
                defaultValue: "\(dateTime)",
                locale: locale,
                bundle: AppBundle.module,
                comment: "History row label, oldest entry"
            )
        )
    }

    static func historyRow(dateTime: String, interval: String, locale: Locale = .current) -> String {
        String(
            localized: LocalizedStringResource(
                "a11y.historyRow.withInterval",
                defaultValue: "\(dateTime), \(interval)",
                locale: locale,
                bundle: AppBundle.module,
                comment: "History row label"
            )
        )
    }

    static func historyRowPenance(_ penance: String, locale: Locale = .current) -> String {
        String(
            localized: LocalizedStringResource(
                "a11y.historyRow.penance",
                defaultValue: "Penance: \(penance)",
                locale: locale,
                bundle: AppBundle.module,
                comment: "Appended to the row label after a comma"
            )
        )
    }

    static func stepHeader(number: Int, title: String, locale: Locale = .current) -> String {
        String(
            localized: LocalizedStringResource(
                "guide.step.header",
                defaultValue: "Step \(number): \(title)",
                locale: locale,
                bundle: AppBundle.module,
                comment: "Section header"
            )
        )
    }

    static func blessMe(interval: String, locale: Locale = .current) -> String {
        String(
            localized: LocalizedStringResource(
                "guide.line.blessMe",
                defaultValue: "Bless me, Father, for I have sinned. It has been \(interval) since my last confession.",
                locale: locale,
                bundle: AppBundle.module,
                comment: "Guide line. interval is the spoken phrase"
            )
        )
    }

    private static func format(
        _ key: StaticString,
        defaultValue: String.LocalizationValue,
        locale: Locale,
        comment: StaticString
    ) -> String {
        String(
            localized: LocalizedStringResource(
                key,
                defaultValue: defaultValue,
                locale: locale,
                bundle: AppBundle.module,
                comment: comment
            )
        )
    }
}
