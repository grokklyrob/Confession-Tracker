import SwiftUI

struct DetailValueRow: View {
    let titleKey: LocalizedStringKey
    let value: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline) {
                Text(titleKey)
                Spacer(minLength: 12)
                Text(verbatim: value)
                    .multilineTextAlignment(.trailing)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(titleKey)
                Text(verbatim: value)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    List {
        DetailValueRow(titleKey: "detail.field.date", value: "Saturday, 14 March 2026")
        DetailValueRow(titleKey: "detail.field.time", value: "4:30 PM")
    }
}
#endif
