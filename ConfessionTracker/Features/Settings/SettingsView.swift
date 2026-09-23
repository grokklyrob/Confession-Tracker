import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var confirmFirst = false
    @State private var confirmSecond = false
    @State private var saveError: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button("settings.deleteAll", role: .destructive) {
                        confirmFirst = true
                    }
                } header: {
                    Text("settings.section.data")
                } footer: {
                    Text("settings.data.footer")
                }

                Section {
                    LabeledContent {
                        Text(verbatim: versionText)
                    } label: {
                        Text("settings.version")
                    }
                    .accessibilityIdentifier("versionRow")
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        Text("settings.privacy")
                    }
                    NavigationLink {
                        AcknowledgementsView()
                    } label: {
                        Text("settings.acknowledgements")
                    }
                } header: {
                    Text("settings.section.about")
                }
            }
            .navigationTitle("settings.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
        .confirmationDialog(
            Text("settings.deleteAll.confirm1.title"),
            isPresented: $confirmFirst,
            titleVisibility: .visible
        ) {
            Button("settings.deleteAll.confirm1.action", role: .destructive) {
                confirmSecond = true
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("settings.deleteAll.confirm1.message")
        }
        .alert(
            Text("settings.deleteAll.confirm2.title"),
            isPresented: $confirmSecond
        ) {
            Button("settings.deleteAll.confirm2.action", role: .destructive) {
                deleteAll()
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("settings.deleteAll.confirm2.message")
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

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        return "\(version) (\(build))"
    }

    private var saveErrorPresented: Binding<Bool> {
        Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )
    }

    private func deleteAll() {
        do {
            try EntryStore(context: modelContext).deleteAll()
            Haptics.warning()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
        .modelContainer(SampleData.populatedContainer)
}
#endif
