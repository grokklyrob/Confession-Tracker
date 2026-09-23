import SwiftUI
import UIKit

struct SignificantTimeRefresh: ViewModifier {
    @Binding var now: Date
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    now = Date()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                now = Date()
            }
    }
}

extension View {
    func refreshNow(_ now: Binding<Date>) -> some View {
        modifier(SignificantTimeRefresh(now: now))
    }
}
