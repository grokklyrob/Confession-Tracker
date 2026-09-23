import Foundation

/// Bundle that contains the app target, including when unit tests call into it.
nonisolated enum AppBundle {
    static let module = Bundle(for: BundleToken.self)
}

nonisolated final class BundleToken {}
