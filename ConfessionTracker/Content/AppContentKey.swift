import SwiftUI

nonisolated struct AppContentKey: EnvironmentKey {
    static let defaultValue = ContentLoader.load()
}

extension EnvironmentValues {
    var appContent: AppContent {
        get { self[AppContentKey.self] }
        set { self[AppContentKey.self] = newValue }
    }
}
