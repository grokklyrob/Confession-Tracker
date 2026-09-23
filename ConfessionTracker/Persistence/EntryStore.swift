import Foundation
import SwiftData

/// Mutations for confession entries. Callers address entries by id, never by holding a model across a delete.
struct EntryStore {
    let context: ModelContext

    @discardableResult
    func create(date: Date, penance: String?) throws -> UUID {
        let entry = ConfessionEntry(date: date, penance: EntryValidation.normalizedPenance(penance))
        context.insert(entry)
        try saveOrRollback()
        return entry.id
    }

    /// Returns false and writes nothing when no entry has that id.
    @discardableResult
    func update(id: UUID, date: Date, penance: String?) throws -> Bool {
        guard let entry = try fetch(id: id) else { return false }
        entry.date = date
        entry.penance = EntryValidation.normalizedPenance(penance)
        entry.updatedAt = Date()
        try saveOrRollback()
        return true
    }

    /// Returns false when no entry has that id.
    @discardableResult
    func delete(id: UUID) throws -> Bool {
        guard let entry = try fetch(id: id) else { return false }
        context.delete(entry)
        try saveOrRollback()
        return true
    }

    func deleteAll() throws {
        try context.delete(model: ConfessionEntry.self)
        try saveOrRollback()
    }

    func fetch(id: UUID) throws -> ConfessionEntry? {
        var descriptor = FetchDescriptor<ConfessionEntry>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func saveOrRollback() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            Logging.persistenceError(error)
            throw error
        }
    }
}
