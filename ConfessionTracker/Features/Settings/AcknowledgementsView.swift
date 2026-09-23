import SwiftUI

struct AcknowledgementsView: View {
    var body: some View {
        ScrollView {
            Text("acknowledgements.body")
                .font(.body)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
        .navigationTitle("settings.acknowledgements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AcknowledgementsView()
    }
}
#endif
