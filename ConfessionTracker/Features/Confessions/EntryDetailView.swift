import SwiftData
import SwiftUI

struct EntryDetailView: View {
    @Environment(ConfessionsModel.self) private var model
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [ConfessionEntry]
    @State private var showEditor = false
    @State private var confirmDelete = false

    let entryID: UUID

    init(entryID: UUID) {
        self.entryID = entryID
        let id = entryID
        _entries = Query(filter: #Predicate<ConfessionEntry> { $0.id == id })
    }

    var body: some View {
        Group {
            if let entry = entries.first {
                detail(entry)
            } else {
                Color.clear
            }
        }
        .onAppear(perform: popIfMissing)
        .onChange(of: entries.count) { _, _ in
            popIfMissing()
        }
    }

    private func detail(_ entry: ConfessionEntry) -> some View {
        List {
            Section {
                DetailValueRow(titleKey: "detail.field.date", value: EntryDateStyle.detailDate(entry.date))
                DetailValueRow(titleKey: "detail.field.time", value: EntryDateStyle.detailTime(entry.date))
            }
            Section {
                if let penance = entry.penance, !penance.isEmpty {
                    Text(verbatim: penance)
                        .font(.body)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("detail.penance.empty")
                        .foregroundStyle(.secondary)
                }
            }
            Section {
                Button("detail.delete", role: .destructive) {
                    confirmDelete = true
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text(verbatim: EntryDateStyle.navigation(entry.date)))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("detail.edit") {
                    showEditor = true
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            EntryEditorView(mode: .edit(entryID))
        }
        .confirmationDialog(
            Text("delete.confirm.title"),
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("delete.confirm.action", role: .destructive) {
                model.pendingDeletionID = entryID
                Haptics.warning()
                model.path.removeAll { $0.id == entryID }
            }
            Button("common.cancel", role: .cancel) {}
        }
    }

    private func popIfMissing() {
        guard entries.isEmpty else { return }
        model.path.removeAll { $0.id == entryID }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        EntryDetailView(entryID: SampleData.firstEntryID)
    }
    .environment(ConfessionsModel())
    .modelContainer(SampleData.populatedContainer)
}
#endif
