import Foundation
import os

/// App loggers. Messages must not include entry dates or penance text.
nonisolated enum Logging {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.robertstevens.confessiontracker"

    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let content = Logger(subsystem: subsystem, category: "content")
    static let ui = Logger(subsystem: subsystem, category: "ui")

    static func persistenceError(_ error: Error) {
        let nsError = error as NSError
        persistence.error("Persistence error domain=\(nsError.domain, privacy: .public) code=\(nsError.code, privacy: .public)")
    }
}
