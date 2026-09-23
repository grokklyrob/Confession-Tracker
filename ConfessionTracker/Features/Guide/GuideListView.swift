import SwiftUI

struct GuideListView: View {
    let lastConfession: Date?
    let canLog: Bool
    @Binding var showAdd: Bool
    @Binding var now: Date

    @Environment(\.appContent) private var content

    var body: some View {
        List {
            Section {
                Text(verbatim: content.guideIntro)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            ForEach(Array(content.guideSteps.enumerated()), id: \.element.id) { index, step in
                Section {
                    ForEach(Array(step.lines.enumerated()), id: \.offset) { _, line in
                        GuideLineView(
                            line: line,
                            prayer: content.actOfContrition,
                            blessMeSentence: blessMeSentence
                        )
                    }
                    if canLog, index == content.guideSteps.count - 1 {
                        ProminentActionButton(titleKey: "guide.logNow") {
                            showAdd = true
                        }
                    }
                } header: {
                    Text(verbatim: L10n.stepHeader(number: index + 1, title: step.title))
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var blessMeSentence: String {
        let phrase = IntervalFormatter.spokenInterval(lastConfession, now: now, calendar: .autoupdatingCurrent)
        return L10n.blessMe(interval: phrase)
    }
}

#if DEBUG
private struct GuideListPreview: View {
    @State private var showAdd = false
    @State private var now = Date()

    var body: some View {
        NavigationStack {
            GuideListView(lastConfession: nil, canLog: true, showAdd: $showAdd, now: $now)
        }
    }
}

#Preview {
    GuideListPreview()
}
#endif
