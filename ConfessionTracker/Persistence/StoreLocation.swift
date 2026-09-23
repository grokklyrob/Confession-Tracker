import Foundation

/// Store paths and directory creation. The directory is protected with complete file protection.
nonisolated enum StoreLocation {
    static let fileName = "ConfessionTracker.store"

    static func storeFileURL(in directory: URL) -> URL {
        directory.appendingPathComponent(fileName, isDirectory: false)
    }

    static func applicationSupportDirectory(fileManager: FileManager = .default) throws -> URL {
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try prepare(directory, fileManager: fileManager)
        return directory
    }

    static func prepare(_ directory: URL, fileManager: FileManager = .default) throws {
        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.complete]
        )
    }

    static func removeStore(at storeURL: URL, fileManager: FileManager = .default) {
        let path = storeURL.path
        for suffix in ["", "-shm", "-wal"] {
            try? fileManager.removeItem(atPath: path + suffix)
        }
    }
}
