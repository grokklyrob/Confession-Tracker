import SwiftUI

struct SummaryHeaderView: View {
    let isEmpty: Bool
    let dateText: String
    let intervalText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isEmpty {
                Text("summary.empty.title")
                    .font(.headline)
                Text("summary.empty.body")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("summary.lastConfession")
                    .font(.headline)
                Text(verbatim: dateText)
                    .font(.title2.bold())
                Text(verbatim: intervalText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: accessibilityLabel))
        .accessibilityIdentifier("summaryHeader")
    }

    private var accessibilityLabel: String {
        if isEmpty {
            let title = String(localized: "summary.empty.title", bundle: AppBundle.module)
            let body = String(localized: "summary.empty.body", bundle: AppBundle.module)
            return "\(title)\n\(body)"
        }
        return L10n.summaryLabel(date: dateText, interval: intervalText)
    }
}

#if DEBUG
#Preview("Empty") {
    List {
        SummaryHeaderView(isEmpty: true, dateText: "", intervalText: "")
    }
}

#Preview("Populated") {
    List {
        SummaryHeaderView(isEmpty: false, dateText: "14 March 2026", intervalText: "12 days ago")
    }
}
#endif
