import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            Text("privacy.body")
                .font(.body)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
        .navigationTitle("settings.privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PrivacyView()
    }
}
#endif
