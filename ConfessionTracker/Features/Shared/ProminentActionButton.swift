import SwiftUI

struct ProminentActionButton: View {
    let titleKey: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(titleKey)
                .foregroundStyle(Color("AccentForeground"))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

#if DEBUG
#Preview {
    ProminentActionButton(titleKey: "action.logNow") {}
        .padding()
}
#endif
