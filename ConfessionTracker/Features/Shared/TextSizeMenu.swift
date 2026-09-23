import SwiftUI

struct TextSizeMenu: View {
    @AppStorage(PreferenceKeys.textSizeSteps) private var storedSteps = 0

    private var steps: Binding<Int> {
        Binding(
            get: { TextScale.resolvedSteps(storedSteps) },
            set: { storedSteps = TextScale.resolvedSteps($0) }
        )
    }

    private var currentName: LocalizedStringKey {
        switch steps.wrappedValue {
        case 2:
            return "textSize.large"
        case 4:
            return "textSize.extraLarge"
        default:
            return "textSize.default"
        }
    }

    var body: some View {
        Menu {
            Picker(selection: steps) {
                Text("textSize.default").tag(0)
                Text("textSize.large").tag(2)
                Text("textSize.extraLarge").tag(4)
            } label: {
                Text("textSize.menu")
            }
            .pickerStyle(.inline)
        } label: {
            Image(systemName: "textformat.size")
        }
        .accessibilityLabel(Text("textSize.menu"))
        .accessibilityValue(Text(currentName))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        Text(verbatim: "Text Size")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    TextSizeMenu()
                }
            }
    }
}
#endif
