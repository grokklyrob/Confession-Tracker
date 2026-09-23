import Foundation
import SwiftData

/// Schema version 1. Models stay CloudKit-compatible: no unique constraints, every stored property optional or defaulted.
nonisolated enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] { [ConfessionEntry.self] }

    @Model
    nonisolated final class ConfessionEntry {
        /// Stable identity, generated on creation. Not unique-constrained (kept CloudKit-compatible); uniqueness is by convention.
        var id: UUID = UUID()

        /// The date and time the confession took place, as chosen by the user. Stored as an absolute instant.
        var date: Date = Date()

        /// Penance assigned by the priest. nil when not recorded. Trimmed; max 2,000 characters.
        var penance: String? = nil

        /// Record creation instant. Never modified after creation.
        var createdAt: Date = Date()

        /// Instant of the most recent user edit. Equal to createdAt until first edit.
        var updatedAt: Date = Date()

        init(date: Date, penance: String? = nil) {
            let now = Date()
            self.id = UUID()
            self.date = date
            self.penance = penance
            self.createdAt = now
            self.updatedAt = now
        }
    }
}

typealias ConfessionEntry = SchemaV1.ConfessionEntry
