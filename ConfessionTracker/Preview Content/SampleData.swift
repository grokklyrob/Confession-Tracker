#if DEBUG
import Foundation
import SwiftData

@MainActor
enum SampleData {
    static let firstEntryID = UUID()

    static let emptyContainer: ModelContainer = makeContainer(seed: false)

    static let populatedContainer: ModelContainer = makeContainer(seed: true)

    private static func makeContainer(seed: Bool) -> ModelContainer {
        do {
            let schema = Schema(versionedSchema: SchemaV1.self)
            let configuration = ModelConfiguration(
                seed ? "preview-populated" : "preview-empty",
                schema: schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .none
            )
            let container = try ModelContainer(
                for: schema,
                migrationPlan: ConfessionMigrationPlan.self,
                configurations: [configuration]
            )
            if seed {
                let context = container.mainContext
                let now = Date()
                let calendar = Calendar.autoupdatingCurrent
                let newest = calendar.date(byAdding: .day, value: -3, to: now) ?? now
                let middle = calendar.date(byAdding: .day, value: -24, to: now) ?? now
                let oldest = calendar.date(byAdding: .day, value: -400, to: now) ?? now
                let newestEntry = ConfessionEntry(date: newest, penance: "Three Hail Marys")
                newestEntry.id = firstEntryID
                context.insert(newestEntry)
                context.insert(ConfessionEntry(date: middle, penance: nil))
                context.insert(ConfessionEntry(date: oldest, penance: nil))
                try context.save()
            }
            return container
        } catch {
            fatalError("Preview store failed")
        }
    }
}
#endif
