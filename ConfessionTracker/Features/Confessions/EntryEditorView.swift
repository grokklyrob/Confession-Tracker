import SwiftData
import SwiftUI

enum EntryEditorMode {
    case add
    case edit(UUID)

    var titleKey: LocalizedStringKey {
        switch self {
        case .add:
            "entry.add.title"
        case .edit:
            "entry.edit.title"
        }
    }

    var confirmKey: LocalizedStringKey {
        switch self {
        case .add:
            "common.save"
        case .edit:
            "common.done"
        }
    }

    var entryID: UUID? {
        if case .edit(let id) = self { return id }
        return nil
    }
}

struct EntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ConfessionEntry.date, order: .reverse) private var entries: [ConfessionEntry]

    let mode: EntryEditorMode

    @State private var date: Date
    @State private var initialDate: Date
    @State private var penance: String
    @State private var initialPenance: String
    @State private var rangeEnd: Date
    @State private var isReady = false
    @State private var showDiscard = false
    @State private var showFutureAlert = false
    @State private var saveError: String?

    init(mode: EntryEditorMode) {
        self.mode = mode
        let now = Date()
        let rounded = EntryValidation.roundedDownToMinute(now)
        _date = State(initialValue: rounded)
        _initialDate = State(initialValue: rounded)
        _penance = State(initialValue: "")
        _initialPenance = State(initialValue: "")
        _rangeEnd = State(initialValue: now)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if isReady {
                        DatePicker(
                            selection: $date,
                            in: EntryValidation.minimumDate()...rangeEnd,
                            displayedComponents: [.date, .hourAndMinute]
                        ) {
                            Text("entry.field.date")
                        }
                        .datePickerStyle(.compact)
                    }
                } header: {
                    Text("entry.section.dateTime")
                } footer: {
                    if showsSameDayNotice {
                        Text("entry.sameDay.notice")
                    }
                }

                Section {
                    TextField("entry.field.penance.placeholder", text: penanceBinding, axis: .vertical)
                        .lineLimit(3...8)
                        .textInputAutocapitalization(.sentences)
                } header: {
                    Text("entry.section.penance")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("entry.section.penance.footer")
                        if EntryValidation.showsPenanceCounter(penance) {
                            Text(verbatim: L10n.penanceCounter(penance.count))
                        }
                    }
                }
            }
            .navigationTitle(mode.titleKey)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.confirmKey, action: save)
                }
            }
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(isDirty)
        .onAppear(perform: loadIfNeeded)
        .confirmationDialog(
            Text("entry.discard.title"),
            isPresented: $showDiscard,
            titleVisibility: .visible
        ) {
            Button("entry.discard.action", role: .destructive) {
                dismiss()
            }
            Button("common.cancel", role: .cancel) {}
        }
        .alert(
            Text("entry.error.futureDate.title"),
            isPresented: $showFutureAlert
        ) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("entry.error.futureDate.message")
        }
        .alert(
            Text("error.save.title"),
            isPresented: saveErrorPresented
        ) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text(verbatim: saveError ?? "")
        }
    }

    private var penanceBinding: Binding<String> {
        Binding(
            get: { penance },
            set: { penance = EntryValidation.limitedPenance($0) }
        )
    }

    private var isDirty: Bool {
        date != initialDate || penance != initialPenance
    }

    private var showsSameDayNotice: Bool {
        guard case .add = mode else { return false }
        let calendar = Calendar.autoupdatingCurrent
        return entries.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private var saveErrorPresented: Binding<Bool> {
        Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )
    }

    private func loadIfNeeded() {
        guard !isReady else { return }
        switch mode {
        case .add:
            let now = Date()
            let rounded = EntryValidation.roundedDownToMinute(now)
            date = rounded
            initialDate = rounded
            rangeEnd = now
            isReady = true
        case .edit(let id):
            guard let entry = entries.first(where: { $0.id == id }) else {
                dismiss()
                return
            }
            rangeEnd = max(Date(), entry.date)
            date = entry.date
            initialDate = entry.date
            let storedPenance = entry.penance ?? ""
            penance = storedPenance
            initialPenance = storedPenance
            isReady = true
        }
    }

    private func cancel() {
        if isDirty {
            showDiscard = true
        } else {
            dismiss()
        }
    }

    private func save() {
        let storedDate = mode.entryID.flatMap { id in
            entries.first { $0.id == id }?.date
        }
        guard EntryValidation.isDateAllowed(date, now: Date(), originalDate: storedDate) else {
            showFutureAlert = true
            return
        }
        let store = EntryStore(context: modelContext)
        do {
            switch mode {
            case .add:
                try store.create(date: date, penance: penance)
                Haptics.success()
            case .edit(let id):
                if try store.update(id: id, date: date, penance: penance) {
                    Haptics.success()
                }
            }
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#if DEBUG
#Preview("Add") {
    EntryEditorView(mode: .add)
        .modelContainer(SampleData.populatedContainer)
}

#Preview("Edit") {
    EntryEditorView(mode: .edit(SampleData.firstEntryID))
        .modelContainer(SampleData.populatedContainer)
}
#endif
