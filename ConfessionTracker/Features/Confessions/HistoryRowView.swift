import SwiftUI

struct HistoryRowView: View {
    let dateText: String
    let intervalText: String?
    let penance: String?
    let accessibilityText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: dateText)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            if let intervalText {
                Text(verbatim: intervalText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let penance, !penance.isEmpty {
                Text(verbatim: penance)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: accessibilityText))
    }
}

#if DEBUG
#Preview {
    List {
        HistoryRowView(
            dateText: "14 Mar 2026, 4:30 PM",
            intervalText: "3 weeks after previous",
            penance: "Three Hail Marys",
            accessibilityText: "Saturday, 14 March 2026 at 4:30 PM, 3 weeks after previous, Penance: Three Hail Marys"
        )
    }
}
#endif
