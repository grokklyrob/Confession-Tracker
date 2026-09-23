import Foundation
import SwiftData

#if TEST_HOOKS
enum SeedFixtures {
    @MainActor
    static func apply(named seed: String, context: ModelContext, now: Date = Date()) throws {
        let calendar = Calendar.autoupdatingCurrent
        switch seed {
        case "empty":
            return
        case "three":
            let store = EntryStore(context: context)
            let newest = calendar.date(byAdding: .day, value: -3, to: now) ?? now
            let middle = calendar.date(byAdding: .day, value: -24, to: now) ?? now
            let oldest = calendar.date(byAdding: .day, value: -400, to: now) ?? now
            try store.create(date: newest, penance: "Three Hail Marys")
            try store.create(date: middle, penance: nil)
            try store.create(date: oldest, penance: nil)
        case "thousand":
            for offset in 1...1_000 {
                let date = calendar.date(byAdding: .day, value: -offset, to: now) ?? now
                let penance = offset == 1 ? "Three Hail Marys" : nil
                context.insert(ConfessionEntry(date: date, penance: penance))
            }
            try context.save()
        default:
            return
        }
    }
}
#endif
