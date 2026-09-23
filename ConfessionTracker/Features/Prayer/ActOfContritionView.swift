import SwiftUI

struct ActOfContritionView: View {
    @Environment(\.appContent) private var content
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AppStorage(PreferenceKeys.textSizeSteps) private var storedSteps = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(content.actOfContrition.body.enumerated()), id: \.offset) { _, paragraph in
                        Text(verbatim: paragraph)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineSpacing(4)
                            .textSelection(.enabled)
                            .dynamicTypeSize(readingSize)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text(verbatim: content.actOfContrition.source)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("prayer.title")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    TextSizeMenu()
                }
            }
        }
        .keepScreenAwake()
    }

    private var readingSize: DynamicTypeSize {
        TextScale.stepped(system: dynamicTypeSize, storedSteps: storedSteps)
    }
}

#if DEBUG
#Preview {
    ActOfContritionView()
}
#endif
