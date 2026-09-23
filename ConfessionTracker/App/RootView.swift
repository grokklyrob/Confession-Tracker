import SwiftUI

enum AppTab: Hashable {
    case confessions
    case prayer
    case guide
}

struct RootView: View {
    let storeAvailable: Bool
    @State private var tab: AppTab = .confessions

    var body: some View {
        TabView(selection: $tab) {
            Group {
                if storeAvailable {
                    ConfessionsListView()
                } else {
                    NavigationStack {
                        StoreErrorView()
                            .navigationTitle("confessions.title")
                            .navigationBarTitleDisplayMode(.large)
                    }
                }
            }
            .tabItem {
                Label("tab.confessions", systemImage: "calendar")
            }
            .tag(AppTab.confessions)

            ActOfContritionView()
                .tabItem {
                    Label("tab.prayer", systemImage: "book.closed")
                        .accessibilityLabel(Text("a11y.tab.prayer"))
                }
                .tag(AppTab.prayer)

            GuideView(storeAvailable: storeAvailable)
                .tabItem {
                    Label("tab.guide", systemImage: "list.number")
                }
                .tag(AppTab.guide)
        }
    }
}

#if DEBUG
#Preview {
    RootView(storeAvailable: true)
        .modelContainer(SampleData.emptyContainer)
}
#endif
