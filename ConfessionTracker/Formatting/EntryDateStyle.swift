import Foundation

nonisolated enum EntryDateStyle {
    static func summary(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .long, time: .omitted))
    }

    static func history(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened))
    }

    static func accessibility(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .complete, time: .shortened))
    }

    static func navigation(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .long, time: .omitted))
    }

    static func detailDate(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .complete, time: .omitted))
    }

    static func detailTime(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .omitted, time: .shortened))
    }
}
