import Foundation

#if TEST_HOOKS
enum TestHooks {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiTesting")
    }

    static var shouldReset: Bool {
        ProcessInfo.processInfo.arguments.contains("-resetState")
    }

    static var shouldCorruptStore: Bool {
        ProcessInfo.processInfo.arguments.contains("-corruptStore")
    }

    static var seed: String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-seed"), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }

    static let defaultsSuiteName = "uitests"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: defaultsSuiteName) ?? .standard
    }

    static func resetDefaults() {
        defaults.removePersistentDomain(forName: defaultsSuiteName)
    }
}
#endif
