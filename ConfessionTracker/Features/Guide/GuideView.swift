import SwiftUI

struct GuideView: View {
    let storeAvailable: Bool
    @State private var showAdd = false
    @State private var now = Date()

    var body: some View {
        NavigationStack {
            Group {
                if storeAvailable {
                    GuideQueriedListView(showAdd: $showAdd)
                } else {
                    GuideListView(lastConfession: nil, canLog: false, showAdd: $showAdd, now: $now)
                        .refreshNow($now)
                }
            }
            .navigationTitle("guide.title")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    TextSizeMenu()
                }
            }
        }
        .keepScreenAwake()
        .sheet(isPresented: $showAdd) {
            EntryEditorView(mode: .add)
                .presentationDetents([.large])
        }
    }
}

#if DEBUG
#Preview {
    GuideView(storeAvailable: true)
        .modelContainer(SampleData.emptyContainer)
}
#endif
