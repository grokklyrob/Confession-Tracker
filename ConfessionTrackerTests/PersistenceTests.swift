import Foundation
import SwiftData
import Testing
@testable import ConfessionTracker

@MainActor
struct PersistenceTests {
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let configuration = ModelConfiguration(
            "memory-\(UUID().uuidString)",
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: ConfessionMigrationPlan.self,
            configurations: [configuration]
        )
    }

    @Test func createUpdateDeleteRoundTrip() throws {
        let container = try makeContainer()
        let store = EntryStore(context: container.mainContext)
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let id = try store.create(date: date, penance: "  Three Hail Marys  ")
        let created = try store.fetch(id: id)
        #expect(created?.penance == "Three Hail Marys")
        #expect(created?.date == date)
        #expect(created?.createdAt == created?.updatedAt)

        let edited = date.addingTimeInterval(86_400)
        #expect(try store.update(id: id, date: edited, penance: "A psalm"))
        let updated = try store.fetch(id: id)
        #expect(updated?.date == edited)
        #expect(updated?.penance == "A psalm")
        #expect(updated?.updatedAt != updated?.createdAt)

        #expect(try store.delete(id: id))
        #expect(try store.fetch(id: id) == nil)
    }

    @Test func missingIDDoesNotMutateTheStore() throws {
        let container = try makeContainer()
        let store = EntryStore(context: container.mainContext)
        let id = try store.create(date: Date(timeIntervalSince1970: 1_700_000_000), penance: "kept")
        let missing = UUID()
        #expect(try store.update(id: missing, date: Date(), penance: "nope") == false)
        #expect(try store.delete(id: missing) == false)
        #expect(try store.fetch(id: id)?.penance == "kept")
        let count = try container.mainContext.fetchCount(FetchDescriptor<ConfessionEntry>())
        #expect(count == 1)
    }

    @Test func updateAfterDeleteDoesNotRecreate() throws {
        let container = try makeContainer()
        let store = EntryStore(context: container.mainContext)
        let id = try store.create(date: Date(), penance: "gone")
        #expect(try store.delete(id: id))
        #expect(try store.update(id: id, date: Date(), penance: "back") == false)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<ConfessionEntry>()) == 0)
    }

    @Test func deleteAllLeavesTheContainerUsable() throws {
        let container = try makeContainer()
        let store = EntryStore(context: container.mainContext)
        _ = try store.create(date: Date(), penance: "one")
        _ = try store.create(date: Date().addingTimeInterval(10), penance: nil)
        try store.deleteAll()
        #expect(try container.mainContext.fetchCount(FetchDescriptor<ConfessionEntry>()) == 0)
        let id = try store.create(date: Date(), penance: "after")
        #expect(try store.fetch(id: id)?.penance == "after")
    }

    @Test func yearGroupingOrdersSectionsDescending() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let entries = [
            EntrySnapshot(id: UUID(), date: date(2026, 3, 1, calendar: calendar), penance: nil),
            EntrySnapshot(id: UUID(), date: date(2026, 1, 2, calendar: calendar), penance: nil),
            EntrySnapshot(id: UUID(), date: date(2025, 12, 1, calendar: calendar), penance: nil),
            EntrySnapshot(id: UUID(), date: date(2024, 6, 1, calendar: calendar), penance: "note"),
        ]
        let sections = YearGrouping.sections(from: entries, calendar: calendar)
        #expect(sections.map(\.year) == [2026, 2025, 2024])
        #expect(sections[0].entries.map(\.id) == [entries[0].id, entries[1].id])
        #expect(sections[1].entries.map(\.id) == [entries[2].id])
        #expect(sections[2].entries.map(\.id) == [entries[3].id])
    }

    @Test func schemaHasNoUniqueAttributes() {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let entity = schema.entities.first { $0.name.contains("ConfessionEntry") }
        #expect(entity != nil)
        for property in entity?.properties ?? [] {
            #expect(property.isUnique == false)
        }
    }

    @Test func storeDirectoryIsCreated() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let directory = root.appendingPathComponent("Application Support", isDirectory: true)
        #expect(!FileManager.default.fileExists(atPath: directory.path))
        try StoreLocation.prepare(directory)
        #expect(FileManager.default.fileExists(atPath: directory.path))
        let store = StoreLocation.storeFileURL(in: directory)
        #expect(store.lastPathComponent == "ConfessionTracker.store")
        #expect(store.deletingLastPathComponent().lastPathComponent == "Application Support")
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, calendar: Calendar) -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)!
    }
}
