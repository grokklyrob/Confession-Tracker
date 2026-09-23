import Foundation

nonisolated struct EntrySnapshot: Identifiable, Equatable, Hashable {
    let id: UUID
    let date: Date
    let penance: String?
}

nonisolated struct YearSection: Identifiable, Equatable {
    var id: Int { year }
    let year: Int
    let entries: [EntrySnapshot]
}

/// Groups a date-descending list into calendar years, newest year first.
nonisolated enum YearGrouping {
    static func sections(from entries: [EntrySnapshot], calendar: Calendar) -> [YearSection] {
        var sections: [YearSection] = []
        for entry in entries {
            let year = calendar.component(.year, from: entry.date)
            if let index = sections.firstIndex(where: { $0.year == year }) {
                sections[index] = YearSection(year: year, entries: sections[index].entries + [entry])
            } else {
                sections.append(YearSection(year: year, entries: [entry]))
            }
        }
        return sections
    }
}
