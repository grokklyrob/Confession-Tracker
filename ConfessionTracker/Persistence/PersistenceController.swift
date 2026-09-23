import Foundation
import SwiftData

@Observable
final class PersistenceController {
    let container: ModelContainer?
    let loadError: Error?

    init() {
        do {
            let location = try Self.resolveLocation()
            if location.corruptBeforeOpen {
                try Self.writeCorruptStore(at: location.storeURL)
            }
            let schema = Schema(versionedSchema: SchemaV1.self)
            let configuration = ModelConfiguration(
                schema: schema,
                url: location.storeURL,
                cloudKitDatabase: .none
            )
            let container = try ModelContainer(
                for: schema,
                migrationPlan: ConfessionMigrationPlan.self,
                configurations: [configuration]
            )
            self.container = container
            self.loadError = nil
            do {
                try Self.seedIfNeeded(container: container)
            } catch {
                Logging.persistenceError(error)
            }
        } catch {
            Logging.persistenceError(error)
            self.container = nil
            self.loadError = error
        }
    }

    private struct Location {
        var storeURL: URL
        var corruptBeforeOpen: Bool
    }

    private static func resolveLocation() throws -> Location {
        #if TEST_HOOKS
        if TestHooks.isUITesting {
            if TestHooks.shouldReset {
                TestHooks.resetDefaults()
            }
            let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let directory = caches.appendingPathComponent("UITestStore", isDirectory: true)
            let storeURL = StoreLocation.storeFileURL(in: directory)
            if TestHooks.shouldReset {
                StoreLocation.removeStore(at: storeURL)
            }
            try StoreLocation.prepare(directory)
            return Location(storeURL: storeURL, corruptBeforeOpen: TestHooks.shouldCorruptStore)
        }
        #endif
        let directory = try StoreLocation.applicationSupportDirectory()
        return Location(storeURL: StoreLocation.storeFileURL(in: directory), corruptBeforeOpen: false)
    }

    private static func writeCorruptStore(at url: URL) throws {
        try Data(repeating: 0xFF, count: 64).write(to: url, options: .atomic)
    }

    @MainActor
    private static func seedIfNeeded(container: ModelContainer) throws {
        #if TEST_HOOKS
        guard TestHooks.isUITesting, TestHooks.shouldReset, let seed = TestHooks.seed else { return }
        try SeedFixtures.apply(named: seed, context: container.mainContext)
        #else
        _ = container
        #endif
    }
}
