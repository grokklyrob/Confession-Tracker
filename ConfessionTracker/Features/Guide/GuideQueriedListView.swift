import SwiftData
import SwiftUI

struct GuideQueriedListView: View {
    @Binding var showAdd: Bool
    @Query(sort: \ConfessionEntry.date, order: .reverse) private var entries: [ConfessionEntry]
    @State private var now = Date()

    var body: some View {
        GuideListView(
            lastConfession: entries.first?.date,
            canLog: true,
            showAdd: $showAdd,
            now: $now
        )
        .refreshNow($now)
    }
}

#if DEBUG
private struct GuideQueriedPreview: View {
    @State private var showAdd = false

    var body: some View {
        GuideQueriedListView(showAdd: $showAdd)
            .modelContainer(SampleData.populatedContainer)
    }
}

#Preview {
    GuideQueriedPreview()
}
#endif
