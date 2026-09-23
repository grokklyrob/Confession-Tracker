import SwiftUI

struct StoreErrorView: View {
    var body: some View {
        ContentUnavailableView(
            "error.store.title",
            systemImage: "exclamationmark.triangle",
            description: Text("error.store.body")
        )
    }
}

#if DEBUG
#Preview {
    StoreErrorView()
}
#endif
