import UIKit

enum Haptics {
    static func success() {
        notify(.success)
    }

    static func warning() {
        notify(.warning)
    }

    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
