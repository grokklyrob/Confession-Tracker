import SwiftData
import SwiftUI

@main
struct ConfessionTrackerApp: App {
    @State private var persistence = PersistenceController()
    @State private var content = ContentLoader.load()

    var body: some Scene {
        WindowGroup {
            RootView(storeAvailable: persistence.container != nil)
                .environment(\.appContent, content)
                .modifier(ModelContainerModifier(container: persistence.container))
                .modifier(UITestStorageModifier())
        }
    }
}

private struct ModelContainerModifier: ViewModifier {
    let container: ModelContainer?

    func body(content: Content) -> some View {
        if let container {
            content.modelContainer(container)
        } else {
            content
        }
    }
}

private struct UITestStorageModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if TEST_HOOKS
        if TestHooks.isUITesting {
            content.defaultAppStorage(TestHooks.defaults)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
