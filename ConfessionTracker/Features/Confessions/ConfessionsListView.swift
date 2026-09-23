import SwiftData
import SwiftUI

struct ConfessionsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ConfessionEntry.date, order: .reverse) private var entries: [ConfessionEntry]
    @State private var model = ConfessionsModel()
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var pendingSwipeDelete: UUID?
    @State private var saveError: String?

    var body: some View {
        @Bindable var navigation = model
        NavigationStack(path: $navigation.path) {
            List {
                Section {
                    SummaryHeaderView(
                        isEmpty: entries.isEmpty,
                        dateText: summaryDate,
                        intervalText: summaryInterval
                    )
                }
                Section {
                    ProminentActionButton(titleKey: "action.logNow") {
                        showAdd = true
                    }
                }
                ForEach(sections) { section in
                    Section {
                        ForEach(section.entries) { snapshot in
                            historyLink(snapshot, in: snapshots)
                        }
                    } header: {
                        Text(verbatim: String(section.year))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("confessions.title")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel(Text("a11y.settings.button"))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(Text("a11y.add.button"))
                }
            }
            .navigationDestination(for: EntryRoute.self) { route in
                EntryDetailView(entryID: route.id)
            }
            #if TEST_HOOKS
            .accessibilityIdentifier("entryCount")
            .accessibilityValue("\(entries.count)")
            #endif
        }
        .environment(model)
        .refreshNow($model.now)
        .sheet(isPresented: $showAdd) {
            EntryEditorView(mode: .add)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .confirmationDialog(
            Text("delete.confirm.title"),
            isPresented: swipeDeletePresented,
            titleVisibility: .visible,
            presenting: pendingSwipeDelete
        ) { id in
            Button("delete.confirm.action", role: .destructive) {
                deleteFromList(id)
            }
            Button("common.cancel", role: .cancel) {}
        }
        .alert(
            Text("error.save.title"),
            isPresented: saveErrorPresented
        ) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text(verbatim: saveError ?? "")
        }
        .onChange(of: model.path) { _, _ in
            performPendingDeletion()
        }
    }

    private var snapshots: [EntrySnapshot] {
        entries.map { EntrySnapshot(id: $0.id, date: $0.date, penance: $0.penance) }
    }

    private var sections: [YearSection] {
        YearGrouping.sections(from: snapshots, calendar: .autoupdatingCurrent)
    }

    private var summaryDate: String {
        guard let newest = entries.first else { return "" }
        return EntryDateStyle.summary(newest.date)
    }

    private var summaryInterval: String {
        guard let newest = entries.first else { return "" }
        return IntervalFormatter.sinceLast(newest.date, now: model.now, calendar: .autoupdatingCurrent)
    }

    private var swipeDeletePresented: Binding<Bool> {
        Binding(
            get: { pendingSwipeDelete != nil },
            set: { if !$0 { pendingSwipeDelete = nil } }
        )
    }

    private var saveErrorPresented: Binding<Bool> {
        Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )
    }

    private func historyLink(_ snapshot: EntrySnapshot, in snapshots: [EntrySnapshot]) -> some View {
        let interval = intervalText(for: snapshot, in: snapshots)
        return NavigationLink(value: EntryRoute(id: snapshot.id)) {
            HistoryRowView(
                dateText: EntryDateStyle.history(snapshot.date),
                intervalText: interval,
                penance: snapshot.penance,
                accessibilityText: historyAccessibility(snapshot, interval: interval)
            )
        }
        .accessibilityIdentifier("history.\(snapshot.id.uuidString)")
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                pendingSwipeDelete = snapshot.id
            } label: {
                Label("common.delete", systemImage: "trash")
            }
            .tint(.red)
            .accessibilityLabel(Text("common.delete"))
        }
    }

    private func intervalText(for snapshot: EntrySnapshot, in snapshots: [EntrySnapshot]) -> String? {
        guard let index = snapshots.firstIndex(where: { $0.id == snapshot.id }),
              index + 1 < snapshots.count else { return nil }
        return IntervalFormatter.afterPrevious(
            current: snapshot.date,
            previous: snapshots[index + 1].date,
            calendar: .autoupdatingCurrent
        )
    }

    private func historyAccessibility(_ snapshot: EntrySnapshot, interval: String?) -> String {
        let dateTime = EntryDateStyle.accessibility(snapshot.date)
        var label = if let interval {
            L10n.historyRow(dateTime: dateTime, interval: interval)
        } else {
            L10n.historyRow(dateTime)
        }
        if let penance = snapshot.penance, !penance.isEmpty {
            label += ", " + L10n.historyRowPenance(penance)
        }
        return label
    }

    private func deleteFromList(_ id: UUID) {
        do {
            _ = try withAnimation {
                try EntryStore(context: modelContext).delete(id: id)
            }
            Haptics.warning()
        } catch {
            saveError = error.localizedDescription
        }
        pendingSwipeDelete = nil
    }

    private func performPendingDeletion() {
        guard let id = model.pendingDeletionID else { return }
        guard !model.path.contains(where: { $0.id == id }) else { return }
        model.pendingDeletionID = nil
        do {
            _ = try withAnimation {
                try EntryStore(context: modelContext).delete(id: id)
            }
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#if DEBUG
#Preview("Empty") {
    ConfessionsListView()
        .modelContainer(SampleData.emptyContainer)
}

#Preview("Populated") {
    ConfessionsListView()
        .modelContainer(SampleData.populatedContainer)
}
#endif
