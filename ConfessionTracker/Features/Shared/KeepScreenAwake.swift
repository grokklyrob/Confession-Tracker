import SwiftUI
import UIKit

struct KeepScreenAwake: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onAppear { update() }
            .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
            .onChange(of: scenePhase) { _, _ in update() }
    }

    private func update() {
        UIApplication.shared.isIdleTimerDisabled = scenePhase == .active
    }
}

extension View {
    func keepScreenAwake() -> some View {
        modifier(KeepScreenAwake())
    }
}
